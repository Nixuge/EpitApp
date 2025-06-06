//
//  FancySheetButton.swift
//  EpitApp
//
//  Created by Quenting on 21/03/2025.
//

import SwiftUI

struct FancySheetButton<Content: View, LabelContent: View>: View {
    var label: () -> LabelContent
    var color: Color = .orange
    var textColor: Color = .white
    var isDisabled: Bool = false

    @State var isPresented: Binding<Bool>

    var action: () -> Void

    var sheetContent: () -> Content
    
    var body: some View {
        Button(action: action) {
            label()
                .font(.headline)
                .padding()
                .background(color)
                .foregroundColor(textColor)
                .cornerRadius(8)
        }
        .sheet(
            isPresented: isPresented,
            content: sheetContent
        )
        .disabled(isDisabled)
    }
}
