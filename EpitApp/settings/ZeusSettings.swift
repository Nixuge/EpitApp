//
//  ZeusSettings.swift
//  EpitApp
//
//  Created by Quenting on 06/03/2025.
//
import SwiftUI

class ZeusSettings: ObservableObject {
    static let shared = ZeusSettings()
    @Published public var shouldUseOfficeTokenToLogin: Bool
        
    init() {
        self.shouldUseOfficeTokenToLogin = false
    }
}
