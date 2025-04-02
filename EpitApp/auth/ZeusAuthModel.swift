import SwiftUI
import Combine

enum AuthState {
    case unauthenticated, loading, authentified
}

// TODO: Better handle checks (eg no internet = no load)
// Unsure as to how I should handle Office login.
// Eg, have an OfficeAuthModel which lets you login to office,
// then for Zeus and Pegasus 2 options:
// - Login with Office (which uses the saved office token, no need to re open a webview)
// - Login manually (currently done)
// Not even sure if possible to implement, havent looked at pegasus yet.

// TODO: Save tokens to keychain? (unsure)
class ZeusAuthModel: ObservableObject {
    static let shared = ZeusAuthModel()
    
    @Published var authState: AuthState = AuthState.unauthenticated
    
    @Published var token: String? {
        didSet {
            UserDefaults.standard.set(token, forKey: "zeusToken")
        }
    }

    init() {
        self.token = UserDefaults.standard.string(forKey: "zeusToken")

        attemptAllLogins()
    }
    
    private func setValidity(newAuthState: AuthState) {
        DispatchQueue.main.async {
            self.authState = newAuthState
            if (newAuthState == AuthState.unauthenticated) {
                self.token = nil;
                UserDefaults.standard.removeObject(forKey: "officeZeusToken")
                UserDefaults.standard.removeObject(forKey: "zeusToken")
            }
        }
    }
    
    func attemptAllLogins() {
        // - First try and login w the Zeus token
        // - If that doesn't work, try and relog with the Microsoft token.
        // - If that STILL doesn't work, try to get a new Microsoft token silently and login w that.
        // Otherwise just let the user relog manually.
        
        self.setValidity(newAuthState: .loading)
        
        self.updateValidityFromToken(setLoadingState: false) { success1 in
            if (success1) {
                self.setValidity(newAuthState: .authentified)
                return
            }
            if (!ZeusSettings.shared.shouldUseOfficeTokenToLogin) {
                self.setValidity(newAuthState: .unauthenticated)
                return
            }
            warn("Failed to validate token, calling updateTokenAndValidityFromOfficeToken")
            self.attemptMicrosotLoginReAuth()
        }
    }
    
    func attemptMicrosotLoginReAuth() {
        self.setValidity(newAuthState: .loading)
        self.updateTokenAndValidityFromOfficeToken(officeToken: MicrosoftAuth.shared.token, setLoadingState: false) { success in
            if (success) {
                self.setValidity(newAuthState: .authentified)
                return
            }
            
            warn("attemptMicrosotLoginReAuth: failed to auth using saved token, trying to refresh token.")
            MicrosoftAuth.shared.refreshTokenUsingSavedId() { success2 in
                self.updateTokenAndValidityFromOfficeToken(officeToken: MicrosoftAuth.shared.token) { success3 in
                    if (success3) {
                        log("attemptMicrosotLoginReAuth: logged in")
                    } else {
                        warn("attemptMicrosotLoginReAuth: failed.")
                    }
                }
            }
        }
    }
    
    func updateTokenAndValidityFromOfficeToken(officeToken: String?, setLoadingState: Bool = true, completion: @escaping (Bool) -> Void = { _ in }) {
        // 2 steps in grabbing the token:
        // 1 - login w office and get the #access_token= value in the url
        // 2 - call a post to https://zeus.ionis-it.com/api/User/OfficeLogin w {"accessToken":"TOKEN"} and you'll get back the token used for authorization
        // this does the 2nd step. and calls updateValidityFromToken just to be sure
        if (officeToken == nil || officeToken!.isEmpty) {
            warn("officeToken is nil or empty, returning.")
            if (setLoadingState) { setValidity(newAuthState: AuthState.unauthenticated) }
            completion(false)
            return
        }
        
        if (setLoadingState) { setValidity(newAuthState: AuthState.loading) }
        let json: [String: String] = ["accessToken": officeToken!]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = NSURL(string: "https://zeus.ionis-it.com/api/User/OfficeLogin")
        var request = URLRequest(url: url! as URL, cachePolicy: .reloadIgnoringLocalCacheData)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            guard let res = response as? HTTPURLResponse else {
                warn("failed at HTTPURLResponse step")
                if (setLoadingState) { self.setValidity(newAuthState: AuthState.unauthenticated) }
                completion(false)
                return
            }
//            log("res: \(String(describing: res))")
//            log("Response: \(String(describing: response))")
            
            guard res.statusCode == 200 else {
                warn("failed at statuscode step: \(res.statusCode)")
                if (setLoadingState) { self.setValidity(newAuthState: AuthState.unauthenticated) }
                completion(false)
                return
            }
            
            guard let outputToken = String(data: data!, encoding: .utf8) else {
                warn("failed at outputToken step")
                if (setLoadingState) { self.setValidity(newAuthState: AuthState.unauthenticated) }
                completion(false)
                return
            }
            
            log("Updating !")
            DispatchQueue.main.async {
                self.token = "Bearer \(outputToken)"
//                log(self.token!)
//                self.updateValidityFromToken()
                if (setLoadingState) { self.setValidity(newAuthState: AuthState.authentified) }
                completion(true)
            }
        }
        dataTask.resume()
    }
    
    func updateValidityFromToken(setLoadingState: Bool = true, completion: @escaping (Bool) -> Void = { _ in }) {
        log("Checking token validity !")
        
        if (token == nil || token!.isEmpty) {
            warn("token is empty or nil")
            if (setLoadingState) { setValidity(newAuthState: AuthState.unauthenticated) }
            completion(false)
            return
        }
        
        if (setLoadingState) { setValidity(newAuthState: AuthState.loading) }
        
        
        // Step 1: Grab the token given by Office
        let url = NSURL(string: "https://zeus.ionis-it.com/api/group/hierarchy")
        var request = URLRequest(url: url! as URL, cachePolicy: .reloadIgnoringLocalCacheData)
//        debugLog(token!)
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let session = URLSession.shared
            
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            guard let res = response as? HTTPURLResponse else {
                warn("failed at HTTPURLResponse step")
                if (setLoadingState) { self.setValidity(newAuthState: AuthState.unauthenticated) }
                completion(false)
                return
            }

            guard res.statusCode == 200 else {
                warn("failed at statuscode step: \(res.statusCode)")
                if (setLoadingState) { self.setValidity(newAuthState: AuthState.unauthenticated) }
                completion(false)
                return
            }

            log("zeusauth updateValidityFromToken: success")
            if (setLoadingState) { self.setValidity(newAuthState: AuthState.authentified) }
            completion(true)
        }
        dataTask.resume()
    }

    func logout() {
        setValidity(newAuthState: AuthState.unauthenticated)
    }
}
