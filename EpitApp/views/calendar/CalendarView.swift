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
    
    @State private var currentView: AuthState?

    var body: some View {
        VStack {
            if let view = currentView {
                Group {
                    if (selectedIdCache.id == nil) {
                        ChooseIdView()
                            .onAppear {
                                SelectedIdCache.shared.getIdList()
                            }
                    } else {
                        switch view {
                        case .authentified:
                            LoadedCalendarView(courseCache: CourseCache())
                        case .loading:
                            VStack {
                                Text("Logging in...")
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .orange))
                            }
                        default:
                            CalendarLoginView(zeusAuthModel: zeusAuthModel)
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            updateView(zeusAuthModel.authState)
        }
        .onChange(of: zeusAuthModel.authState) { newState in
            updateView(newState)
        }
    }

    private func updateView(_ state: AuthState) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentView = state
        }
    }
}
