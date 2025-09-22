//
//  ZeusAppApp.swift
//  ZeusApp
//
//  Created by Quenting on 03/09/2024.
//

import SwiftUI
import MSAL

@main
struct EpitApp: App {
    @ObservedObject var updater = Updater.shared

    var body: some Scene {
        WindowGroup {
            ContentView().tint(.orange)
                .onOpenURL { url in
                // sourceApplication hardcoded for now.
                // TODO: Find a way in SwiftUI to NOT HARDCODE IT LIKE THAT.
                // AppDellegate's application function DOES NOT GET CALLED
                MSALPublicClientApplication.handleMSALResponse(
                    url,
                    sourceApplication: "com.microsoft.azureauthenticator"
                )}
                .onAppear { Task {
                    await Updater.shared.grabUpdateVersions()
                }}
                .alert(isPresented: $updater.updateAlertShown) {
                    Alert(title: Text(updater.getUpdatePopupTitle()), message: Text(updater.getUpdatePopupString()), dismissButton: .default(Text("Got it!")))
                }
        }
    }
}
