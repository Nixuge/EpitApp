//
//  RandomViewUtils.swift
//  EpitApp
//
//  Created by Quenting on 06/03/2025.
//
import UIKit

func getRootViewController() -> UIViewController? {
    guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
        return nil
    }
    guard let root = screen.windows.first?.rootViewController else {
        return nil
    }
    return root
}
