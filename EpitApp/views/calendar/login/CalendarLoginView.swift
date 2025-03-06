//
//  LoginView.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI


struct CalendarLoginView: View {
    @ObservedObject var microsoftAuth = MicrosoftAuth.shared
    @ObservedObject var zeusAuthModel = ZeusAuthModel.shared
    @State private var showWebView = false
    let loginURL = URL(string: "https://zeus.ionis-it.com/login")!

    var body: some View {
        VStack(spacing: 40) {
            Button(action: {
                DispatchQueue.main.async {
                    ZeusSettings.shared.shouldUseOfficeTokenToLogin = true
                }
                if (microsoftAuth.isAuthenticated) {
                    zeusAuthModel.updateTokenAndValidityFromOfficeToken(officeToken: microsoftAuth.token)
                } else {
                    microsoftAuth.login { success in
                        if success {
                           print("Login successful!")
                           zeusAuthModel.updateTokenAndValidityFromOfficeToken(officeToken: microsoftAuth.token)
                       } else {
                           print("Login failed!")
                       }
                    }
                }
            }) {
                Text("Login using Office (recommended)")
                    .font(.headline)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            TextSeparator(text: "Or", sidePadding: 20)
            
            Button(action: {
                DispatchQueue.main.async {
                    ZeusSettings.shared.shouldUseOfficeTokenToLogin = false
                }
                showWebView = true
            }) {
                Text("Login manually")
                    .font(.headline)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $showWebView) {
                CalendarLoginWebView(url: loginURL, isPresented: $showWebView)
            }
        }
    }
}
