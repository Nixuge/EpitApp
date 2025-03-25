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
        // - First try and login w the Zeus token
        // - If that doesn't work, try and relog with the Microsoft token.
        // - If that STILL doesn't work, try to get a new Microsoft token silently and login w that.
        // Otherwise just let the user relog manually.
        self.updateValidityFromToken() { success1 in
            if (success1) { return }
            if (!ZeusSettings.shared.shouldUseOfficeTokenToLogin) { return }
            
            print("Failed to validate token, calling updateTokenAndValidityFromOfficeToken")
            self.updateTokenAndValidityFromOfficeToken(officeToken: MicrosoftAuth.shared.token) { success2 in
                if (success2) { return }
                print("Failed to validate token AGAIN, calling MicrosoftAuth.shared.refreshToken")
                MicrosoftAuth.shared.refreshTokenUsingSavedId() { success3 in
                    self.updateTokenAndValidityFromOfficeToken(officeToken: MicrosoftAuth.shared.token) { success4 in
                        if (success4) {
                            print("FINALLY logged in")
                        } else {
                            print("All attempts at relogging automatically failed, you'll have to do it yourself")
                        }
                    }
                }
            }
        
        }
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
    
    func updateTokenAndValidityFromOfficeToken(officeToken: String?, completion: @escaping (Bool) -> Void = { _ in }) {
        // 2 steps in grabbing the token:
        // 1 - login w office and get the #access_token= value in the url
        // 2 - call a post to https://zeus.ionis-it.com/api/User/OfficeLogin w {"accessToken":"TOKEN"} and you'll get back the token used for authorization
        // this does the 2nd step. and calls updateValidityFromToken just to be sure
        if (officeToken == nil || officeToken!.isEmpty) {
            print("officeToken is nil or empty, returning.")
            setValidity(newAuthState: AuthState.unauthenticated)
            completion(false)
            return
        }
        
        setValidity(newAuthState: AuthState.loading)
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
                print("zeusauth updateTokenAndValidityFromOfficeToken: failed at HTTPURLResponse step")
                self.setValidity(newAuthState: AuthState.unauthenticated)
                completion(false)
                return
            }
//            print("res: \(String(describing: res))")
//            print("Response: \(String(describing: response))")
            
            guard res.statusCode == 200 else {
                print("zeusauth updateTokenAndValidityFromOfficeToken: failed at statuscode step: \(res.statusCode)")
                self.setValidity(newAuthState: AuthState.unauthenticated)
                completion(false)
                return
            }
            
            guard let outputToken = String(data: data!, encoding: .utf8) else {
                print("zeusauth updateTokenAndValidityFromOfficeToken: failed at outputToken step")
                self.setValidity(newAuthState: AuthState.unauthenticated)
                completion(false)
                return
            }
            
            print("Updating !")
            DispatchQueue.main.async {
                self.token = "Bearer \(outputToken)"
//                print(self.token!)
//                self.updateValidityFromToken()
                self.setValidity(newAuthState: AuthState.authentified)
                completion(true)
            }
        }
        dataTask.resume()
    }
    
    func updateValidityFromToken(completion: @escaping (Bool) -> Void = { _ in }) {
        print("Checking token validity !")
        
        if (token == nil || token!.isEmpty) {
            print("zeusauth updateValidityFromToken: token is empty or nil")
            setValidity(newAuthState: AuthState.unauthenticated)
            completion(false)
            return
        }
        
        setValidity(newAuthState: AuthState.loading)
        
        
        // Step 1: Grab the token given by Office
        let url = NSURL(string: "https://zeus.ionis-it.com/api/group/hierarchy")
        var request = URLRequest(url: url! as URL, cachePolicy: .reloadIgnoringLocalCacheData)
//        debugPrint(token!)
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let session = URLSession.shared
            
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            guard let res = response as? HTTPURLResponse else {
                print("zeusauth updateValidityFromToken: failed at HTTPURLResponse step")
                self.setValidity(newAuthState: AuthState.unauthenticated)
                completion(false)
                return
            }
//            print("res: \(String(describing: res))")
//            print("Response: \(String(describing: response))")
            
            guard res.statusCode == 200 else {
                print("zeusauth updateValidityFromToken: failed at statuscode step: \(res.statusCode)")
                self.setValidity(newAuthState: AuthState.unauthenticated)
                completion(false)
                return
            }
            
            print("zeusauth updateValidityFromToken: success")
            self.setValidity(newAuthState: AuthState.authentified)
            completion(true)
        }
        dataTask.resume()
    }

    func logout() {
        setValidity(newAuthState: AuthState.unauthenticated)
    }
}
