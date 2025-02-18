//
//  LoadedCalendarCourseSheet.swift
//  EpitApp
//
//  Created by Quenting on 18/02/2025.
//

import SwiftUI


// TODO: If multiple courses, show multiple rectangles.
struct LoadedCalendarCourseSheet: View {
    @Environment(\.colorScheme) var colorScheme
    
    let range: CourseRange
    let borderColor: Color
    
    var body: some View {
        VStack() {
            ForEach(range.courses, id: \.self) { course in
                Text(course.name)
                    .bold(true)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                
                Divider()
                    .frame(height: 1)
                    .background(course.groups.first?.color ?? Color.gray)
                        .padding(.horizontal, 25)
                
                VStack(alignment: .leading) {
                    Text("Teachers:")
                        .padding(.top, 10)
                        .multilineTextAlignment(.leading)

                    if (!course.teachers.isEmpty) {
                        let allTeacherNames = course.teachers.compactMap { $0.name }.joined(separator: ", ")
                        Text(allTeacherNames).multilineTextAlignment(.leading)
                    } else {
                        Text("None")
                            .multilineTextAlignment(.leading)
                    }

                    Text("Rooms:")
                        .padding(.top, 10)
                        .multilineTextAlignment(.leading)

                    if (!course.rooms.isEmpty) {
                        let allRoomNames = course.rooms.compactMap { $0.name }.joined(separator: ", ")
                        Text(allRoomNames)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("None")
                            .multilineTextAlignment(.leading)
                    }

                    Text("Groups:")
                        .padding(.top, 10)
                        .multilineTextAlignment(.leading)

                    if (!course.groups.isEmpty) {
                        let allGroupNames = course.groups.compactMap { $0.name }.joined(separator: ", ")
                        Text(allGroupNames)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("None")
                            .multilineTextAlignment(.leading)
                    }
                    
                    // Unimplemented - needs another request.
                    Text("Comments:")
                        .padding(.top, 10)
                    Text("TODO")
                        .multilineTextAlignment(.leading)
                    
                    
                }
                .padding(.horizontal, 30)
                .frame(maxWidth: .infinity, alignment: .leading)


                
                if (course != range.courses.last) {
                    Divider()
                            .frame(height: 2)
                            .background(Color.orange)
                            .padding(.horizontal, 10)
                }
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 30, leading: 10, bottom: 80, trailing: 10))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                // Background color
                if (colorScheme == .dark) {
                    Color.black.edgesIgnoringSafeArea(.all)
                }
                // Border (offset down otherwise not looking good)
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(borderColor, lineWidth: 2)
                        .frame(height: geometry.size.height + 100)
                }
            }
        )
    }
}
