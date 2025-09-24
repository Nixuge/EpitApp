//
//  Success.swift
//  EpitApp
//
//  Created by Quenting on 24/09/2025.
//

import SwiftUI

struct AlarmSuccessView: View {
    var alarmTime: String
    @Binding var isPresented: Bool
    
    @Binding var isParentPresented: Bool
    
    var body: some View {
        VStack {
            Text("Done !")
                .font(.largeTitle)
                .foregroundColor(.green)
                .padding(.top, 50)
            
            Spacer()
            
            Label("Info", systemImage: "clock.badge.checkmark")
                .labelStyle(.iconOnly)
                .foregroundStyle(.green)
                .font(.system(size: 200)) // Adjust the size as needed

                .frame(width: 150, height: 150)
            
            Spacer()
            
            Text("Your alarm for \(alarmTime) has been enabled successfully !")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding(10)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
