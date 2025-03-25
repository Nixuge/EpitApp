//
//  KeychainHelper.swift
//  EpitApp
//
//  Created by Quenting on 06/03/2025.
//


import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()

    func saveValue(_ value: String?, key: String) {
        guard let value = value else {
            deleteToken(accountName: key)
            return
        }
        
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)

        SecItemAdd(query as CFDictionary, nil)
    }

    func retrieveValue(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard let data = dataTypeRef as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func deleteToken(accountName: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: accountName
        ]

        SecItemDelete(query as CFDictionary)
    }
}
