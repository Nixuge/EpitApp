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
    
    @ObservedObject var zeusSelectedIdCache = SelectedIdCache.shared
    
    var body: some View {
        List {
            Section(header: Text("General (office)")) {
                SettingsButton(
                    text: "Logout from Office",
                    color: .red,
                    isDisabled: !microsoftAuth.isAuthenticated
                ) {
                    microsoftAuth.logout()
                }
                SettingsButton(
                    text: "Login to Office",
                    color: .red,
                    isDisabled: microsoftAuth.isAuthenticated
                ) {
                    microsoftAuth.login()
                }
            
            }
            Section(header: Text("Zeus")) {
                SettingsButton(
                    text: "Logout from Zeus",
                    color: .orange,
                    isDisabled: zeusAuthModel.authState != .authentified
                ) {
                    zeusAuthModel.logout()
                    ZeusSettings.shared.shouldUseOfficeTokenToLogin = false
                    CourseCache.shared.clearAllCourses()
                }
                SettingsButton(
                    text: "Reset class Id for Zeus",
                    color: .orange,
                    isDisabled: zeusSelectedIdCache.id == nil
                ) {
                    zeusSelectedIdCache.id = nil
                }
                
            }
            Section(header: Text("Pegasus")) {
                SettingsButton(
                    text: "Logout from Pegasus",
                    color: .pegasusBackgroundColor,
                    isDisabled: pegasusAuthModel.authState != .authentified
                ) {
                    pegasusAuthModel.logout()
                }
            }
            Section(header: Text("Absences")) {
                SettingsButton(
                    text: "Logout from Absences",
                    color: .green,
                    isDisabled: absencesAuth.authState != .authentified
                ) {
                    absencesAuth.logout()
                    AbsencesCache.shared.clear()
                }
            }
            
            Section(header: Text("Updates")) {
                if (Updater.shared.upToDate == nil) {
                    SettingsButton(
                        text: "Loading update status...",
                        isDisabled: true,
                        isLoading: true,
                    ) { }
                } else if (!Updater.shared.upToDate!) {
                    SettingsButton(
                        text: "Update available !",
                        color: .cyan,
                    ) { Updater.shared.updateAlertShown = true }
                } else {
                    SettingsButton(text: "Up to date !", isDisabled: true) {}
                }
                Text("Version \(Updater.shared.appVersion)")
            }
        }
    }
}
