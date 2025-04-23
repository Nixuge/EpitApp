import SwiftUI
import Combine

// TODO: Better handle checks (eg no internet = no load)
// Unsure as to how I should handle Office login.
// Eg, have an OfficeAuthModel which lets you login to office,
// then for Zeus and Pegasus 2 options:
// - Login with Office (which uses the saved office token, no need to re open a webview)
// - Login manually (currently done)
// Not even sure if possible to implement, havent looked at pegasus yet.

// TODO: Save tokens to keychain? (unsure)


class PegasusAuthModel: ObservableObject {
    static let shared = PegasusAuthModel()

    @Published var authState: AuthState = AuthState.unauthenticated
    
    @Published var pegasusPhpSessId: String? {
        didSet {
            UserDefaults.standard.set(pegasusPhpSessId, forKey: "pegasusPhpSessId")
        }
    }

    init() {
        self.pegasusPhpSessId = UserDefaults.standard.string(forKey: "pegasusPhpSessId")
        self.updateValidityFromPhpSessId()
    }
    
    private func setValidity(newAuthState: AuthState) {
        DispatchQueue.main.async {
            self.authState = newAuthState
            if (newAuthState == AuthState.unauthenticated) {
                self.pegasusPhpSessId = nil;
                UserDefaults.standard.removeObject(forKey: "pegasusPhpSessId")
            }
        }
    }
    
    func setPhpSessId(newPhpSessId: String) {
        DispatchQueue.main.async {
            self.pegasusPhpSessId = newPhpSessId
            self.updateValidityFromPhpSessId()
        }
    }
    
    func updateValidityFromPhpSessId() {
        if (pegasusPhpSessId == nil || pegasusPhpSessId!.isEmpty) {
            setValidity(newAuthState: AuthState.unauthenticated)
            return
        }
        
        setValidity(newAuthState: AuthState.loading)
        log("Checking phpSessId validity !")
        
        // Step 1: Grab the token given by Office
        let url = NSURL(string: "https://prepa-epita.helvetius.net/pegasus/index.php")
        var request = URLRequest(url: url! as URL, cachePolicy: .reloadIgnoringLocalCacheData)

        request.setValue("PHPSESSID=\(pegasusPhpSessId!)", forHTTPHeaderField: "Cookie")
        request.httpMethod = "GET"
        let session = URLSession.shared
            
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            if let res = response as? HTTPURLResponse {
//                log("res: \(String(describing: res))")
//                log("Response: \(String(describing: response))")
                if (res.statusCode == 200) {
                    if let responseString = String(data: data!, encoding: .isoLatin1) {
                        if responseString.contains("<td class=\"logout item\">") {
                            self.setValidity(newAuthState: AuthState.authentified)
                            return
                        } else {
                            self.setValidity(newAuthState: AuthState.unauthenticated)
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

    func logout() {
        setValidity(newAuthState: AuthState.unauthenticated)
    }
}
