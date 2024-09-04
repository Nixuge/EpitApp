//
//  CoursesStructs.swift
//  ZeusApp
//
//  Created by Quenting on 03/09/2024.
//

import Foundation

struct Room: Decodable {
    let id: Int
    let capacity: Int
    let name: String
    let idRoomType: Int
    let idLocation: Int
    let isVisible: Bool
}

struct Group: Decodable {
    let id: Int
//    let idParent: Int //always null?
    let name: String
//    let path: String //always null?
    let count: Int?
//    let isReadOnly: Bool //always null?
    let idSchool: Int
    let color: String //TODO: Convert to HexColour type
    let isVisible: Bool
}

struct Teacher: Decodable {
    let id: Int
    let name: String
    let firstname: String
//    "mail": null,
//    "isInternal": null,
//    "isPhd": null,
//    "phone": null,
//    "typeId": null,
//    "hourlyRate": null,
//    "code": null
}

struct Course: Decodable {
    let idReservation: Int
    let idCourse: Int? // Note: nullable
    let name: String
    let idType: Int
    let typeName: String // TODO: enum
    let startDate: String //TODO: date object
    let endDate: String
    let isOnline: Bool
    let rooms: [Room]
    let groups: [Group]
    let teachers: [Teacher]
    let idSchool: Int
    let schoolName: String
//    let constraintGroupId: always null
}

let group = 1
let startDate = "2024-09-01T22:00:00.000Z"
let endDate = "2024-09-08T21:59:59.999Z"

let url = URL(string: "https://zeus.ionis-it.com/api/reservation/filter/displayable?groups=\(group)&startDate=\(startDate)&endDate=\(endDate)")!

func performRequest(auth: String) async throws -> [Course] {
    var request = URLRequest(url: url)
    
    request.addValue(auth, forHTTPHeaderField: "Authorization")
    
    let (data, response) = try await URLSession.shared.data(for: request)
        
    //let jsonData = jsonString.data(using: .utf8)!
    
    //print(String(decoding: data, as: UTF8.self))
    let courses: [Course] = try! JSONDecoder().decode([Course].self, from: data)
    
    return courses
}
