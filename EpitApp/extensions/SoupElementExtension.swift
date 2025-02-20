//
//  SoupElementExtension.swift
//  EpitApp
//
//  Created by Quenting on 20/02/2025.
//
import SwiftSoup

extension Element {
    // Useful for debugging
    func textQuoted() throws -> String {
        return "\"\(try self.text())\""
    }
}
