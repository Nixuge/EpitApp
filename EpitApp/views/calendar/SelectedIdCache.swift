//
//  SelectedIdCache.swift
//  EpitApp
//
//  Created by Quenting on 26/03/2025.
//

import SwiftUI

struct HierarchyNode: Decodable, Identifiable {
    let name: String
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

enum SelectedIdCacheLoadingState {
    case def, loading, done, failed
}

class SelectedIdCache: ObservableObject {
    static let shared = SelectedIdCache()
    
    @ObservedObject var zeusAuthModel = ZeusAuthModel.shared
    
    @Published var loadingState: SelectedIdCacheLoadingState = .def
    
    @Published var allIds: [HierarchyNode]?
    @Published var id : String? {
        didSet {
            UserDefaults.standard.set(id, forKey: "selectedIdCache.id")
        }
    }
    
    init() {
       id = UserDefaults.standard.string(forKey: "selectedIdCache.id")
    }
    
    func getIdList(completion: @escaping (Bool) -> Void = {_ in }) {
        if (loadingState == .loading || loadingState == .done) {
            print("Already done/loading.")
            return
        }
        
        guard let token = zeusAuthModel.token else {
            print("Token is nil.")
            return
        }
        
        let url = NSURL(string: "https://zeus.ionis-it.com/api/group/hierarchy")
        var request = URLRequest(url: url! as URL, cachePolicy: .reloadIgnoringLocalCacheData)
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        let session = URLSession.shared
            
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            guard let res = response as? HTTPURLResponse else {
                print("getIdList failed at HTTPURLResponse step")
                self.loadingState = .failed
                completion(false)
                return
            }

            guard res.statusCode == 200 else {
                print("getIdList failed at  statuscode step: \(res.statusCode)")
                self.loadingState = .failed
                completion(false)
                return
            }
            
            guard let data = data else {
                print("getIdList failed at data unwrap step")
                self.loadingState = .failed
                completion(false)
                return
            }
            
            let nodes: [HierarchyNode]
            do {
                nodes = try JSONDecoder().decode([HierarchyNode].self, from: data)
            } catch {
                print("getIdList failed at JSON decoding step: \(error)")
                self.loadingState = .failed
                completion(false)
                return
            }
            
            print("getIdList: success")
            self.allIds = nodes
            self.loadingState = .done
            completion(true)
        }
        dataTask.resume()
    }
    
    // ids parameter for recursion
    func searchForName(_ name: String, in ids: [HierarchyNode]) -> [HierarchyNode] {
        let name = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        print("Called \(#function) with \(ids.count)")
        
        if (name.isEmpty) {
            print("Name is empty, returning all !")
            return ids
        }
        
        var shownChilds = [HierarchyNode]()
        for id in ids {
            if let childs = id.children {
                print("Looking recursive inside \(id.name)")
                let foundsChilds = searchForName(name, in: childs)
                if (!foundsChilds.isEmpty) {
                    shownChilds.append(id.cloneChangeChildren(newChildren: foundsChilds))
                }
            } else {
                if (id.name.lowercased().contains(name)) {
                    shownChilds.append(id)
                }
            }
        
        }
        
        print("DONE: \(shownChilds)")
        
        return shownChilds
    }
}
