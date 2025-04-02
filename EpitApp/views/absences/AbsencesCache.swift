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
    
    let isCurrentPeriod: Bool
    enum CodingKeys: CodingKey {
        case id
        case points
        case grade
        case beginDate
        case endDate
        case absences
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.points = try container.decode(Int.self, forKey: .points)
        self.grade = try container.decode(Int.self, forKey: .grade)
        self.beginDate = try container.decode(String.self, forKey: .beginDate)
        self.endDate = try container.decode(String.self, forKey: .endDate)
        self.absences = try container.decode([Absence].self, forKey: .absences)
        
        // Not really need to put the date in the struct as not used anywhere else.
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = TimeZone.current // Unsure as if should use GMT or current like rn.

        // Parse the date strings into Date objects
        guard let startDate = dateFormatter.date(from: self.beginDate),
              let endDate = dateFormatter.date(from: self.endDate) else {
            errorLog("ERROR INTIALIZING ISCURRENTPERIOD DATE.")
            self.isCurrentPeriod = false
            return
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let endOfEndDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!

        self.isCurrentPeriod = currentDate >= startOfStartDate && currentDate <= endOfEndDate
    }
}

struct AbsencesSemester: Decodable {
//    var id = UUID()
    let levelId: Int
    let semesterId: Int
    let levelName: String
    let promo: Int
    var periods: [AbsencesPeriod]
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
            log("DONE GRABBING: \(success)")
            if (success) {
                self.absencesAuthModel.setValidity(newAuthState: .authentified)
            } else {
                self.absencesAuthModel.loginWithSaved()
            }
        })
    }
    
    func setState(_ newState: AbsencesCacheState) {
        DispatchQueue.main.async {
            self.state = newState
        }
    }
    
    func grabNewContent(completion: @escaping (Bool) -> Void = { _ in }, force: Bool = false) {
        log("request received.")
        
        if (!force && !content.isEmpty) {
            warn("Non empty content and no force, returning.")
            completion(false)
            return
        }
        
        // TODO: Weird things r done here :/
        // check logs while running to understand
//        if (state == .loading) {
//            print("grabNewContent: already loading.")
//            completion(false)
//            return
//        }
        
        guard let token = absencesAuthModel.token else {
            warn("token is nil.")
            completion(false)
            return
        }
        
//        setState(.loading)
        self.state = .loading
        log("State: \(self.state)")
        let url = NSURL(string: "https://absences.epita.net/api/Users/student/grades")
        var request = URLRequest(url: url! as URL, cachePolicy: .reloadIgnoringLocalCacheData)
        request.httpMethod = "GET"
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            guard let res = response as? HTTPURLResponse else {
                self.setState(.loaded)
                completion(false)
                warn("Failed at HTTPURLResponse step")
                return
            }
            guard res.statusCode == 200 else {
                self.setState(.loaded)
                completion(false)
                warn("Failed at statuscode step: \(res.statusCode)")
                return
            }
            guard let data = data else {
                self.setState(.loaded)
                completion(false)
                warn("Failed at data unwrap step")
                return
            }
            
            var semesters: [AbsencesSemester]
            do {
                semesters = try JSONDecoder().decode([AbsencesSemester].self, from: data)
            } catch {
                self.setState(.loaded)
                completion(false)
                warn("Failed at JSON decoding step: \(error)")
                return
            }
            
            log("Done grabbing content.")
            
            // Get the most recent period at the top.
            // Note: Could use a sort for reddundance, but rn a reverse works just fine
            // (by default the website sends first->last, we reverse last->first)
            for i in 0..<semesters.count {
                semesters[i].periods.reverse()
//                semesters[i].periods.sort { $0.beginDate > $1.beginDate }
            }
                        
            DispatchQueue.main.async {
                self.content = semesters
                self.setState(.loaded)
                completion(true)
            }
        }
        dataTask.resume()
    }
}
