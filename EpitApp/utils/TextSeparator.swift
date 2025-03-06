//
//  TextSeparator.swift
//  EpitApp
//
//  Created by Quenting on 06/03/2025.
//

//
//  LoginView.swift
//  ZeusApp
//
//  Created by Quenting on 14/02/2025.
//

import SwiftUI


struct TextSeparator: View {
    let text: String
    let textColor: Color
    let separatorColor: Color
    let separatorHeight: CGFloat
    let sidePadding: CGFloat
    
    init(text: String, separatorColor: Color = .gray, textColor: Color = .gray, separatorHeight: CGFloat = 1, sidePadding: CGFloat = 10) {
        self.text = text
        self.separatorColor = separatorColor
        self.textColor = textColor
        self.separatorHeight = separatorHeight
        self.sidePadding = sidePadding
    }

    var body: some View {
        HStack {
            Rectangle()
                .frame(height: self.separatorHeight)
                .foregroundColor(self.separatorColor)
                .padding(.horizontal, self.sidePadding)
            
            Text(self.text)
                .foregroundColor(self.textColor)
            
            Rectangle()
                .frame(height: self.separatorHeight)
                .foregroundColor(self.separatorColor)
                .padding(.horizontal, self.sidePadding)
        }.frame(maxWidth: .infinity, alignment: .center)
    }
}
