//
//  LoadedCalendarSeparator.swift
//  ZeusApp
//
//  Created by Quenting on 17/02/2025.
//

import SwiftUI


struct LoadedCalendarSeparator: View {
    let range: CourseRange
    
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
                .padding(.horizontal, 10)
            
            Text("\(minutesToTime(minutes: range.start)) - \(minutesToTime(minutes: range.end))")
                .foregroundColor(.gray)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
                .padding(.horizontal, 10)
        }.frame(maxWidth: .infinity, alignment: .center)
    }
}
