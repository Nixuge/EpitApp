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
            FancyButton(text: "Login using Office (recommended)") {
                DispatchQueue.main.async {
                    ZeusSettings.shared.shouldUseOfficeTokenToLogin = true
                }
                if (microsoftAuth.isAuthenticated) {
                    log("Authentified, trying direct.")
                    
                    zeusAuthModel.attemptMicrosotLoginReAuth()
                } else {
                    microsoftAuth.login { success in
                        if success {
                            log("Login successful!")
                           zeusAuthModel.updateTokenAndValidityFromOfficeToken(officeToken: microsoftAuth.token)
                       } else {
                           log("Login failed!")
                       }
                    }
                }
            }
            
            TextSeparator(text: "Or", sidePadding: 20)
            
            VStack {
                FancySheetButton(
                    label: { Text("Login using in-app browser") },
                    isPresented: $showWebView,
                    action: {
                        DispatchQueue.main.async {
                            ZeusSettings.shared.shouldUseOfficeTokenToLogin = false
                        }
                        showWebView = true
                    },
                    sheetContent: {
                        CalendarLoginWebView(url: loginURL, isPresented: $showWebView)
                    })
                
                FancyButton(text: "Logout from browser") {
                    deleteAllWebKitCookies()
                }
            }
        }
    }
}
