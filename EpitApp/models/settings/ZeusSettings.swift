//
//  ZeusSettings.swift
//  EpitApp
//
//  Created by Quenting on 06/03/2025.
//
import SwiftUI

class ZeusSettings: ObservableObject {
    static let shared = ZeusSettings()
    @Published public var shouldUseOfficeTokenToLogin: Bool {
        didSet {
            UserDefaults.standard.set(shouldUseOfficeTokenToLogin, forKey: "zeusSettings.shouldUseOfficeTokenToLogin")
        }
    }
        
    init() {
        self.shouldUseOfficeTokenToLogin = UserDefaults.standard.bool(forKey: "zeusSettings.shouldUseOfficeTokenToLogin")
    }
}
