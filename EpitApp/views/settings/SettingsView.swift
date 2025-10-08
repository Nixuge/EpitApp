//
//  SettingsView.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI


struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme

    @ObservedObject var zeusAuthModel = ZeusAuthModel.shared
    @ObservedObject var pegasusAuthModel = PegasusAuthModel.shared
    @ObservedObject var microsoftAuth = MicrosoftAuth.shared
    @ObservedObject var absencesAuth = AbsencesAuthModel.shared
    
    @ObservedObject var zeusSelectedIdCache = SelectedIdCache.shared
    
    @State private var zeusHideText: String = ZeusSettings.shared.hideClassesEndingWith
    @State private var isShowHideClassesInfoAlertShown: Bool = false

    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Office")) {
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
                    HStack {
                        TextField(
                            "Hide classes ending with",
                            text: $zeusHideText
                        )
                        Spacer()
                        Button(action: showHideClassesInfo) {
                            Label("", systemImage: "exclamationmark.circle")
                                .foregroundStyle(.orange)
                        }
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
                
                Section(header: Text("About")) {
                    NavigationLink(destination: MoreInfoView()) {
                        SettingsButton(text: "Support", color: colorScheme == .dark ? .white : .black) { }
                    }
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
            .navigationTitle("Settings")
        }
        .alert(isPresented: $isShowHideClassesInfoAlertShown) {
            Alert(title: Text("Hide classes help"), message: Text("This functionality is meant to be used for classes with multiple groups.\nEg if you're in group 2 of class 2, you want to show classes that end with 2.2 but hide the ones ending with 2.1.\nIn that case, you just have to put '2.1' in this field and it'll hide the classes of the other group."), dismissButton: .default(Text("Got it")))
        }.onChange(of: zeusHideText) { newText in
            ZeusSettings.shared.hideClassesEndingWith = newText
        }
    }
    
    
    private func showHideClassesInfo() {
        isShowHideClassesInfoAlertShown = true;
    }
}
