//
//  AbsencesCache.swift
//  EpitApp
//
//  Created by Quenting on 20/03/2025.
//

import SwiftUI

struct Absence: Decodable, Identifiable {
    var id = UUID()
    let slotId: Int
    let startDate: Date
    let subjectName: String
    let justificatory: String?
    let mandatory: Bool
    
    
    private enum CodingKeys: String, CodingKey {
        case slotId
        case startDate
        case subjectName
        case justificatory
        case mandatory
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        slotId = try container.decode(Int.self, forKey: .slotId)

        let startDateStr = try container.decode(String.self, forKey: .startDate)
        startDate = IsoDateFormatter.date(from: startDateStr)!

        subjectName = try container.decode(String.self, forKey: .subjectName)
        justificatory = try container.decode(String?.self, forKey: .justificatory)
        mandatory = try container.decode(Bool.self, forKey: .mandatory)
    }
}

struct AbsencesPeriod: Decodable, Identifiable {
    // ID already in the json
    let id: Int
    let points: Int
    let grade: Int
    let beginDate: String
    let endDate: String
    let absences: [Absence]
//    let exclusions: [Exclusion] // No data example to get that :/
}

struct AbsencesSemester: Decodable {
//    var id = UUID()
    let levelId: Int
    let semesterId: Int
    let levelName: String
    let promo: Int
    let periods: [AbsencesPeriod]
}

enum AbsencesCacheState {
    case loading, loaded
}


class AbsencesCache: ObservableObject {
    static let shared = AbsencesCache()

    @ObservedObject var absencesAuthModel = AbsencesAuthModel.shared
    
    @Published var state: AbsencesCacheState = .loading
    @Published var content: [AbsencesSemester] = []
    
    func onAppear() {
        grabNewContent(completion: { (success) in
            print("DONE GRABBING: \(success)")
            if (success) {
                self.absencesAuthModel.setValidity(newAuthState: .authentified)
            } else {
                self.absencesAuthModel.loginWithSaved()
            }
        })
    }
    
    func setState(_ newState: AbsencesCacheState) {
//        DispatchQueue.main.async {
            self.state = newState
//        }
    }
    
    func grabNewContent(completion: @escaping (Bool) -> Void = { _ in }, force: Bool = false) {
        print("grabNewContent request received.")
        
        if (!force && !content.isEmpty) {
            print("grabNewContent: Non empty content and no force, returning.")
            completion(false)
            return
        }
        
        guard let token = absencesAuthModel.token else {
            print("grabNewContent: token is nil.")
            completion(false)
            return
        }
        
//        setState(.loading)
        self.state = .loading
        print("State: \(self.state)")
        let url = NSURL(string: "https://absences.epita.net/api/Users/student/grades")
        var request = URLRequest(url: url! as URL, cachePolicy: .reloadIgnoringLocalCacheData)
        request.httpMethod = "GET"
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            guard let res = response as? HTTPURLResponse else {
                self.setState(.loaded)
                completion(false)
                print("Failed new content grabbing at HTTPURLResponse step")
                return
            }
            guard res.statusCode == 200 else {
                self.setState(.loaded)
                completion(false)
                print("Failed new content grabbing at statuscode step: \(res.statusCode)")
                return
            }
            guard let data = data else {
                self.setState(.loaded)
                completion(false)
                print("Failed new content grabbing at data unwrap step")
                return
            }
            
            let semesters: [AbsencesSemester]
            do {
                semesters = try JSONDecoder().decode([AbsencesSemester].self, from: data)
            } catch {
                self.setState(.loaded)
                completion(false)
                print("Failed new content grabbing at JSON decoding step: \(error)")
                return
            }
            
            print("Done grabbing content.")
//            print(semesters)
            self.content = semesters
            self.setState(.loaded)
            completion(true)
        }
        dataTask.resume()
    }
}
