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
    @Published public var alarmHoursBeforeClass: Int {
        didSet {
            UserDefaults.standard.set(alarmHoursBeforeClass, forKey: "zeusSettings.alarmHoursBeforeClass")
        }
    }
    @Published public var alarmMinutesBeforeClass: Int {
        didSet {
            UserDefaults.standard.set(alarmMinutesBeforeClass, forKey: "zeusSettings.alarmMinutesBeforeClass")
        }
    }
    @Published public var hideClassesEndingWith: String {
        didSet {
            UserDefaults.standard.set(hideClassesEndingWith, forKey: "zeusSettings.hideClassesEndingWith")
        }
    }
        
    init() {
        self.shouldUseOfficeTokenToLogin = UserDefaults.standard.bool(forKey: "zeusSettings.shouldUseOfficeTokenToLogin")
        self.alarmHoursBeforeClass = UserDefaults.standard.integer(forKey: "zeusSettings.alarmHoursBeforeClass")
        self.alarmMinutesBeforeClass = UserDefaults.standard.integer(forKey: "zeusSettings.alarmMinutesBeforeClass")
        self.hideClassesEndingWith = UserDefaults.standard.string(forKey: "zeusSettings.hideClassesEndingWith") ?? ""
    }
}
