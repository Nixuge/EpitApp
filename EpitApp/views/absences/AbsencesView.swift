//
//  TPSView.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI

struct AbsencesView: View {
    @ObservedObject var authModel: AbsencesAuthModel = AbsencesAuthModel.shared
    @ObservedObject var absencesCache = AbsencesCache.shared

    var body: some View {
        if (authModel.authState == .authentified) {
            AbsencesLoadedView()
            // Why that:
            // On initial launch, what the program does first is to.
            // check it the token is valid by calling absencesCache.grabNewContent on it
            // This makes it so that on first launch, the absencesCache is in loading state, while the authState is unauthentified.
            // Hence why we need to check for both here.
        } else if (authModel.authState == .loading) {
            VStack {
                Text("Logging in...")
                ProgressView()
            }
        } else if (absencesCache.state == .loading) {
            VStack {
                Text("Loading data...")
                ProgressView()
            }.onAppear {
                // Should only ever happen once
                absencesCache.onAppear()
            }
        } else {
            AbsencesLoginView()
        }
    }
}
