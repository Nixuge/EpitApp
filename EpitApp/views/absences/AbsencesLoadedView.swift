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
//        }
    }
}
