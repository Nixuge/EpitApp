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
        VStack {
            if (authModel.authState == .unauthenticated || authModel.authState == .failed || absencesCache.state == .failed) {
                AbsencesLoginView()
            } else if (authModel.authState == .loading) {
                VStack {
                    Text("Logging in...")
                    ProgressView()
                }
            } else if (absencesCache.state == .unloaded) {
                Text("Data unloaded.")
            } else if (absencesCache.state == .loading) {
                VStack {
                    Text("Loading data...")
                    ProgressView()
                }
            } else if (authModel.authState == .authentified && absencesCache.state == .loaded) {
                AbsencesLoadedView()
                // Why that:
                // On initial launch, what the program does first is to.
                // check it the token is valid by calling absencesCache.grabNewContent on it
                // This makes it so that on first launch, the absencesCache is in loading state, while the authState is unauthentified.
                // Hence why we need to check for both here.
            } else {
                Text("Unknown state? auth: \(authModel), cache: \(absencesCache)")
            }
        }
        .animation(.easeInOut, value: authModel.authState)
        .animation(.easeInOut, value: absencesCache.state)
        .onAppear {
            if (!authModel.isInitialLoginDone) {
                log("Appeared !")
                authModel.loginWithSaved(completion:{ success in
                    log("Absences default login success: \(success)")
                    if (success) {
                        AbsencesCache.shared.grabNewContent()
                    }
                })
                authModel.isInitialLoginDone = true
            }

        }
    }
}
