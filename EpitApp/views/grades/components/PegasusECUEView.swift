//
//  PegasusECUEView.swift
//  EpitApp
//
//  Created by Quenting on 21/02/2025.
//


import SwiftUI

struct PegasusECUEView: View {
    var ecue: PegasusECUE
    
    let color = Color.orange
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(spacing: 5) {
                Section {
                    Text(ecue.label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(5)
//                        .foregroundStyle(Color.black)
                        .background(
                            RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                                .foregroundStyle(Color.init(hex: "fa4811"))
                            // ff7d54 and ff6130 are pretty nice (ff3c00)
                        )
                    
//                    Rectangle()
//                        .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1, alignment: .leading)
//                        .foregroundStyle(color)
                    
                    if (ecue.inner[0].grades.isEmpty) {
                        Text("No grades").foregroundStyle(Color.gray)
                            .padding(5)
                    } else {
                        ForEach(ecue.inner[0].grades) { grade in
                            HStack(spacing: 8) {
                                Text("\(grade.noteType): \(grade.note.displayableString())")
                                Text("\(grade.date)")
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    .foregroundColor(.gray)
                            }
                            .padding(5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
//                    Rectangle()
//                        .fill(.gray)
//                        .frame(height: 5)
//                        .edgesIgnoringSafeArea(.horizontal)

                }
            }
//            .overlay(
//                RoundedRectangle(cornerRadius: 5)
//                    .stroke(color, lineWidth: 1)
//            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
//            .padding(5)   
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
