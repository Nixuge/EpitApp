//
//  AbsencesCache.swift
//  EpitApp
//
//  Created by Quenting on 20/03/2025.
//

import SwiftUI



struct VersionEntry: Codable {
    let version: String
    let importantUpdate: Bool
    let changelog: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        version = try container.decode(String.self)
        importantUpdate = try container.decode(Bool.self)
        changelog = try container.decode(String.self)
    }
}

class Updater: ObservableObject {
    static let shared = Updater()
    
    public final var appVersion: String
    
    @Published var updateAlertShown = false
    
    @Published public var newAppVersions : [VersionEntry] = []
    @Published var upToDate: Bool? = nil
    
    init () {
        appVersion = Bundle.main.releaseVersionNumber ?? "0.0.0"
    }
    
    func grabUpdateVersions() async {
        let url = NSURL(string: "https://cdn.nixuge.me/epitapp/versions.json")
        
        var request = URLRequest(url: url! as URL, cachePolicy: .reloadIgnoringLocalCacheData)
        request.httpMethod = "GET"
                
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            guard let res = response as? HTTPURLResponse else {
                warn("Failed at HTTPURLResponse step")
                return
            }
            guard res.statusCode == 200 else {
                warn("Failed at statuscode step: \(res.statusCode)")
                return
            }
            guard let data = data else {
                warn("Failed at data unwrap step")
                return
            }
            
            do {
                let appVersions = try JSONDecoder().decode([VersionEntry].self, from: data)
                let currentComponents = self.appVersion.components(separatedBy: ".").compactMap { Int($0) }

                var showAlert = false
                var upToDate = true

                for version in appVersions {
                    let versionComponents = version.version.components(separatedBy: ".").compactMap { Int($0) }

                    // Pad with zeros if necessary to ensure equal length for comparison
                    let maxLength = max(versionComponents.count, currentComponents.count)
                    let paddedVersion = versionComponents + Array(repeating: 0, count: maxLength - versionComponents.count)
                    let paddedCurrent = currentComponents + Array(repeating: 0, count: maxLength - currentComponents.count)

                    // Compare each component numerically
                    let isNewer = paddedVersion.lexicographicallyPrecedes(paddedCurrent) { $0 > $1 }
                    //info("Comp: \(version.version) vs \(currentVersionString), res: \(isNewer)")

                    if isNewer {
                        self.newAppVersions.append(version)
                        upToDate = false
                        if version.importantUpdate { showAlert = true }
                    }
                }
                
                if (showAlert) { self.updateAlertShown = true }
                self.upToDate = upToDate
                info("Done grabbing update versions! \(self.updateAlertShown) / \(String(describing: self.upToDate))")
            } catch {
                warn("Failed at JSON decoding step: \(error)")
                return
            }
            
        }
        dataTask.resume()
    }
    
    func getUpdatePopupTitle() -> String {
        if (newAppVersions.count < 2) {
            return "You're missing some update"
        }
        
        return "You're missing some updates"
    }
    
    func getUpdatePopupString() -> String {
        if (newAppVersions.isEmpty) {
            return "No new app version seem to be listed."
        }
        
        var str = ""
        for version in newAppVersions {
            str += "v\(version.version)"
            if (version.importantUpdate) { str += " (IMPORTANT)" }
            
            let changelogStr = (version.changelog == "") ? "No changelog" : version.changelog
            str += "\n\(changelogStr)\n\n"
        }
        str = str.trimmingCharacters(in: .whitespacesAndNewlines)
        return str
    }
}
