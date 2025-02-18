import SwiftUI
import Combine

// Example auth view model.
// Unused.

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    @Published var token: String? {
        didSet {
            UserDefaults.standard.set(token, forKey: "authToken")
        }
    }

    init() {
        self.token = UserDefaults.standard.string(forKey: "authToken")
        self.checkTokenValidity { isValid in
            self.isAuthenticated = isValid
        }
    }

    func checkTokenValidity(completion: @escaping (Bool) -> Void) {
        // Simulate token validation
        if token == "validToken" {
            completion(true)
        } else {
            completion(false)
        }
    }

    func logout() {
        isAuthenticated = false
        token = nil
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
}
