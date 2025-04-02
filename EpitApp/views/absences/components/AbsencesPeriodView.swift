//
//  AbsencesPeriodView.swift
//  EpitApp
//
//  Created by Quenting on 24/03/2025.
//


import SwiftUI

struct AbsencesPeriodView: View {
    var period: AbsencesPeriod

    var body: some View {
        VStack {
            LazyVStack(pinnedViews: .sectionHeaders) {
                Section {
                    if (period.absences.isEmpty) {
                        Text("Aucune absence !")
                            .padding(.leading, 5)
                    } else {
                        VStack {
                            ForEach(period.absences) { absence in
                                AbsenceSingleView(absence: absence)
                            }
                        }
                        .padding(.leading, 5)
                    }

                    
                } header: {
                    HStack {
                        Text("Du \(period.beginDate.description) au \(period.endDate.description) (\(period.grade)/\(period.points))")
                            .frame(alignment: .center)
                            .padding(5)
                        
                    }
                    .padding(5)
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                                .foregroundStyle(.green)
                                .padding(2)
                            
                            if (period.isCurrentPeriod) {
                                RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                                    .stroke(.white, lineWidth: 2)
                                    .padding(2)
                            }
                        }
                    )
                }
            }
            .frame( maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
            Spacer()
        }
    }
}
