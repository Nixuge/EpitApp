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
    static let keyToken = "Micro$oftToken"
    static let keyId = "Micro$oftIdentifier"
    static let shared = MicrosoftAuth()
    
    @Published var isAuthenticated: Bool = false
    
    var token: String?
    
    var applicationContext: MSALPublicClientApplication?
    
    init() {
        do {
            let config = MSALPublicClientApplicationConfig(clientId: kClientID)
            self.applicationContext = try MSALPublicClientApplication(configuration: config)
            print("Application context initialized successfully")
            if let retrievedToken = KeychainHelper.shared.retrieveValue(key: MicrosoftAuth.keyToken),
               let retrievedIdentifier = KeychainHelper.shared.retrieveValue(key: MicrosoftAuth.keyId) {
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
//            self.applicationContext.accou
//            let paramsSilent = MSALSilentTokenParameters(scopes: kScopes, account: )
//            self.applicationContext?.acquireTokenSilent(with: parameters) { (result, error) in
//                 
//            }

            guard let result = result else {
                print("Result is nil")
                completion(false)
                return
            }
            
            print("Access token: \(result.accessToken)")
            print("Identifier: \(result.account.identifier ?? "nil")")
            KeychainHelper.shared.saveValue(result.accessToken, key: MicrosoftAuth.keyToken)
            KeychainHelper.shared.saveValue(result.account.identifier, key: MicrosoftAuth.keyId)

            print("Saved token.")
            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.token = result.accessToken
                completion(true)
            }
        }
    }
    
    func refreshTokenUsingSavedId(completion: @escaping (Bool) -> Void = {_ in }) {
        print("Trying to refresh Microsoft auth token using saved id.")
        guard let accountId = KeychainHelper.shared.retrieveValue(key: MicrosoftAuth.keyId) else {
            print("refreshTokenUsingSavedId: no/empty saved id.")
            completion(false)
            return
        }
        // Code inspired by https://github.com/AzureAD/microsoft-authentication-library-for-objc/issues/923
        let msalParameters = MSALAccountEnumerationParameters()
//            msalParameters.completionBlockQueue = DispatchQueue.main

        self.applicationContext?.accountsFromDevice(for: msalParameters) { accounts, error in
            if let error = error {
                print("Couldn't query current account with error: \(error)")
                completion(false)
                return
            }
            guard let accounts = accounts else {
                print("No accounts saved in device")
                completion(false)
                return
            }
            let foundAccTemp = accounts.first { $0.identifier == accountId }
            guard let foundAccount = foundAccTemp else {
                print("Account with id \(accountId) not found in saved device accounts")
                completion(false)
                return
            }
            
            
            let parameters = MSALSilentTokenParameters(scopes: kScopes, account: foundAccount)
            self.applicationContext?.acquireTokenSilent(with: parameters) { (result, error) in
                if let error = error {
                    print("refreshTokenUsingSavedId: Could not acquire token: \(error)")
                    completion(false)
                    return
                }

                guard let result = result else {
                    print("refreshTokenUsingSavedId: Result is nil")
                    completion(false)
                    return
                }
                
                print("Access token: \(result.accessToken)")
                print("Identifier: \(result.account.identifier ?? "nil")")
                KeychainHelper.shared.saveValue(result.accessToken, key: MicrosoftAuth.keyToken)
                KeychainHelper.shared.saveValue(result.account.identifier, key: MicrosoftAuth.keyId)

                print("Saved token.")
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    self.token = result.accessToken
                    completion(true)
                }
            }
        }
    }
    
    func logout() {
        KeychainHelper.shared.deleteToken(accountName: MicrosoftAuth.keyToken)
        KeychainHelper.shared.deleteToken(accountName: MicrosoftAuth.keyId)

        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.token = nil
        }
    }
}
