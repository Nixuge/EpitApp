//
//  AbsencesSemesterHeader.swift
//  EpitApp
//
//  Created by Quenting on 21/03/2025.
//


import SwiftUI


struct AbsencesHeader: View {
    @ObservedObject var absencesCache: AbsencesCache = AbsencesCache.shared
    @Binding var selectedSemester: Int
    
    let color = Color.green

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
            
            Button(action: {
            }) {
                let selected = absencesCache.content[selectedSemester]
                Text("\(selected.levelName) (\(selected.promo))")
                    .foregroundStyle(color)
            }

            Spacer()

            Button(action: {
                selectedSemester += 1
            }) {
                Image(systemName: "arrow.right")
                    .foregroundStyle(selectedSemester >= absencesCache.content.count - 1 ? .gray : color)
            }
            .disabled(selectedSemester >= absencesCache.content.count - 1)
        }
    }
}
