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
        self.updateValidityFromToken()
        if (authState == AuthState.unauthenticated && ZeusSettings.shared.shouldUseOfficeTokenToLogin) {
            // Attempt to re get token from office token if failed w normal token
            debugPrint("Seems to be unauthentified after updateValidityFromToken, calling updateTokenAndValidityFromOfficeToken")
            self.updateTokenAndValidityFromOfficeToken(officeToken: MicrosoftAuth.shared.token)
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
    
    func updateTokenAndValidityFromOfficeToken(officeToken: String?) {
        // 2 steps in grabbing the token:
        // 1 - login w office and get the #access_token= value in the url
        // 2 - call a post to https://zeus.ionis-it.com/api/User/OfficeLogin w {"accessToken":"TOKEN"} and you'll get back the token used for authorization
        // this does the 2nd step. and calls updateValidityFromToken just to be sure
        if (officeToken == nil || officeToken!.isEmpty) {
            setValidity(newAuthState: AuthState.unauthenticated)
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
            if let res = response as? HTTPURLResponse {
//                print("res: \(String(describing: res))")
//                print("Response: \(String(describing: response))")
                if (res.statusCode == 200) {
                    if let outputToken = String(data: data!, encoding: .utf8) {
                        DispatchQueue.main.async {
                            self.token = "Bearer \(outputToken)"
//                            print(self.token!)
                            self.updateValidityFromToken()
                        }
                    } else {
                        self.setValidity(newAuthState: AuthState.unauthenticated)
                    }

                } else {
                    self.setValidity(newAuthState: AuthState.unauthenticated)
                }
            } else {
                self.setValidity(newAuthState: AuthState.unauthenticated)
            }
        }
        dataTask.resume()
    }
    
    func updateValidityFromToken() {
        if (token == nil || token!.isEmpty) {
            setValidity(newAuthState: AuthState.unauthenticated)
            return
        }
        
        setValidity(newAuthState: AuthState.loading)
        debugPrint("Checking token validity !")
        
        // Step 1: Grab the token given by Office
        let url = NSURL(string: "https://zeus.ionis-it.com/api/group/hierarchy")
        var request = URLRequest(url: url! as URL, cachePolicy: .reloadIgnoringLocalCacheData)
//        debugPrint(token!)
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let session = URLSession.shared
            
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if let res = response as? HTTPURLResponse {
//                print("res: \(String(describing: res))")
//                print("Response: \(String(describing: response))")
                if (res.statusCode == 200) {
                    self.setValidity(newAuthState: AuthState.authentified)
                } else {
                    self.setValidity(newAuthState: AuthState.unauthenticated)
                }
            } else {
//                print("Error: \(String(describing: error))")
                self.setValidity(newAuthState: AuthState.unauthenticated)
            }
        }
        dataTask.resume()
    }

    func logout() {
        setValidity(newAuthState: AuthState.unauthenticated)
    }
}
