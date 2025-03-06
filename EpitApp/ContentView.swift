//
//  AuthViewModel.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .notes //TODO: Change back

    enum Tab {
        case notes
        case emploiDuTemps
        case tps
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                CalendarView()
            }
            .tabItem {
                Label("Zeus", systemImage: "calendar")
            }
            .tag(Tab.emploiDuTemps)
            
            NavigationView {
                NotesView()
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
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(Tab.settings)
        }
    }
}
