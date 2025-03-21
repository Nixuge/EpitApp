//
//  WebKitUtils.swift
//  EpitApp
//
//  Created by Quenting on 21/03/2025.
//

import Foundation
import WebKit

func deleteAllWebKitCookies() {
    HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
    print("All cookies deleted")

    WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
        records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            print("Cookie ::: \(record) deleted")
        }
    }
}
