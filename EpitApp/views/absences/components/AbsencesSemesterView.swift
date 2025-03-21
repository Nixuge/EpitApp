//
//  AbsencesSemesterView.swift
//  EpitApp
//
//  Created by Quenting on 21/03/2025.
//

import SwiftUI

struct AbsencesSemesterView: View {
    var semester: AbsencesSemester

    var body: some View {
        VStack {
            Text("To be done.")
            Text("Semester \(semester.levelName)")
            Text("Amount of periods: \(semester.periods.count)")
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(10)
    }
}
