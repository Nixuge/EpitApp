//
//  MoreInfoView.swift
//  EpitApp
//
//  Created by Quenting on 23/09/2025.
//

import SwiftUI

struct MoreInfoView: View {
    var body: some View {
        Text("Dev par le grand nixu")
            .font(.largeTitle)
            .padding(.top, 20)
        
        
        
        List {
            Section(header: Text("Contact (bug, suggestion, ...)")) {
                SettingsButton(text: "Telegram", color: Color.init(hex: "#00aaff")) {
                    UIApplication.shared.open(URL(string: "https://t.me/Nixuge")!)
                }
                SettingsButton(text: "Discord", color: Color.init(hex: "#5865F2")) {
                    UIApplication.shared.open(URL(string: "https://discord.com/users/784062518901473351")!)
                }
                SettingsButton(text: "Email", color: Color.init(hex: "#ffffff")) {
                    UIApplication.shared.open(URL(string: "mailto:epitapp@nixuge.me")!)
                }
            }
            
            Section(header: Text("Other stuff")) {
                SettingsButton(text: "Source Code", color: Color.init(hex: "#586673")) {
                    UIApplication.shared.open(URL(string: "https://github.com/Nixuge/epitapp")!)
                }
                SettingsButton(text: "nixuge.me", color: Color.init(hex: "#ffffff")) {
                    UIApplication.shared.open(URL(string: "https://nixuge.me")!)
                }
            }
        }
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline) // forces inline
    }
}
