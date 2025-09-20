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
    
    @ObservedObject var courseDetailsCache = CourseDetailsCache.shared
    
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
                    
                    
                    VStack {
                        switch courseDetailsCache.details[course.idReservation] {
                        case .failed(let error):
                            Text("Loading course data...")
                                .padding(.top, 10)
                            Text("Error loading: \(error)")
                        case .loaded(let details):
                            if (details.comment.isEmpty) {
                                Text("No comment")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 10)
                                    .foregroundStyle(.gray)
                            } else {
                                Text("Comment:")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 10)
                                Text(details.comment)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            if (details.isOnline) {
                                Text("Class is online!")
                                    .padding(.top, 10)
                            }
                            
                            if (details.url != "") {
                                if (!details.isOnline) {
                                    Text("URL")
                                        .padding(.top, 10)
                                }
                                Link(details.url, destination: URL(string: details.url)!)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        
                        default:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: borderColor))
                                .padding(.top, 10)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .animation(.easeInOut, value: courseDetailsCache.details[course.idReservation])
                    
                    
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
        .onAppear {
            for course in range.courses {
                Task {
                    await courseDetailsCache.loadDetailsCache(idReservation: course.idReservation)
                }
            }
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
