//
//  JankOffsetter.swift
//  EpitApp
//
//  Created by Quenting on 22/02/2025.
//

import SwiftUI
import Combine


// Kinda dirty part in code :/
// Basically nested LazyVStack pinnedViews don't work.
// What I've done here is made it have a padding to be below if under a certain y/
// This is used im the PegasusUEView and the PegasusECUEView and set in the PegasusSemesterView and in the PegasusUEView
class JankOffsetter: ObservableObject {
    @Published var semesterHeaderBottomY: CGFloat
    var availableSemesterHeaderValues: [String: CGFloat]
    
    init() {
        self.semesterHeaderBottomY = 0
        self.availableSemesterHeaderValues = [:]
    }
    
    func setSemesterHeaderBottonY(semesterName: String, y: CGFloat) {
        availableSemesterHeaderValues[semesterName] = y
        
    }
    func semesterDisappear(semesterName: String) {
        availableSemesterHeaderValues.removeValue(forKey: semesterName)
    }
    func semesterAppear(semesterName: String, y: CGFloat) {
//        availableSemesterHeaderValues.
    }
}
