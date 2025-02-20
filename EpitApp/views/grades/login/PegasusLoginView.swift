//
//  LoginView.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI


struct PegasusLoginView: View {
    @ObservedObject var pegasusAuthModel: PegasusAuthModel
    @State private var showWebView = false
    let loginURL = URL(string: "https://prepa-epita.helvetius.net/pegasus/index.php")!

    var body: some View {
        VStack {
            Button(action: {
                showWebView = true
            }) {
                Text("Login")
                    .font(.headline)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .sheet(isPresented: $showWebView) {
                PegasusLoginWebView(pegasusAuthModel: pegasusAuthModel, url: loginURL, isPresented: $showWebView)
            }
        }
    }
}
