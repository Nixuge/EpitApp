//
//  PegasusSemesterView.swift
//  EpitApp
//
//  Created by Quenting on 20/02/2025.
//

import SwiftUI

struct PegasusSemesterView: View {
    @ObservedObject var pegasusParser: PegasusParser
    var semester: PegasusSemester

    var body: some View {
        ScrollView {
            VStack {
                ForEach(semester.localisations[0].compensations[0].UEs) { ue in
                    PegasusUEView(ue: ue)
                }
            }
        }
    }
}
