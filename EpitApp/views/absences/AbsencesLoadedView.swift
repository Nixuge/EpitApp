//
//  AbsencesLoadedView.swift
//  EpitApp
//
//  Created by Quenting on 21/03/2025.
//

import SwiftUI

struct AbsencesLoadedView: View {
    @ObservedObject var cache = AbsencesCache.shared

    @State var selectedSemester: Int = 0

    var body: some View {
        switch cache.state {
        case .unloaded:
            Text("Unloaded cache ?") // Should not happen
            
        case .loading:
            Text("Loading content...")
        
        case .loaded:
            VStack {
                AbsencesHeader(selectedSemester: $selectedSemester)
                    .padding()
                
                TabView(selection: $selectedSemester) {
                    ForEach(cache.content.indices, id: \.self) { index in
                        AbsencesSemesterView(semester: cache.content[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
    }
}
