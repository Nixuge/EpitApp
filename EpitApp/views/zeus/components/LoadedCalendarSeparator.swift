//
//  LoadedCalendarSeparator.swift
//  ZeusApp
//
//  Created by Quenting on 17/02/2025.
//

import SwiftUI

struct LoadedCalendarSeparator: View {
    private let overdrawSize: CGFloat = 25
    
    let isCurrentDay: Bool
    let range: CourseRange
    
    @State private var currentMinute: Int = calculateCurrentMinute()
    @State private var viewWidth: CGFloat = 0

    var body: some View {
        ZStack {
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 5)

                
                Text("\(minutesToTime(minutes: range.start)) - \(minutesToTime(minutes: range.end))")
                    .foregroundColor(.gray)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 5)
            }
            .background(GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        viewWidth = geometry.size.width
                    }
            })
            .frame(maxWidth: .infinity, alignment: .center)
            .onAppear {
                // Update the current minute every minute
                Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                    currentMinute = calculateCurrentMinute()
                }
            }
        
            if isCurrentDay && range.start <= currentMinute && currentMinute <= range.end {
                RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                    .foregroundColor(.red.opacity(0.8))
                    .frame(width: overdrawSize, height: 15)
                    .offset(x: calculateOverlayOffset(viewWidth) - (overdrawSize/2), y: 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .mask {
                        HStack {
                            Rectangle()
                                .frame(maxWidth: .infinity, maxHeight: 1, alignment: .leading)
                                .padding(.horizontal, 5)
                            
                            Text("\(minutesToTime(minutes: range.start)) - \(minutesToTime(minutes: range.end))")
                                .foregroundColor(.gray)
                            
                            Rectangle()
                                .frame(maxWidth: .infinity, maxHeight: 1, alignment: .leading)
                                .padding(.horizontal, 5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
            }
        }
        
    }

    private func calculateOverlayOffset(_ viewWidth: CGFloat) -> CGFloat {
        let totalMinutes = CGFloat(range.end - range.start)
        let pixelPerMinute = (viewWidth - 20) / totalMinutes // Minus offsets
        
        let minutesPassed = CGFloat(currentMinute - range.start)
        
        return 10 + pixelPerMinute * minutesPassed
    }
}

private func calculateCurrentMinute() -> Int {
    let calendar = Calendar.current
    let now = Date()
    let hour = calendar.component(.hour, from: now)
    let minute = calendar.component(.minute, from: now)
    
    let res = hour * 60 + minute
    return res
}
