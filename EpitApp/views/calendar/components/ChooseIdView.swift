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
    
    @Binding var isPresented: Bool
    
    @State var currentSearchResult: [HierarchyNode] = []
    
    @ObservedObject var selectedIdCache = SelectedIdCache.shared
    
    var body: some View {
        VStack {
            TextField(
                "Search",
                text: $searchText
            )
            .padding(.trailing, 15)
            .padding(.leading, 15)
            .padding(.top, 15)
            .font(.title)
            
            Divider()
            
            
            Spacer()
            
            switch selectedIdCache.loadingState {
            case .def:
                Text("Checking login...")
            case .loading:
                Text("Loading hierarchy...")
                ProgressView()
            case .done:
                ListIdChooseView(items: currentSearchResult, isPresented: $isPresented)
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
        .onAppear { SelectedIdCache.shared.getIdList()}
    }
}


func onButtonClick(row: HierarchyNode, isPresented: Binding<Bool>) {
    print("Tapped on \(row.name) (id \(row.id))")
    SelectedIdCache.shared.id = row.id.description
    isPresented.wrappedValue = false
    CourseCache.shared.clearAllCourses()
    Task {
        await CourseCache.shared.reRequestLastSavedDateOtherwiseDoNothing()
    }
    
}



struct ListIdChooseView: View {
    let items: [HierarchyNode]
    @Binding var isPresented: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(items) { row in
                    if (row.children == nil) {
                        ZStack {
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onButtonClick(row: row, isPresented: $isPresented)
                                }
                            
                            Text(row.name)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onTapGesture {
                                    onButtonClick(row: row, isPresented: $isPresented)
                                }
                        }
                        
                    } else {
                        // DIRTY FIX - no divider at the top.
                        if (row.name != "EPITA") {
                            Divider()
                        }
                        IndividualView(title: row.name, items: row.children!, isViewPresented: $isPresented)
                    }
                    
                }

            }
            .padding(.leading, 15)
            .padding(.trailing, 15)
            .padding(.bottom, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
//                RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
//                    .foregroundStyle(.gray.opacity(0.2))
            }
        }
    }
}
struct IndividualView: View {
    let title: String
    let items: [HierarchyNode]

    @Binding var isViewPresented: Bool

    @State var isExpanded: Bool = true

    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 15, height: .infinity)
                
                    LazyVStack {
                        ForEach(items) { row in
                            if row.children == nil {
                                Divider()
                                ZStack {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            onButtonClick(row: row, isPresented: $isViewPresented)
                                        }

                                    Text(row.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .onTapGesture {
                                            onButtonClick(row: row, isPresented: $isViewPresented)
                                        }
                                }
                            } else {
                                Divider()
                                IndividualView(title: row.name, items: row.children!, isViewPresented: $isViewPresented)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            },
            label: {
                Text(title)
                    .padding(.bottom, 5)
                    .font(.headline)
            }
        )
    }
}
