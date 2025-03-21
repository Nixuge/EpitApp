//
//  NotesView.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI

struct NotesView: View {
    @ObservedObject var pegasusAuthModel = PegasusAuthModel.shared
    
    var body: some View {
        VStack {
            if pegasusAuthModel.authState == .authentified{
                LoadedNotesView(pegasusAuthModel: pegasusAuthModel, pegasusParser: PegasusParser(pegasusAuthModel: pegasusAuthModel))
            } else if pegasusAuthModel.authState == .loading {
                VStack {
                    Text("Logging in...")
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .pegasusTextColor))
                }
            } else {
                PegasusLoginView(pegasusAuthModel: pegasusAuthModel)
            }
        }

    }
    
 
}
