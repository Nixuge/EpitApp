//
//  DateUtils.swift
//  EpitApp
//
//  Created by Quenting on 18/02/2025.
//

import Foundation


let dateExtensionFormatter = DateFormatter()

extension Date {
    var formattedNoTimezone: String {
        dateExtensionFormatter.dateFormat = "yyyy-MM-dd"
        return dateExtensionFormatter.string(from: self)
    }
    var FNT: String {
        return formattedNoTimezone
    }
    
    var startMinutesFromDay: Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        return hour * 60 + minute
    }
}
