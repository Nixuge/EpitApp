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
                if (selectedSemester <= absencesCache.content.count-1) {
                    let selected = absencesCache.content[selectedSemester]
                    // Without the .description i get an annoying space (eg 2 029 instead of 2029)
                    Text("\(selected.levelName) (\(selected.promo.description))")
                        .foregroundStyle(color)
                } else {
                    // Basically just a safeguard to not crash on a logout.
                    Text("Unknown")
                        .foregroundStyle(color)
                }
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
