//
//  ChooseIdView.swift
//  EpitApp
//
//  Created by Quenting on 26/03/2025.
//

// TODO:
// Break down into multiple classes.
// Find if lag on open (due to the ScrollView) is fixable :/
import SwiftUI


struct ChooseIdView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var favoriteHelpPopupShown = false

    @State var searchText = ""
    @State var backupIdText = ""
    
    @Binding var isPresented: Bool
    
    @State var currentSearchResult: [HierarchyNode] = []
    
    @ObservedObject var selectedIdCache = SelectedIdCache.shared
    
    @FocusState private var searchFocus: Bool
    
    @State private var isEditing = false

    private func moveFavorite(from source: IndexSet, to destination: Int) {
        selectedIdCache.favoriteIds.move(fromOffsets: source, toOffset: destination)
    }
    private func deleteFavorite(at offsets: IndexSet) {
        selectedIdCache.favoriteIds.remove(atOffsets: offsets)
    }
    
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
            .focused($searchFocus)
            .onAppear {
                searchFocus = true
            }
            
            Divider()
            
            ScrollView {
                if (selectedIdCache.favoriteIds.count > 0) {
                    NavigationView {
                        List {
                            ForEach(selectedIdCache.favoriteIds, id: \.self) { row in
                                ZStack {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            onStringButtonClick(id: row.id, isPresented: $isPresented)
                                        }
                                    
                                    HStack {
                                        Text(row.name)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .onTapGesture {
                                                onStringButtonClick(id: row.id, isPresented: $isPresented)
                                            }
                                        
                                        if row.id == selectedIdCache.id {
                                            Spacer()
                                            Label("", systemImage: "checkmark")
                                                .foregroundStyle(.tint)
                                        }
                                    }
                                }
                                .listRowBackground(Color.clear)

                            }
                            .onMove(perform: moveFavorite)
                            .onDelete(perform: deleteFavorite)
                        }
                        .scrollDisabled(true)
                        .background(colorScheme == .dark ? .black : .white)
                        .listStyle(PlainListStyle())
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Text("Favorites")
                                    .foregroundStyle(.orange)
                                    .bold()
                                    .font(.title)
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                EditButton()
                            }
                        }
                    }
                    .frame(height: CGFloat(selectedIdCache.favoriteIds.count) * 44 + 55)
                    .padding(5)

                    Divider()
                }
                
                Text("Manual selection")
                    .foregroundStyle(.orange)
                    .bold()
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)

                switch selectedIdCache.loadingState {
                case .def:
                    Text("Checking login...")
                    ProgressView()
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
            }
            .animation(.easeInOut, value: selectedIdCache.loadingState)
            
            Spacer()
        }
        .onAppear {
            SelectedIdCache.shared.getIdList()
        }
    }
}


func onButtonClick(row: HierarchyNode, isPresented: Binding<Bool>) {
    log("Tapped on \(row.name) (id \(row.id))")
    onStringButtonClick(id: row.id, isPresented: isPresented)
}

func onStringButtonClick(id: Int, isPresented: Binding<Bool>) {
    log("Tapped on id \(id)")
    SelectedIdCache.shared.id = id
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
                        IndividualView(row: row, items: row.children!, isViewPresented: $isPresented)
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
    let row: HierarchyNode
    let items: [HierarchyNode]

    @Binding var isViewPresented: Bool

    @State var isExpanded: Bool = true
    
    @ObservedObject var selectedIdCache = SelectedIdCache.shared

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
                                    
                                    HStack {
                                        Text(row.name)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .onTapGesture {
                                                onButtonClick(row: row, isPresented: $isViewPresented)
                                            }
                                        
                                        if (row.id == SelectedIdCache.shared.id) {
                                            Spacer()
                                            Label("", systemImage: "checkmark")
                                                .foregroundStyle(.tint)
                                        }
                                        if (selectedIdCache.favoriteIds.contains(where: { $0.id == row.id })) {
                                            Label("", systemImage: "star.fill")
                                                .foregroundStyle(.tint)
                                                .onTapGesture {
                                                    selectedIdCache.favoriteIds.removeAll(where: { $0.id == row.id})
                                                    log("CC !!!")
                                                }
                                        } else {
                                            Label("", systemImage: "star")
                                                .foregroundStyle(.tint)
                                                .onTapGesture {
                                                    selectedIdCache.favoriteIds.append(FavoriteID(name: row.name, id: row.id))
                                                    log("HIIII !!!")
                                                }
                                        }
                        
                                    }

                                }
                            } else {
                                Divider()
                                IndividualView(row: row, items: row.children!, isViewPresented: $isViewPresented)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            },
            label: {
                HStack {
                    Text(row.name)
                        .padding(.bottom, 5)
                        .font(.headline)
                }
            }
        )
    }
}
