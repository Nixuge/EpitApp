//
//  PegasusHeader.swift
//  EpitApp
//
//  Created by Quenting on 06/03/2025.
//


import SwiftUI


struct PegasusHeader: View {
    @ObservedObject var pegasusParser: PegasusParser
    @Binding var selectedSemester: Int
    
    let color = Color.orange

    var body: some View {
        HStack {
            Button(action: {
                selectedSemester -= 1
            }) {
                Image(systemName: "arrow.left")
                    .foregroundStyle(selectedSemester == 0 ? .gray : color)
            }
            .disabled(selectedSemester == 0)

            Spacer()
            
            // TODO: Tap for overview of it.
            Button(action: {
            }) {
                Text(pegasusParser.data?.semesters[selectedSemester].label ?? "Unknown")
                    .foregroundStyle(color)
            }

            Spacer()

            Button(action: {
                selectedSemester += 1
            }) {
                Image(systemName: "arrow.right")
                    .foregroundStyle(selectedSemester >= (pegasusParser.data?.semesters.count ?? 1) - 1 ? .gray : color)
            }
            .disabled(selectedSemester >= (pegasusParser.data?.semesters.count ?? 1) - 1)
        }
    }
}
