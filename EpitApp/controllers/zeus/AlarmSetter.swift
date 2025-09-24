//
//  AlarmSetter.swift
//  EpitApp
//
//  Created by Quenting on 24/09/2025.
//

struct Alarm: Equatable {
    var time: String
    var new: Bool
}

import SwiftUI

class AlarmSetter: ObservableObject {
    static let shared = AlarmSetter()
    
    @Published var receivedAlarmSet: Alarm? = nil
    
    public func setAlarmSet(url: String) {
        let urlSplit = url.split(separator: "/")
        if (urlSplit.count != 2) {
            warn("Uh oh")
            return
        }
        
        setAlarmSet(Alarm(time: String(urlSplit[0]), new: urlSplit[1].contains("new")))
    }
    
    func setAlarmSet(_ alarm: Alarm) {
        receivedAlarmSet = alarm
        info("Alarm set successfully set to \(alarm)")
    }
    
    public func clearAlarmSet() {
        receivedAlarmSet = nil
    }
}
