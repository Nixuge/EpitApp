//
//  ColorExtension.swift
//  EpitApp
//
//  Created by Quenting on 21/03/2025.
//

import SwiftUI

var _pegasusBackgroundColor = Color.init(hex: "1A51F4")
var _pegasusTextColor = Color.init(hex: "2597fa")

extension Color {
    static var pegasusBackgroundColor : Color {
        return _pegasusBackgroundColor
    }
    static var pegasusTextColor : Color {
        return _pegasusTextColor
    }
}
