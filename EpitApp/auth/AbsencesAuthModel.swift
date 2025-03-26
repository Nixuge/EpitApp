//
//  AbsencesCache.swift
//  EpitApp
//
//  Created by Quenting on 20/03/2025.
//

import SwiftUI
import Combine

enum AbsencesAuthState {
    case unauthenticated, loading, authentified, failed
}

struct AuthUser: Decodable {
    let id: Int
    let login: String
    let firstname: String
    let lastname: String
    let roleName: String
    let regionId: Int
    let regionName: String
}

struct AuthResult: Decodable {
    let access_token: String
    let expires_in: Int
    let user: AuthUser
}

class AbsencesAuthModel: ObservableObject {
    static let shared = AbsencesAuthModel()
    
    @Published var authState: AbsencesAuthState = .unauthenticated
    
    @Published var token: String? {
        didSet {
            KeychainHelper.shared.saveValue(token, key: "absencesToken")
        }
    }
    
    @Published var user: String? {
        didSet {
            KeychainHelper.shared.saveValue(user, key: "absencesUser")
        }
    }
    @Published var password: String? {
        didSet {
            KeychainHelper.shared.saveValue(password, key: "absencesPassword")
        }
    }

    init() {
        self.authState = .unauthenticated
        
        self.token = KeychainHelper.shared.retrieveValue(key: "absencesToken")
        self.user = KeychainHelper.shared.retrieveValue(key: "absencesUser")
        self.password = KeychainHelper.shared.retrieveValue(key: "absencesPassword")
    }
    
    func setValidity(newAuthState: AbsencesAuthState) {
        DispatchQueue.main.async {
            self.authState = newAuthState
        }
    }
    
    func loginWithSaved() {
        guard let user = self.user, let password = self.password else {
            self.authState = .failed
            return
        }
        
        login(username: user, password: password)
    }
    
    func login(username: String, password: String) {
        if (authState == .loading) {
            print("Already loading, returning...")
            return
        }
        setValidity(newAuthState: .loading)
        let json: [String: String] = ["login": username, "password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = NSURL(string: "https://absences.epita.net/api/Users/login")
        var request = URLRequest(url: url! as URL, cachePolicy: .reloadIgnoringLocalCacheData)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            guard let res = response as? HTTPURLResponse else {
                self.setValidity(newAuthState: .failed)
                print("Failed absences login at HTTPURLResponse step")
                return
            }
            guard res.statusCode == 200 else {
                self.setValidity(newAuthState: .failed)
                print("Failed absences login at statuscode step: \(res.statusCode)")
                return
            }
            guard let data = data else {
                self.setValidity(newAuthState: .failed)
                print("Failed absences login at data unwrap step")
                return
            }
            
            guard let authRes = try? JSONDecoder().decode(AuthResult.self, from: data) else {
                self.setValidity(newAuthState: .failed)
                print("Failed absences login at json decoding step")
                return
            }
        
            print("Done logging in.")
            print(authRes)
            self.user = username
            self.password = password
            self.token = authRes.access_token
            self.setValidity(newAuthState: .authentified)
        }
        dataTask.resume()
    }
    
    func logout() {
        setValidity(newAuthState: .unauthenticated)
        self.token = nil
    }
}
