//
//  SelectedIdCache.swift
//  EpitApp
//
//  Created by Quenting on 26/03/2025.
//

import SwiftUI

struct HierarchyNode: Decodable, Identifiable {
    let name: String
    let searchName: String
    let id: Int
    let id_school: Int
    let count: Int
    let id_parent: Int?
    // Actually not nullable, but the list depends on it being nullable to
    // show or not an expand thing.
    let children: [HierarchyNode]?
    
    enum CodingKeys: CodingKey {
        case name
        case id
        case id_school
        case count
        case id_parent
        case children
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.searchName = self.name.lowercased().replacingOccurrences(of: " ", with: "")
        self.id = try container.decode(Int.self, forKey: .id)
        self.id_school = try container.decode(Int.self, forKey: .id_school)
        self.count = try container.decode(Int.self, forKey: .count)
        self.id_parent = try container.decodeIfPresent(Int.self, forKey: .id_parent)
        let childrenTemp = try container.decodeIfPresent([HierarchyNode].self, forKey: .children)
        if (childrenTemp!.isEmpty) {
            self.children = nil
        } else {
            self.children = childrenTemp
        }
    }
    
    init(name: String, id: Int, id_school: Int, count: Int, id_parent: Int?, children: [HierarchyNode]?) {
        self.name = name
        self.searchName = self.name.lowercased().replacingOccurrences(of: " ", with: "")
        self.id = id
        self.id_school = id_school
        self.count = count
        self.id_parent = id_parent
        self.children = children
    }
    
    func cloneChangeChildren(newChildren: [HierarchyNode]?) -> HierarchyNode {
        return HierarchyNode(
            name: self.name,
            id: self.id,
            id_school: self.id_school,
            count: self.count,
            id_parent: self.id_parent,
            children: newChildren
        )
    }
}

struct FavoriteID: Identifiable, Hashable, Encodable, Decodable {
    let name: String
    let id: Int

    var identifiableID: String { "\(name)-\(id)" }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(id)
    }
}


enum SelectedIdCacheLoadingState {
    case def, loading, done, failed
}

class SelectedIdCache: ObservableObject {
    static let shared = SelectedIdCache()
    
    @ObservedObject var zeusAuthModel = ZeusAuthModel.shared
    
    @Published var loadingState: SelectedIdCacheLoadingState = .def
    
    @Published var allIds: [HierarchyNode]?
    @Published var id : Int? {
        didSet {
            UserDefaults.standard.set(id, forKey: "selectedIdCache.id")
        }
    }
    var idString: String? {
        self.id?.description
    }
    
    @Published var favoriteIds: [FavoriteID] = [] {
        didSet {
            if let encoded = try? JSONEncoder().encode(favoriteIds) {
                UserDefaults.standard.set(encoded, forKey: "selectedIdCache.favoriteIds")
                log("Saved: \(favoriteIds.count)")
            }
        }
    }
    
    init() {
        id = UserDefaults.standard.integer(forKey: "selectedIdCache.id")
        
        if let data = UserDefaults.standard.data(forKey: "selectedIdCache.favoriteIds"),
           let decoded = try? JSONDecoder().decode([FavoriteID].self, from: data) {
            favoriteIds = decoded
            log("Loaded: \(favoriteIds.count)")
        } else {
            favoriteIds = [FavoriteID]()
            log("Loaded: empty")
        }
    }
    
    func getIdList(completion: @escaping (Bool) -> Void = {_ in }) {
        if (loadingState == .loading || loadingState == .done) {
            warn("Already done/loading.")
            return
        }
        
        guard let token = zeusAuthModel.token else {
            warn("Token is nil.")
            return
        }
        
        let url = NSURL(string: "https://zeus.ionis-it.com/api/group/hierarchy")
        var request = URLRequest(url: url! as URL, cachePolicy: .reloadIgnoringLocalCacheData)
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let session = URLSession.shared
            
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            guard let res = response as? HTTPURLResponse else {
                warn("failed at HTTPURLResponse step")
                self.loadingState = .failed
                completion(false)
                return
            }

            guard res.statusCode == 200 else {
                warn("failed at  statuscode step: \(res.statusCode)")
                self.loadingState = .failed
                completion(false)
                return
            }
            
            guard let data = data else {
                warn("failed at data unwrap step")
                self.loadingState = .failed
                completion(false)
                return
            }
            
            let nodes: [HierarchyNode]
            do {
                nodes = try JSONDecoder().decode([HierarchyNode].self, from: data)
            } catch {
                warn("failed at JSON decoding step: \(error)")
                self.loadingState = .failed
                completion(false)
                return
            }
            
            log("success")
            self.allIds = nodes
            self.loadingState = .done
            completion(true)
        }
        dataTask.resume()
    }
    
    // ids parameter for recursion
    func searchForName(_ name: String, in ids: [HierarchyNode]) -> [HierarchyNode] {
        let name = name.lowercased().replacingOccurrences(of: " ", with: "")
        
        if (name.isEmpty) {
//            debugLog("Name is empty, returning all !")
            return ids
        }
        
        var shownChilds = [HierarchyNode]()
        for id in ids {
            if let childs = id.children {
//                debugLog("Looking recursive inside \(id.name)")
                let foundsChilds = searchForName(name, in: childs)
                if (!foundsChilds.isEmpty) {
                    shownChilds.append(id.cloneChangeChildren(newChildren: foundsChilds))
                }
            } else {
                if (id.searchName.contains(name)) {
                    shownChilds.append(id)
                }
            }
        
        }
        
//        debugLog("DONE: \(shownChilds)")
        
        return shownChilds
    }
}
