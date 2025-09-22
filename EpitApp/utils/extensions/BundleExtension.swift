//
//  BundleExtension.swift
//  EpitApp
//
//  Created by Quenting on 20/09/2025.
//

import SwiftUI

// Thanks to https://www.repeato.app/how-to-retrieve-app-version-and-build-number-in-swift/
extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
