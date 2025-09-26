//
//  InstallShortcutView.swift
//  EpitApp
//
//  Created by Quenting on 24/09/2025.
//


import SwiftUI

struct InstallShortcutView: View {
    @Binding var isPresented: Bool
    
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Installation instructions")
                .font(.largeTitle)
                .padding(.top, 50)
            
            Text("You might need to reinstall the shortcut if its version doesn't match the one displayed below.")
                .font(.caption)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            
            Text("Current shortcut version: 1.0")
                .font(.caption)
                .foregroundStyle(.gray)
            
            Spacer()
            Button("Install the shortcuts app (tap)") {
                UIApplication.shared.open(URL(string: "https://apps.apple.com/fr/app/shortcuts/id1462947752?l=en-GB")!)
            }
            
            Button("Add the shortcut (tap)") {
                UIApplication.shared.open(URL(string: "https://www.icloud.com/shortcuts/845ac8f62e9844e6a06a5a7eb8c79150")!)
            }
            
            Text("All done !")
            Text("If the shortcuts asks for some permission while running for the first time, tap 'Always Allow' and it shouldn't bother you anymore")
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
