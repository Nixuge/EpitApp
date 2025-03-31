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
            
            Spacer()
            
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
            
            Spacer()
        }
    }
}




import SwiftUI

struct ListIdChooseView: View {
    let items: [HierarchyNode]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(items) { row in
                    if (row.children == nil) {
                        Divider()
                        ZStack {
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    print("Tapped on \(row.name) (id \(row.id))")
                                    SelectedIdCache.shared.id = row.id.description
                                }
                            
                            Text(row.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                    } else {
                        Divider()
                        IndividualView(title: row.name, items: row.children!, leftRect: true)
                    }
                    
                }

            }
            .padding(.leading, 15)
            .padding(.trailing, 15)
            .padding(.bottom, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                    .foregroundStyle(.gray.opacity(0.2))
            }
        }
    }
}
struct IndividualView: View {
    let title: String
    let items: [HierarchyNode]
    let leftRect: Bool

    @State var isExpanded: Bool = true

    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                HStack(spacing: 0) {
                    if leftRect {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 15, height: .infinity)
                    }
                    LazyVStack {
                        ForEach(items) { row in
                            if row.children == nil {
                                Divider()
                                ZStack {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            print("Tapped on \(row.name) (id \(row.id))")
                                            SelectedIdCache.shared.id = row.id.description
                                        }

                                    Text(row.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .onTapGesture {
                                            print("Tapped on \(row.name) (id \(row.id))")
                                            SelectedIdCache.shared.id = row.id.description
                                        }
                                }
                            } else {
                                Divider()
                                IndividualView(title: row.name, items: row.children!, leftRect: true)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            },
            label: {
                Text(title)
                    .padding(.bottom, 5) // For some reason too low
                    .font(.headline)
            }
        )
    }
}
