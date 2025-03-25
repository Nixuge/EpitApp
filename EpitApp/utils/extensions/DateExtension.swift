//
//  DateUtils.swift
//  EpitApp
//
//  Created by Quenting on 18/02/2025.
//

import Foundation

// Avoid re setting dateFormat every time.
private struct DateFormatterHelper {
    static let FNTFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let LeAFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy-MM à HH:mm"
        return formatter
    }()
}



extension Date {
    var formattedNoTimezone: String {
        return DateFormatterHelper.FNTFormatter.string(from: self)
    }
    var FNT: String {
        return formattedNoTimezone
    }
    
    var formatLeA: String {
        return DateFormatterHelper.LeAFormatter.string(from: self)
    }
    
    var startMinutesFromDay: Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        return hour * 60 + minute
    }
}
