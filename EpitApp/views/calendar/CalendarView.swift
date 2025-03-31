//
//  EmploiDuTempsView.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI


struct CalendarView: View {
    @ObservedObject var zeusAuthModel = ZeusAuthModel.shared
    @ObservedObject var selectedIdCache = SelectedIdCache.shared
    
    var body: some View {
        VStack {
            switch zeusAuthModel.authState {
            case .authentified:
                if (selectedIdCache.id == nil) {
                    ChooseIdView(isPresented: .constant(true))
                } else {
                    LoadedCalendarView()
                }
            case .loading:
                VStack {
                    Text("Logging in...")
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .orange))
                }
            default:
                CalendarLoginView(zeusAuthModel: zeusAuthModel)
            }
        }
        .animation(.easeInOut, value: zeusAuthModel.authState)
    }
    
}
