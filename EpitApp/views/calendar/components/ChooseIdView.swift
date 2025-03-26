//
//  ChooseIdView.swift
//  EpitApp
//
//  Created by Quenting on 26/03/2025.
//

import SwiftUI


struct ChooseIdView: View {
    @State var searchText = ""
    @State var backupIdText = ""
    
    @State var currentSearchResult: [HierarchyNode] = []
    
    @ObservedObject var selectedIdCache = SelectedIdCache.shared
    
    var body: some View {
        VStack {
            FancyTextInput(text: $searchText, placeholder: "Search", color: .orange)
                .padding(5)
            
            switch selectedIdCache.loadingState {
            case .def:
                Text("Error: Not processing?")
            case .loading:
                Text("Loading hierarchy...")
                ProgressView()
            case .done:
                ListIdChooseView(items: currentSearchResult)
                    .onAppear() {
                        currentSearchResult = selectedIdCache.searchForName(searchText, in: selectedIdCache.allIds!)
                    }
                    .onChange(of: searchText) { newValue in
                        currentSearchResult = selectedIdCache.searchForName(newValue, in: selectedIdCache.allIds!)
                    }
            case .failed:
                Text("Failed to load hierarchy.")
                FancyButton(text: "Retry ?") {
                    selectedIdCache.getIdList()
                }
            }
        }
    }
}




import SwiftUI

struct ListIdChooseView: View {
    let items: [HierarchyNode]
    
    var body: some View {
        List(items, children: \.children) { row in
            if (row.children == nil) {
                ZStack {
                    Rectangle()
                        .fill(Color.clear)  // Make the rectangle invisible
                        .contentShape(Rectangle())  // Define the tappable area
                        .onTapGesture {
                            print("Tapped on \(row.name) (id \(row.id))")
                            SelectedIdCache.shared.id = row.id.description
                        }
                    
                    Text(row.name)
                        .frame(maxWidth: .infinity, alignment: .leading)


                }
                .frame( alignment: .leading)
            } else {
                Text(row.name)
            }
        }
        .animation(.none)
    }
}
