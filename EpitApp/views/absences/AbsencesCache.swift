//
//  AbsencesCache.swift
//  EpitApp
//
//  Created by Quenting on 20/03/2025.
//

import SwiftUI

struct Absence: Decodable {
//    var id = UUID()
    let slotId: Int
    let startDate: String
    let subjectName: String
    let justificatory: String?
    let mandatory: Bool
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
    
    @Published var state: AbsencesCacheState = .loaded
    @Published var content: [AbsencesSemester] = []
    
    init() {
        // First try to just grab w whathever token is available.
        // If can't grab, try to login w saved logins.
        // Otherwise have user enter password (done through the login screen when authstate isn't valid)
        grabNewContent(completion: { (success) in
            print("DONE GRABBING: \(success)")
            if (success) {
                self.absencesAuthModel.setValidity(newAuthState: .authentified)
            } else {
                self.absencesAuthModel.loginWithSaved()
                // TODO: Rn grabnewcontent is done on onappear in absencesview, could be nice if done here instead.
            }
        })
    }
    
    func setState(_ newState: AbsencesCacheState) {
//        DispatchQueue.main.async {
            self.state = newState
//        }
    }
    
    func grabNewContent(completion: @escaping (Bool) -> Void = { _ in }, force: Bool = false) {
        if (!force && !content.isEmpty) {
            print("grabNewContent: Non empty content and no force, returning.")
            completion(true)
            return
        }
        
        guard let token = absencesAuthModel.token else {
            print("grabNewContent: token is nil.")
            completion(true)
            return
        }
        
        setState(.loading)
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
        print("Ok yes")
        dataTask.resume()
    }
}
