//
//  CourseCache.swift
//  ZeusApp
//
//  Created by Quenting on 17/02/2025.
//

import SwiftUI
import Combine

class CourseCache: ObservableObject {
    @ObservedObject var zeusAuthModel = ZeusAuthModel.shared
    
    // About dates:
    // Dates are really a fucking pain.
    // Imagine a Date object:
    // If i do a date object about eg monday 00:00
    // - If I get its string using formatted(), i get the... proper date
    // - If I get its string using am ISO8601DateFormatter, I get the date relative to GMT (so here -1h)
    // Hence why as of now the key is a string.
    // To get the string as a key from a date, use the "formattedNoTimezone" ("FNT" for short) property.
    
    // Note: Unsure if optimized.
    @Published var courses: [String: (TimeInterval, [CourseRange])] = [:]
    
    // TODO: custom group
    let bestGroup = 426
    
    func buildCourseDictionary(from inputCourses: [Course], startDate: Date, endDate: Date) -> [String: [Course]] {
//        print("Start: " + startDate.FNT)
//        print("End: " + endDate.FNT)
//        print(startDate.formatted())
//        print(endDate.formatted())

        var coursesByDate: [String: [Course]] = [:]
        let calendar = Calendar.current


        // Initialize the dictionary with the date range
        var currentDate = startDate
        while currentDate <= endDate {
            coursesByDate[currentDate.FNT] = []
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        for inputCourse in inputCourses {
            let courseStartDate = inputCourse.startDate
            let courseEndDate = inputCourse.endDate

            let courseStartDay = calendar.startOfDay(for: courseStartDate)
            let courseEndDay = calendar.startOfDay(for: courseEndDate)

            var currentDay = max(startDate, courseStartDay)
            while currentDay <= min(endDate, courseEndDay) {
                print("Processing \(currentDay.FNT) (\(endDate.FNT) - \(courseEndDay.FNT))")
                let currentDayStart = calendar.startOfDay(for: currentDay)
                let currentDayEnd = calendar.date(byAdding: .day, value: 1, to: currentDayStart)!
                
                // Comparaisons seems to be done correctly.
                var startDate = inputCourse.startDate
                if (currentDay > courseStartDay) {
                    startDate = Calendar.current.startOfDay(for: currentDay)
                }
                var endDate = inputCourse.endDate
                if (currentDay < courseEndDay) {
                    endDate = Calendar.current.startOfDay(for: currentDay)
                    endDate = calendar.date(byAdding: .day, value: 1, to: endDate)!.addingTimeInterval(-1)
                }
                                
                let c = Course(from: inputCourse, startDate: startDate, endDate: endDate)
                
                coursesByDate[currentDay.FNT]?.append(c)

                currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay)!
            }
        }
        return coursesByDate
    }
    
    func buildRangesFromDictionary(from input: [String: [Course]]) -> [String: [CourseRange]] {
        var coursesByDate: [String: [CourseRange]] = [:]
        for (date, _) in input {
            coursesByDate[date] = []
        }
        #if DEBUG
        print("Courses by date: \(coursesByDate)")
        #endif
        
        for (date, var courses) in input {
            var currentDateCourseRange: [CourseRange] = []

            courses.sort { $0.startDate < $1.startDate }

            for c in courses {
                currentDateCourseRange.append(
                    CourseRange(
                        startTime: c.startDate.startMinutesFromDay,
                        endTime: c.endDate.startMinutesFromDay,
                        courses: [c])
                )
                // TODO: Change overlaps into multiple courses.
                print("\(c.name) (\(c.startDate.startMinutesFromDay) - \(c.endDate.startMinutesFromDay))")
            }
            print("============================")
        
            
            coursesByDate[date] = currentDateCourseRange
        }

        
        return coursesByDate
    }
    
