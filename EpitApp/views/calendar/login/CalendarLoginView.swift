//
//  LoginView.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI


struct CalendarLoginView: View {
    @ObservedObject var zeusAuthModel: ZeusAuthModel
    @State private var showWebView = false
    let loginURL = URL(string: "https://zeus.ionis-it.com/login")!

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
                CalendarLoginWebView(zeusAuthModel: zeusAuthModel, url: loginURL, isPresented: $showWebView)
            }
        }
    }
}
