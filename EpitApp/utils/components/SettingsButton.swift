//
//  FancyButton.swift
//  EpitApp
//
//  Created by Quenting on 21/03/2025.
//

import SwiftUI

struct SettingsButton: View {
    var text: String
    var color: Color = .white
    var isDisabled: Bool = false
    var disabledColor: Color = .gray
    var action: () -> Void
    
    var body: some View {
        let actualColor = isDisabled ? disabledColor : color
        Button(action: action) {
            HStack(spacing: 0) {
                RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                    .frame(width: 20, height: 20)
                    .foregroundStyle(actualColor)
                Text(text)
                    .font(.headline)
                    .padding(10)
                    .foregroundColor(actualColor)
                    .cornerRadius(8)
            }

        }
        .disabled(isDisabled)
    }
}
