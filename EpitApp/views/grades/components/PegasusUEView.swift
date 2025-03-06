//
//  PegasusUEView.swift
//  EpitApp
//
//  Created by Quenting on 20/02/2025.
//

import SwiftUI

struct PegasusUEView: View {
    @ObservedObject var jankOffsetter: JankOffsetter
    var ue: PegasusUE

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10, bottomTrailingRadius: 10, topTrailingRadius: 10)
                .fill(Color.white)
                .frame(minWidth: 4, idealWidth: 4, maxWidth: 4, maxHeight: .infinity, alignment: .topLeading)
                .padding(.leading, 5)
            
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                Section {
                    VStack {
                        ForEach(ue.ECUEs) { ecue in
                            PegasusECUEView(jankOffsetter: jankOffsetter, ecue: ecue)
                        }
                    }
                    .padding(.top, 40)
                } header: {
                    GeometryReader { geometry in
                        let maxY = geometry.frame(in: .global).maxY

                        VStack(spacing: 0) {
                            HStack {
                                Text(ue.label)
                                Text((ue.state?.toString() ?? ""))
                                Text(ue.averageNote != nil ? (String(format: "(%.2f)", ue.averageNote!)) : "")
    //                            Text("\(geometry.frame(in: .global).minY)")
//                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(5)
                            UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 20, topTrailingRadius: 20)
                                .frame(maxWidth: .infinity, minHeight: 4, maxHeight: 4, alignment: .leading)
                                .foregroundStyle(.white)
                        }
      
                        .background(Color.black)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
//                        .onChange(of: maxY) { newMaxY in
                            // For some reason, geometry.size.height seems to be half the actual size.
//                            let size = geometry.size.height * 2
//                            jankOffsetter.ueHeaderBottomY = maxY + size + 10 // + offset
//                        }
                        .offset(y: geometry.frame(in: .global).minY > jankOffsetter.semesterHeaderBottomY ? 0 : jankOffsetter.semesterHeaderBottomY - geometry.frame(in: .global).minY)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 10)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
