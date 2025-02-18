//
//  LoadedCalendarClass.swift
//  ZeusApp
//
//  Created by Quenting on 17/02/2025.
//

import SwiftUI


struct LoadedCalendarCourse: View {    
    let range: CourseRange
    @State private var showPopup = false
    
    var body: some View {
        // Formula has been changed to grow slower.
        // Eg 1h is going to be ~46px (almost the same height as the original formula), but
        // 2h is going to be ~79px (less than 2*1h)
        // This is made to avoid eg vacation where it'd take up waaay too much screen.
        //let height = (range.end - range.start)*(5.0/6.0)
        let height = pow((Double)(range.end - range.start), 0.8) * 1.75
        
        let courseColor = (range.courses.count > 1) ? Color.orange : range.courses[0].groups[0].color //TODO: HAndle "better" color from website
        
        let name = (range.courses.count == 1) ? range.courses[0].name : range.courses[0].name + "...";
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

            RoundedRectangle(cornerSize: CGSize(width: 20, height: 30)).frame(width: 5, height: CGFloat(height)).foregroundColor(courseColor)
            
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
                
//                Spacer()
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }.frame(height: CGFloat(height))
        // Note: rn this doesnt take all the width, only the width w text in it. Need to find how to make it full width.
        .onTapGesture {
            showPopup = true;
        }.sheet(isPresented: $showPopup) {
            LoadedCalendarCourseSheet(range: range, borderColor: courseColor)
        }
    }
}
