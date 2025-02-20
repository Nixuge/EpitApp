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
    @ObservedObject var pegasusAuthModel: PegasusAuthModel
    
    var body: some View {
        VStack(spacing: 10) {
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
            .disabled(zeusAuthModel.authState != .authentified)
            
            Button(action: {
                pegasusAuthModel.logout()
            }) {
                Text("Logout from Pegasus")
            }
            .disabled(pegasusAuthModel.authState != .authentified)
        }
   

    }
}
