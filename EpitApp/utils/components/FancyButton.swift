//
//  FancyButton.swift
//  EpitApp
//
//  Created by Quenting on 21/03/2025.
//

import SwiftUI

struct FancyButton: View {
    var text: String
    var color: Color = .orange
    var textColor: Color = .white
    var isDisabled: Bool = false
    var disabledColor: Color = .gray
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.headline)
                .padding()
                .background(isDisabled ? disabledColor : color)
                .foregroundColor(textColor)
                .cornerRadius(8)
        }
        .disabled(isDisabled)
    }
}