    func fillInBlanks(from input: [String: [CourseRange]]) -> [String: [CourseRange]] {
        var output: [String: [CourseRange]] = [:]
                
        for (date, var courses) in input {
//            if (!courses.isEmpty && courses[0].start != 0) {
//                courses.insert(CourseRange(startTime: 0, endTime: courses[0].start), at: 0)
//            }
            if (!courses.isEmpty && courses[0].start > 480) { // 480 = 8h
                courses.insert(CourseRange(startTime: 480, endTime: courses[0].start), at: 0)
            }
            var i = 0;
            while i < courses.count-1 {
                if courses[i].end < courses[i+1].start {
                    courses.insert(CourseRange(startTime: courses[i].end, endTime: courses[i+1].start), at: i+1)
                    i += 1
                }
                i += 1
            }
//            if (courses.last != nil && courses.last!.end != 1439) { //1439 = 23h59
//                courses.insert(CourseRange(startTime: courses.last!.end, endTime: 1439), at: courses.count)
//            }
            output[date] = courses
        }
        
        for (_, courses) in output {
            print(courses.count)
        }
        return output
    }
    
    func addSaveTime(from input: [String: [CourseRange]]) -> [String: (TimeInterval, [CourseRange])] {
        let saveTime = Date().timeIntervalSinceReferenceDate
        
        var new: [String: (TimeInterval, [CourseRange])] = [:]
        for (date, courses) in input {
            new[date] = (saveTime, courses)
        }
        return new
    }

    
    func clearAllCourses() {
        self.courses = [:]
    }

    func loadCourses(date: Date) async {
        print("Called !")
        if (self.courses[date.FNT] != nil) {
            // todo: CHECK FOR VALIDITY WITH TIMEINTERVAL
            print("Already valid.")
            return;
        }
        
        // Dates are weird.
        // For the api, we need to query from previous sunday 23:00 to this sunday 22:59:59 (UTC+1?) BUT for the actual thingys we need to get the actual days.
        let calendar = Calendar.current
        let startOfWeek: Date? = calendar.dateInterval(of: .weekOfYear, for: date)?.start
        var endOfWeek: Date? = calendar.dateInterval(of: .weekOfYear, for: date)?.end
        endOfWeek = calendar.date(byAdding: .nanosecond, value: -1000000, to: endOfWeek!)
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        dateFormatter.timeZone = TimeZone(secondsFromGMT: Calendar.current.timeZone.secondsFromGMT())
//        dateFormatter.defaultDate = Date()
//        dateFormatter.dateFormat = "E HH:mm"
//        let convertedDate = dateFormatter.date(from: startOfWeek!)
//        print(convertedDate)
//
//        
        
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // pas peur des nil ici
        let startDateString = isoDateFormatter.string(from: startOfWeek!)
        let endDateString = isoDateFormatter.string(from: endOfWeek!)
        
        
        let url = URL(string: "https://zeus.ionis-it.com/api/reservation/filter/displayable?groups=\(bestGroup)&startDate=\(startDateString)&endDate=\(endDateString)")!
        
        var request = URLRequest(url: url)
        
        request.addValue(zeusAuthModel.token!, forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            //let jsonData = jsonString.data(using: .utf8)!
//            print(String(data: data, encoding: .utf8));
            //print(String(decoding: data, as: UTF8.self))
            let coursesParsed: [Course] = try! JSONDecoder().decode([Course].self, from: data)
//            print(coursesParsed)
//            let coursesOrdered = buildCourseRanges(from: coursesParsed)
            print("===========================================================================================================================================================================================================================================================================================================")

//            print(coursesOrdered.count)
            let res = buildCourseDictionary(
                from: coursesParsed,
                startDate: startOfWeek!,
                endDate: endOfWeek!
            )
            let coursesNoTime = buildRangesFromDictionary(from: res)
            let blanked = fillInBlanks(from: coursesNoTime)
            
            let final = addSaveTime(from: blanked)
            for (date, coursesForDate) in final {
                courses[date] = coursesForDate
            }
        } catch {
            print("FAIL !") // TODO: Handle
        }
    }
}
