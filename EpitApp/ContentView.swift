//
//  AuthViewModel.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var zeusAuthModel = ZeusAuthModel()
    @StateObject private var authViewModel = AuthViewModel()
    @State private var selectedTab: Tab = .emploiDuTemps

    enum Tab {
        case notes
        case emploiDuTemps
        case tps
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                CalendarView(zeusAuthModel: zeusAuthModel)
            }
            .tabItem {
                Label("Zeus", systemImage: "calendar")
            }
            .tag(Tab.emploiDuTemps)
            
            NavigationView {
                NotesView()
                    .navigationTitle("Notes")
            }
            .tabItem {
                Label("Pegasus", systemImage: "note.text")
            }
            .tag(Tab.notes)

            NavigationView {
                AbsencesView()
                    .navigationTitle("Absences")
            }
            .tabItem {
                Label("Absences", systemImage: "timer")
            }
            .tag(Tab.tps)

            NavigationView {
                SettingsView(authViewModel: authViewModel, zeusAuthModel: zeusAuthModel)
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(Tab.settings)
        }
    }
}
