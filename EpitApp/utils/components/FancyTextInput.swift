//
//  FancyTextField.swift
//  EpitApp
//
//  Created by Quenting on 20/03/2025.
//

import SwiftUI

struct FancyTextInput: View {
    @Binding var text: String
    var placeholder: String = ""
    var cornerRadius: CGFloat = 5
    var color: Color = Color.green
    
    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .textInputAutocapitalization(.never)
            .overlay {
                RoundedRectangle(cornerSize: CGSize(width: cornerRadius, height: cornerRadius))
                    .stroke(color, lineWidth: 1)
            }
            .font(.system(size: 20))
    
    }
}
