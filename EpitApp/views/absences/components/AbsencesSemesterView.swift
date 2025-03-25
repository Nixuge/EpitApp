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
        ScrollView {
            VStack {
                ForEach(semester.periods) { period in
                    AbsencesPeriodView(period: period)
                }
            }
        }
    }
}
