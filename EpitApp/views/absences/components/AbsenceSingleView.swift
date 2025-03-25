//
//  AbsenceView.swift
//  EpitApp
//
//  Created by Quenting on 24/03/2025.
//


import SwiftUI

struct AbsenceSingleView: View {
    var absence: Absence

    var body: some View {
        VStack {
            Text("Le \(absence.startDate.formatLeA)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text("En \(absence.subjectName)")
                
                if (absence.mandatory) {
                    Text("(Obligatoire)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if (absence.justificatory == nil) {
                Text("Non justifiée")
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Justification: \(absence.justificatory!)")
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }


            

            
            Divider()
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

