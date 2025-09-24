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
        VStack {
            Text("Installation instructions")
                .font(.largeTitle)
            
            Text("Install the shortcuts app (https://apps.apple.com/fr/app/shortcuts/id1462947752?l=en-GB)")
            Text("Add the shortcut (...)")
            Text("All done !")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
