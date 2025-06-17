//
//  AbsencesLoginView.swift
//  EpitApp
//
//  Created by Quenting on 20/03/2025.
//

import SwiftUI

struct AbsencesLoginView: View {
    @State private var loginText: String = AbsencesAuthModel.shared.user ?? ""
    @State private var passwordText: String = AbsencesAuthModel.shared.password ?? ""
    
    @ObservedObject var authModel: AbsencesAuthModel = AbsencesAuthModel.shared

    var body: some View {
        if (authModel.authState == .loading) {
            ProgressView()
        } else {
            VStack {
                VStack(spacing: 30) {
                    VStack(spacing: 15) {
                        FancyTextInput(text: $loginText, placeholder: "Login")
                        
                        FancyTextInput(text: $passwordText, placeholder: "Password")
                    }
                    
                    FancyButton(text: "Login", color: .green) {
                        authModel.login(username: loginText, password: passwordText) { success in
                            log("Absences login success: \(success)")
                            if (success) {
                                AbsencesCache.shared.grabNewContent()
                            }
                        }
                    }
                    
                    if (authModel.authState == .failed) {
                        Text("Failed to login.")
                            .foregroundStyle(.red)
                            .padding(.bottom, 20)
                    }
                }
                    
                TextSeparator(text: "Or", sidePadding: 20)
                
                FancyButton(text: "Guest access", color: .green) {
                    authModel.guestLogin()
                    AbsencesCache.shared.grabNewContent()
                }
            }
            .padding(5)
        }
    }
}
