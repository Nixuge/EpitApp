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
    @State private var currentView: PegasusProgressState?

    init(pegasusAuthModel: PegasusAuthModel, pegasusParser: PegasusParser) {
        self.pegasusAuthModel = pegasusAuthModel
        self.pegasusParser = pegasusParser
    }

    var body: some View {
        VStack {
            if let view = currentView {
                Group {
                    switch view {
                    case .fetching:
                        VStack {
                            Text("Fetching content...")
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .orange))
                        }
                    case .parsing:
                        VStack {
                            Text("Parsing content...")
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .orange))
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
                .transition(.opacity)
            }
        }
        .onAppear {
            updateView(pegasusParser.progressState)
        }
        .onChange(of: pegasusParser.progressState) { newState in
            updateView(newState)
        }
    }

    private func updateView(_ state: PegasusProgressState) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentView = state
        }
    }
}
