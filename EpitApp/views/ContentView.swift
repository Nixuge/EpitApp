//
//  ContentView.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .zeus
    
    @State private var color: Color = .orange

    enum Tab {
        case zeus
        case pegasus
        case absences
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
            .tag(Tab.zeus)
            
            NavigationView {
                NotesView()
            }
            .tabItem {
                Label("Pegasus", systemImage: "note.text")
            }
            .tag(Tab.pegasus)

            NavigationView {
                AbsencesView()
//                    .navigationTitle("Absences")
            }
            .tabItem {
                Label("Absences", systemImage: "timer")
            }
            .tag(Tab.absences)

            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(Tab.settings)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tint(color)
        .onChange(of: selectedTab, perform: { tab in
            changeColorToTabColor(selectedTab)
        })
        .onAppear {
            changeColorToTabColor(selectedTab)
        }
    }
    
    func changeColorToTabColor(_ newTab: Tab) {
        switch newTab {
        case .zeus:
            color = .orange
        case .pegasus:
            color = .pegasusTextColor
        case .absences:
            color = .green
        case .settings:
            color = .white
        }
    }
}
