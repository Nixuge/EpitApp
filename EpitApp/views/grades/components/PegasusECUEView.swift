//
//  PegasusECUEView.swift
//  EpitApp
//
//  Created by Quenting on 21/02/2025.
//


import SwiftUI

struct PegasusECUEView: View {
    @ObservedObject var jankOffsetter: JankOffsetter
    var ecue: PegasusECUE

    var body: some View {
        HStack(alignment: .top) {
//            UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10, bottomTrailingRadius: 10, topTrailingRadius: 10)
//                .fill(Color.orange)
//                .frame(minWidth: 3, idealWidth: 3, maxWidth: 3, maxHeight: .infinity, alignment: .topLeading)
//                .padding(.leading, 5)
//            
            LazyVStack(spacing: 5, pinnedViews: .sectionHeaders) {
                Section {
                    Text(ecue.label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(5)
                    
                    UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 20, topTrailingRadius: 20)
                        .frame(maxWidth: .infinity, minHeight: 3, maxHeight: 3, alignment: .leading)
                        .foregroundStyle(.orange)
                    
                    if (ecue.inner[0].grades.isEmpty) {
                        Text("No grades").foregroundStyle(Color.gray)
                            .padding(5)
                    } else {
                        ForEach(ecue.inner[0].grades) { grade in
                            HStack(spacing: 8) {
                                Text("\(grade.noteType): \(grade.note.displayableString())")
                                Text("\(grade.date)")
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    .foregroundColor(.gray)
                            }
                            .padding(5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color.orange, lineWidth: 2)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//            .padding(.bottom, 5)
            .padding(5)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
