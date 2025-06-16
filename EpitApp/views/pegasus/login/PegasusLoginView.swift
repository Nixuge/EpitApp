//
//  LoginView.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI


struct PegasusLoginView: View {
    @ObservedObject var pegasusAuthModel: PegasusAuthModel
    @State private var showWebView = false
    let loginURL = URL(string: "https://prepa-epita.helvetius.net/pegasus/index.php")!

    var body: some View {
        VStack {
            FancySheetButton(
                label: { Text("Login using in-app browser") },
                color: .pegasusBackgroundColor,
                isPresented: $showWebView,
                action: {
                    DispatchQueue.main.async {
                        ZeusSettings.shared.shouldUseOfficeTokenToLogin = false
                    }
                    showWebView = true
                },
                sheetContent: {
                    PegasusLoginWebView(pegasusAuthModel: pegasusAuthModel, url: loginURL, isPresented: $showWebView)
                })
            
            FancyButton(text: "Logout from browser", color: .pegasusBackgroundColor) {
                deleteAllWebKitCookies()
            }
            
            TextSeparator(text: "Or", sidePadding: 20)
     
            FancyButton(text: "Guest access", color: .pegasusBackgroundColor) {
                pegasusAuthModel.guestLogin()
            }
        }
    }
}
