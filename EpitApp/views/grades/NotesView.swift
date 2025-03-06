//
//  NotesView.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI

struct NotesView: View {
    @ObservedObject var pegasusAuthModel = PegasusAuthModel.shared
    
    init() {
        setupNavigationBarAppearance()
    }

    var body: some View {
        VStack {
            if pegasusAuthModel.authState == .authentified{
                LoadedNotesView(pegasusAuthModel: pegasusAuthModel, pegasusParser: PegasusParser(pegasusAuthModel: pegasusAuthModel))
            } else if pegasusAuthModel.authState == .loading {
                VStack {
                    Text("Logging in...")
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .orange))
                }
            } else {
                PegasusLoginView(pegasusAuthModel: pegasusAuthModel)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Notes")
                    .font(.headline) // Use a smaller font size
            }
        }
    }
    
    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
