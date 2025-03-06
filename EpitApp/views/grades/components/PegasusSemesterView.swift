//
//  PegasusSemesterView.swift
//  EpitApp
//
//  Created by Quenting on 20/02/2025.
//

import SwiftUI

struct PegasusSemesterView: View {
    @ObservedObject var pegasusParser: PegasusParser
    @ObservedObject var jankOffsetter: JankOffsetter
    var semester: PegasusSemester

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10, bottomTrailingRadius: 10, topTrailingRadius: 10)
//                    RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                .fill(Color.blue)
                .frame(minWidth: 6, idealWidth: 6, maxWidth: 6, maxHeight: .infinity, alignment: .topLeading)
            
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
//                        GeometryReader { gReader in
//                            ZStack {
//                                Text(semester.label)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
////                                    .background(BlurView())
//
//                                    .padding(2)
//                            }
//                            .background(Color.black)
//                            .font(.headline)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                        }
                Section {
                    ForEach(semester.localisations[0].compensations[0].UEs) { ue in
                        PegasusUEView(jankOffsetter: jankOffsetter, ue: ue)
                    }
                } header: {
                    GeometryReader { geometry in
                        let maxY = geometry.frame(in: .global).maxY
                        
                        VStack(spacing: 0) {
                            Text(semester.label)
//                            Text(geometry.frame(in: .global).maxY.description)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(5)
                            
                            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 20, topTrailingRadius: 20)
                                .frame(maxWidth: .infinity, minHeight: 6, maxHeight: 6, alignment: .leading)
                                .foregroundStyle(.blue)
                        }
                        .background(Color.black)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onChange(of: maxY) { newMaxY in
//                            debounce(maxY: newMaxY)
//                            print("Change: \(maxY)")
                            let size = geometry.size.height * 2
                            jankOffsetter.semesterHeaderBottomY = newMaxY + size + 5 // + offset
                        }
                        .onAppear() {
                            print("Appeared !")
                        }
                        .onDisappear {
                            print("Disaappeared !")
                        }
//                        .onChange(of: geometry.frame(in: .global).maxY) { newMaxY in
//                            // For some reason, geometry.size.height seems to be half the actual size.
//                            let size = geometry.size.height * 2
//                            jankOffsetter.semesterHeaderBottomY = newMaxY + size + 5 // + offset
//                        }
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
