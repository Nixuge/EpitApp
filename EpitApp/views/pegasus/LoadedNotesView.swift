//
//  LoadedNotesView.swift
//  EpitApp
//
//  Created by Quenting on 19/02/2025.
//
import SwiftUI

struct LoadedNotesView: View {
    @ObservedObject var pegasusAuthModel: PegasusAuthModel
    @ObservedObject var pegasusParser: PegasusParser

    @State private var selectedSemester = 0

    init(pegasusAuthModel: PegasusAuthModel, pegasusParser: PegasusParser) {
        self.pegasusAuthModel = pegasusAuthModel
        self.pegasusParser = pegasusParser
    }

    var body: some View {
        VStack {
            switch pegasusParser.progressState {
            case .fetching:
                VStack {
                    Text("Fetching content...")
                    ProgressView()
                }
            case .parsing:
                VStack {
                    Text("Parsing content...")
                    ProgressView()
                }
            case .errorFetching:
                Text("Error fetching content.")
            case .errorParsing:
                Text("Error parsing content.")
            case .done:
                VStack {
                    PegasusHeader(pegasusParser: pegasusParser, selectedSemester: $selectedSemester)
                        .padding()

                    TabView(selection: $selectedSemester) {
                        ForEach(pegasusParser.data!.semesters.indices, id: \.self) { index in
                            PegasusSemesterView(pegasusParser: pegasusParser, semester: pegasusParser.data!.semesters[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }

        }
        .animation(.easeInOut, value: pegasusParser.progressState)
    }
}
