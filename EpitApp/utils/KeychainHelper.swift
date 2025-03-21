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

    func saveToken(_ token: String?, accountName: String) {
        guard let token = token else {
            deleteToken(accountName: accountName)
            return
        }
        
        guard let data = token.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: accountName,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)

        SecItemAdd(query as CFDictionary, nil)
    }

    func retrieveToken(accountName: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: accountName,
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
