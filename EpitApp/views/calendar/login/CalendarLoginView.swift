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
                    print("Authentified, trying direct.")
                    zeusAuthModel.updateTokenAndValidityFromOfficeToken(officeToken: microsoftAuth.token) { success in
                        if success {
                            print("Direct login successful!")
                        } else {
                            print("Direct login failed, trying to refresh token.")
                            microsoftAuth.refreshTokenUsingSavedId { success in
                                if success {
                                    zeusAuthModel.updateTokenAndValidityFromOfficeToken(officeToken: self.microsoftAuth.token)
                                }
                            }
                        }
                    }
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
            }
            
            TextSeparator(text: "Or", sidePadding: 20)
            
            VStack {
                FancySheetButton(
                    text: "Login using in-app browser",
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
