//
//  SettingsView.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI


struct SettingsView: View {
    @ObservedObject var zeusAuthModel = ZeusAuthModel.shared
    @ObservedObject var pegasusAuthModel = PegasusAuthModel.shared
    @ObservedObject var microsoftAuth = MicrosoftAuth.shared
    
    var body: some View {
        VStack(spacing: 10) {
            Button(action: {
                zeusAuthModel.logout()
            }) {
                Text("Logout from zeus")
            }
            .disabled(zeusAuthModel.authState != .authentified)
            
            Button(action: {
                pegasusAuthModel.logout()
            }) {
                Text("Logout from Pegasus")
            }
            .disabled(pegasusAuthModel.authState != .authentified)
            
            Button(action: {
                microsoftAuth.login()
            }) {
                Text("Login to Office")
            }
            .disabled(microsoftAuth.isAuthenticated)
            
            Button(action: {
                microsoftAuth.logout()
            }) {
                Text("Logout from Office")
            }
            .disabled(!microsoftAuth.isAuthenticated)
            
            Button(action: {
                let serviceURL = "https://prepa-epita.helvetius.net/pegasus/index.php"
                makeAuthenticatedRequest(to: serviceURL)
            }) {
                Text("THE TEST")
            }
        }
    }
}
