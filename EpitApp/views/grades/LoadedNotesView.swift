//
//  LoadedNotesView.swift
//  EpitApp
//
//  Created by Quenting on 19/02/2025.
//

import SwiftUI

struct LoadedNotesView: View {
    @ObservedObject var pegasusAuthModel: PegasusAuthModel
    @ObservedObject var pegasusParser: PegasusParser

    var body: some View {
        switch pegasusParser.progressState {
            case .fetching:
                VStack {
                    Text("Fetching content...")
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .orange))
                }
            case .parsing:
                VStack {
                    Text("Parsing content...")
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .orange))
                }
            case .done:
                VStack {
                    Text("DONE !")
                }
            case .errorFetching:
                Text("Error fetching content.")
            case .errorParsing:
                Text("Error parsing content.")
        }
    }
}
