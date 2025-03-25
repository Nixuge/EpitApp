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

func deleteCookieForDomain(_ domain: String) {
    HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

    let dateStore = WKWebsiteDataStore.default()
    dateStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
        records.forEach { record in
            if (record.displayName == domain) {
                dateStore.removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("Cookie ::: \(record) deleted")
            }
        }
    }
}
