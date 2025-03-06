//
//  LoadedNotesView.swift
//  EpitApp
//
//  Created by Quenting on 19/02/2025.
//
// TODO: Scrap this view and do like calendar, scroll left/right to see different semesters.
// Would also make jankOffsetter unnecessary !!
import SwiftUI

struct LoadedNotesView: View {
    @ObservedObject var pegasusAuthModel: PegasusAuthModel
    @ObservedObject var pegasusParser: PegasusParser
    var jankOffsetter: JankOffsetter
    
    init(pegasusAuthModel: PegasusAuthModel, pegasusParser: PegasusParser) {
        self.pegasusAuthModel = pegasusAuthModel
        self.pegasusParser = pegasusParser
        self.jankOffsetter = JankOffsetter()
    }
    
    var body: some View {
        switch pegasusParser.progressState {
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
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ForEach(pegasusParser.data!.semesters) { semester in
                        PegasusSemesterView(pegasusParser: pegasusParser, jankOffsetter: jankOffsetter, semester: semester)
                        Divider()
                    }
                }
            }
        }
    }
}
