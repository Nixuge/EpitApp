//
//  EmploiDuTempsView.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI


struct CalendarView: View {
    @ObservedObject var zeusAuthModel = ZeusAuthModel.shared

    var body: some View {
        if zeusAuthModel.authState == AuthState.authentified {
            LoadedCalendarView(courseCache: CourseCache())
        } else if zeusAuthModel.authState == AuthState.loading {
            VStack {
                Text("Logging in...")
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .orange))
            }
        } else {
            CalendarLoginView(zeusAuthModel: zeusAuthModel)
        }
    }
}
