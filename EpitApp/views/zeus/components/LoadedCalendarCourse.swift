//
//  LoadedCalendarClass.swift
//  ZeusApp
//
//  Created by Quenting on 17/02/2025.
//

import SwiftUI


struct LoadedCalendarCourse: View {
    let isCurrentDay: Bool
    let range: CourseRange
    
    @State private var showPopup = false

    @State private var currentMinute: Int = calculateCurrentMinute()

    var body: some View {
        // Formula has been changed to grow slower.
        // Eg 1h is going to be ~46px (almost the same height as the original formula), but
        // 2h is going to be ~79px (less than 2*1h)
        // This is made to avoid eg vacation where it'd take up waaay too much screen.
        //let height = (range.end - range.start)*(5.0/6.0)
        let height = pow((Double)(range.end - range.start), 0.8) * 1.75
        
        let courseColor = (range.courses.count > 1) ? Color.orange : range.courses[0].groups[0].color //TODO: HAndle "better" color from website
        
        let name = (range.courses.count == 1) ? range.courses[0].name : range.courses[0].name + "...";
        ZStack {
            HStack {
                VStack(alignment: .trailing) {
                    Text(minutesToTime(minutes: range.start))
                        .multilineTextAlignment(.trailing)
                        .frame(width: 50, alignment: .trailing)
                    
                    Spacer()
                    
                    Text(minutesToTime(minutes: range.end))
                        .multilineTextAlignment(.trailing)
                        .frame(width: 50, alignment: .trailing)
                }
                
                ZStack {
                    RoundedRectangle(cornerSize: CGSize(width: 20, height: 30)).frame(width: 5, height: CGFloat(height)).foregroundColor(courseColor)
                    
                    if isCurrentDay && range.start <= currentMinute && currentMinute <= range.end {
                        RoundedRectangle(cornerSize: CGSize(width: 20, height: 30))
                            .frame(width: 5, height: 10)
                            .frame(maxHeight: .infinity, alignment: .topLeading)
                            .foregroundColor(.white.opacity(0.8))
                            .offset(x: 0, y: calculateOverlayOffset(height))
                    }
                }
                .onAppear {
                    // Update the current minute every minute
                    Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                        currentMinute = calculateCurrentMinute()
                    }
                }

                
                VStack(alignment: .leading) {
                    Text(name)
                        .multilineTextAlignment(.leading)
                        .frame(alignment: .topLeading)
                    
                    // TODO: Handle multi courses better for below.
                    if (range.courses.count > 1) {
                        Text("Multiple classes at once").foregroundColor(.red)
                    } else {
                        if (!range.courses[0].rooms.isEmpty) {
                            let allRoomNames = range.courses.flatMap { $0.rooms }.map { $0.name }.joined(separator: ", ")
                            Text(allRoomNames).foregroundColor(.gray)
                        }
                    }
                    

                    if (height > 50 && !range.courses[0].teachers.isEmpty) {
                        let allTeacherNames = range.courses.flatMap { $0.teachers }.map { $0.name }.joined(separator: ", ")
                        Text(allTeacherNames)
                            .multilineTextAlignment(.leading)
                            .frame(alignment: .topLeading)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Dirty hack:
            // Big rectangle on top of everything to check for taps.
            // Problem is: when the rectangle is of color .clear, it doesn't register taps.
            // The fix: make smth with an opacity of 0.001
            Rectangle()
                .foregroundStyle(.black.opacity(0.001))
        }.frame(height: CGFloat(height))
        // Note: rn this doesnt take all the width, only the width w text in it. Need to find how to make it full width.
        .onTapGesture {
            showPopup = true;
        }.sheet(isPresented: $showPopup) {
            LoadedCalendarCourseSheet(range: range, borderColor: courseColor)
        }
    }
    
    private func calculateOverlayOffset(_ viewHeight: CGFloat) -> CGFloat {
        let totalMinutes = CGFloat(range.end - range.start)
        let pixelPerMinute = (viewHeight - 5) / totalMinutes

        let minutesPassed = CGFloat(currentMinute - range.start)
        return pixelPerMinute * minutesPassed
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
