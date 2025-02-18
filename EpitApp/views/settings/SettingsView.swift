//
//  SettingsView.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var zeusAuthModel: ZeusAuthModel

    var body: some View {
        VStack {
            Button(action: {
                authViewModel.logout()
            }) {
                Text("Logout from generic")
            }
            
            Button(action: {
                zeusAuthModel.logout()
            }) {
                Text("Logout from zeus")
            }
            .disabled(zeusAuthModel.authState != AuthState.authentified)
        }
   
    }
}
