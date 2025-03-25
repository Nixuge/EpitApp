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
    @ObservedObject var absencesAuth = AbsencesAuthModel.shared

    
    var body: some View {
        VStack(spacing: 50) {
            VStack(spacing: 15) {
                FancyButton(
                    text: "Logout from Zeus",
                    isDisabled: zeusAuthModel.authState != .authentified
                ) {
                    zeusAuthModel.logout()
                    ZeusSettings.shared.shouldUseOfficeTokenToLogin = false
                }
                
                FancyButton(
                    text: "Logout from Pegasus",
                    color: .pegasusBackgroundColor,
                    isDisabled: pegasusAuthModel.authState != .authentified
                ) {
                    pegasusAuthModel.logout()
                }
                
                FancyButton(
                    text: "Logout from Absences",
                    color: .green,
                    isDisabled: absencesAuth.authState != .authentified
                ) {
                    absencesAuth.logout()
                }
                
                FancyButton(
                    text: "Logout from Office",
                    color: .red,
                    isDisabled: !microsoftAuth.isAuthenticated
                ) {
                    microsoftAuth.logout()
                }
            }
            
            FancyButton(
                text: "Login to Office",
                color: .red,
                isDisabled: microsoftAuth.isAuthenticated
            ) {
                microsoftAuth.login()
            }
        }
    }
}
