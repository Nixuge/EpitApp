//
//  TPSView.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI

struct AbsencesView: View {
    @ObservedObject var authModel: AbsencesAuthModel = AbsencesAuthModel.shared
    
    var absencesCache = AbsencesCache.shared

    var body: some View {
        if (authModel.authState == .authentified) {
            AbsencesLoadedView()
                .onAppear {
                    absencesCache.grabNewContent()
                }
        } else {
            AbsencesLoginView()
        }
    }
}
