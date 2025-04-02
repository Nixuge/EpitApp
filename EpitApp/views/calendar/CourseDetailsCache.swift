//
//  CourseDetailsCache.swift
//  EpitApp
//
//  Created by Quenting on 01/04/2025.
//

//struct CourseRoomBroadcast: Decodable {
//    let room: Room
//    let isBroadcastRoom: Bool
//}

struct CourseDetails: Decodable, Hashable {
    let idReservation: Int
    let idCourse: Int?
    let name: String
    let idType: Int
    let startDate: String
    let endDate: String
    let isOnline: Bool
    let url: String
    let comment: String
    let creationDate: String
    let code: String
    let duration: Int
    let idSchool: Int
    
    // Not really needed below as already there in the other struct.
//    let rooms: [CourseRoomBroadcast]
//    let groups: [CourseGroup]
//    let teachers: [Teacher]
    
}

enum CourseDetailStatus {
    case loading, loaded(CourseDetails), failed(String)
}


import SwiftUI
import Combine

class CourseDetailsCache: ObservableObject {
    static let shared = CourseDetailsCache()

    @ObservedObject var zeusAuthModel = ZeusAuthModel.shared
    
    @Published var details: [Int: CourseDetailStatus] = [:]

    func clearAll() {
        self.details = [:]
    }

    func loadDetailsCache(idReservation: Int) async {
        print("Called !")
                
        if case .loaded(_) = self.details[idReservation] {
            // todo: CHECK FOR VALIDITY WITH TIMEINTERVAL
            print("Already valid.")
            return;
        }

        guard let token = zeusAuthModel.token else {
            print("Token is nil.")
            return
        }
        
        let url = URL(string: "https://zeus.ionis-it.com/api/reservation/\(idReservation)/details")!
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        request.httpMethod = "GET"
        
        request.addValue(token, forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            guard let res = response as? HTTPURLResponse else {
                self.details[idReservation] = .failed("Couldn't get an HTTPURLResponse")
                print("Failed CourseDetailsCache grabbing at HTTPURLResponse step")
                return
            }
            guard res.statusCode == 200 else {
                self.details[idReservation] = .failed("Wrong statuscode")
                print("Failed CourseDetailsCache grabbing at statuscode step: \(res.statusCode)")
                return
            }
            guard let data = data else {
                self.details[idReservation] = .failed("Couldn't unwrap data.")
                print("Failed CourseDetailsCache grabbing at data unwrap step")
                return
            }
            
            let detailsParsed: CourseDetails
            do {
                detailsParsed = try JSONDecoder().decode(CourseDetails.self, from: data)
            } catch {
                self.details[idReservation] = .failed("Couldn't deode json")
                print("Failed CourseDetailsCache grabbing at JSON decoding step: \(error)")
                return
            }
            
            print("Done grabbing content.")
            print(detailsParsed)

            self.details[idReservation] = .loaded(detailsParsed)
        }
        print("Ok yes")
        dataTask.resume()
    }
}
