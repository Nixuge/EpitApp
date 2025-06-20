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
    
    var isInitialLoginDone = false

    @Published var authState: AbsencesAuthState
    
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
    
    var isGuest: Bool { return token == "GUEST" }


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
    
    func guestLogin() {
        self.token = "GUEST"
        setValidity(newAuthState: .authentified)
    }
    
    func loginWithSaved(completion: @escaping (Bool) -> Void = { _ in }) {
        guard let user = self.user, let password = self.password else {
            self.authState = .failed
            return
        }
        
        login(username: user, password: password, completion: completion)
    }
    
    func login(username: String, password: String, completion: @escaping (Bool) -> Void = { _ in }) {
        if (authState == .loading) {
            warn("Already loading, returning...")
            completion(false)
            return
        }
        
        setValidity(newAuthState: .loading)
        
        self.user = username
        self.password = password
                
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
                warn("Failed absences login at HTTPURLResponse step")
                completion(false)
                return
            }
            guard res.statusCode == 200 else {
                self.setValidity(newAuthState: .failed)
                warn("Failed absences login at statuscode step: \(res.statusCode)")
                completion(false)
                return
            }
            guard let data = data else {
                self.setValidity(newAuthState: .failed)
                warn("Failed absences login at data unwrap step")
                completion(false)
                return
            }
            
            guard let authRes = try? JSONDecoder().decode(AuthResult.self, from: data) else {
                self.setValidity(newAuthState: .failed)
                warn("Failed absences login at json decoding step")
                completion(false)
                return
            }
        
            log("Done logging in.")
            log(authRes)
            self.token = authRes.access_token
            self.setValidity(newAuthState: .authentified)
            completion(true)
        }
        dataTask.resume()
    }
    
    func logout() {
        // TODO: Fix crash on logout when clearing cache IDK WHY since view shouldve changed.
        // EDIT: MAY BE BECAUSE OF ANIMATION
        // VERY DIRTY PATCH FOR NOW !!!
        DispatchQueue.main.async {
            self.authState = .unauthenticated
            self.token = nil
        }
//        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(Int(1)))) {
//            AbsencesCache.shared.clear()
//        }
    }
}
