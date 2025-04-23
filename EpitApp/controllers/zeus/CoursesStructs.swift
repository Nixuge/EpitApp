//
//  CoursesStructs.swift
//  ZeusApp
//
//  Created by Quenting on 03/09/2024.
//

import Foundation
import SwiftUI

let IsoDateFormatter = ISO8601DateFormatter()


struct Room: Decodable {
    let id: Int
    let capacity: Int
    let name: String
    let idRoomType: Int
    let idLocation: Int
    let isVisible: Bool
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        let length = hexSanitized.count

        guard length == 6 || length == 8 else {
            self.init(white: 1.0) // Return white color for invalid format
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgbValue)

        let red, green, blue, alpha: CGFloat
        if length == 6 {
            red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgbValue & 0x0000FF) / 255.0
            alpha = CGFloat(1.0)
        } else {
            red = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            alpha = CGFloat(rgbValue & 0x000000FF) / 255.0
        }

        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}

struct CourseGroup: Decodable {
    let id: Int
//    let idParent: Int //always null?
    let name: String
//    let path: String //not null in details
    let count: Int?
//    let isReadOnly: Bool //not null in details
    let idSchool: Int
    let color: Color
    let isVisible: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case count
        case idSchool
        case color
        case isVisible
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        count = try container.decodeIfPresent(Int.self, forKey: .count)
        idSchool = try container.decode(Int.self, forKey: .idSchool)
        let hexColor = try container.decode(String.self, forKey: .color)
        color = Color(hex: hexColor)
        isVisible = try container.decode(Bool.self, forKey: .isVisible)
    }
}

struct Teacher: Decodable {
    let id: Int
    let name: String
    let firstname: String
//    "mail": null,
//    "isInternal": null / bool,
//    "isPhd": null,
//    "phone": null,
//    "typeId": null,
//    "hourlyRate": null,
//    "code": null
}

//struct Course: Decodable, Identifiable {
struct Course: Decodable, Hashable {

//    var id = UUID()
    let idReservation: Int
    let idCourse: Int? // Note: nullable
    let name: String
    let idType: Int
    let typeName: String
    let startDate: Date
    let endDate: Date
    let isOnline: Bool
    let rooms: [Room]
    let groups: [CourseGroup]
    let teachers: [Teacher]
    let idSchool: Int
    let schoolName: String
//    let constraintGroupId: always null
    
    static func == (lhs: Course, rhs: Course) -> Bool {
        return lhs.idReservation == rhs.idReservation
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(idReservation)
    }
    
    private enum CodingKeys: String, CodingKey {
        case idReservation
        case idCourse
        case name
        case idType
        case typeName
        case startDate
        case endDate
        case isOnline
        case rooms
        case groups
        case teachers
        case idSchool
        case schoolName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        idReservation = try container.decode(Int.self, forKey: .idReservation)
        idCourse = try container.decode(Int?.self, forKey: .idCourse)
        name = try container.decode(String.self, forKey: .name)
        idType = try container.decode(Int.self, forKey: .idType)
        typeName = try container.decode(String.self, forKey: .typeName)
        // DATES
        let startDateStr = try container.decode(String.self, forKey: .startDate)
        startDate = IsoDateFormatter.date(from: startDateStr)!
        let endDateStr = try container.decode(String.self, forKey: .endDate)
        endDate = IsoDateFormatter.date(from: endDateStr)!
        
        isOnline = try container.decode(Bool.self, forKey: .isOnline)
        rooms = try container.decode([Room].self, forKey: .rooms)
        groups = try container.decode([CourseGroup].self, forKey: .groups)
        teachers = try container.decode([Teacher].self, forKey: .teachers)
        idSchool = try container.decode(Int.self, forKey: .idSchool)
        schoolName = try container.decode(String.self, forKey: .schoolName)
    }
    init (from course: Course, startDate: Date, endDate: Date) {
        idReservation = course.idReservation
        idCourse = course.idCourse
        name = course.name
        idType = course.idType
        typeName = course.typeName
        self.startDate = startDate
        self.endDate = endDate
        isOnline = course.isOnline
        rooms = course.rooms
        groups = course.groups
        teachers = course.teachers
        idSchool = course.idSchool
        schoolName = course.schoolName
    }
}
