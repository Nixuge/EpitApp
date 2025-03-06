//
//  TestMicrosoftAuth.swift
//  EpitApp
//
//  Created by Quenting on 06/03/2025.
//

import MSAL


let kClientID = "87e9c2da-3a91-4d55-bfc0-8125ee3b5520"
let kAuthority = "https://login.microsoftonline.com/3534b3d7-316c-4bc9-9ede-605c860f49d2"
let kRedirectUri = "msauth.me.nixuge.epitapp://auth"
let kScopes: [String] = ["User.Read"]

class MicrosoftAuth: ObservableObject {
    static let shared = MicrosoftAuth()
    
    @Published var isAuthenticated: Bool = false
    
    var token: String?
    
    var applicationContext: MSALPublicClientApplication?
    let accountName = "Micro$oft"
    
    init() {
        do {
            let config = MSALPublicClientApplicationConfig(clientId: kClientID)
            self.applicationContext = try MSALPublicClientApplication(configuration: config)
            print("Application context initialized successfully")
            if let retrievedToken = KeychainHelper.shared.retrieveToken(accountName: accountName) {
                print("Token retrieved from Keychain")
                self.isAuthenticated = true
                self.token = retrievedToken
            }
        } catch {
            print("Failed to initialize application context: \(error)")
        }
    }
    
    func login(completion: @escaping (Bool) -> Void = { _ in }) {
        guard let view = getRootViewController() else {
            print("Couldn't get root view controller for Microsoft auth !")
            completion(false)
            return
        }
        login(from: view, completion: completion)
    }
    
    func login(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        let webviewParameters = MSALWebviewParameters(authPresentationViewController: viewController)
        let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webviewParameters)
        self.applicationContext?.acquireToken(with: parameters) { (result, error) in
            if let error = error {
                print("Could not acquire token: \(error)")
                completion(false)
                return
            }

            guard let result = result else {
                print("Result is nil")
                completion(false)
                return
            }

            print("Access token: \(result.accessToken)")
            KeychainHelper.shared.saveToken(result.accessToken, accountName: self.accountName)
            print("Saved token.")
            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.token = result.accessToken
                completion(true)
            }
        }
    }
    
    func logout() {
        KeychainHelper.shared.deleteToken(accountName: self.accountName)
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.token = nil
        }
    }
}
