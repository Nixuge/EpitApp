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
    var body: some Scene {
        WindowGroup {
            ContentView().tint(.orange).onOpenURL { url in
                // sourceApplication hardcoded for now.
                // TODO: Find a way in SwiftUI to NOT HARDCODE IT LIKE THAT.
                MSALPublicClientApplication.handleMSALResponse(
                    url,
                    sourceApplication: "com.microsoft.azureauthenticator"
                )
            }
        }
    }
}
