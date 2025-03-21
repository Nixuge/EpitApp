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
            VStack(spacing: 30) {
                VStack(spacing: 15) {
                    FancyTextInput(text: $loginText, placeholder: "Login")
                    
                    FancyTextInput(text: $passwordText, placeholder: "Password")
                }
                
                FancyButton(text: "Login", color: .green) {
                    AbsencesAuthModel.shared.login(username: loginText, password: passwordText)
                }
                
                if (authModel.authState == .failed) {
                    Text("Failed to login.")
                        .foregroundStyle(.red)
                } else {
                    Text("" )
                }
            }
        }
    }
}
