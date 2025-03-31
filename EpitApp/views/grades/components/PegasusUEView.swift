//
//  PegasusUEView.swift
//  EpitApp
//
//  Created by Quenting on 20/02/2025.
//

import SwiftUI

struct PegasusUEView: View {
    @Environment(\.colorScheme) var colorScheme

    var ue: PegasusUE

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
//            UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 10, bottomTrailingRadius: 10, topTrailingRadius: 10)
//                .fill(Color.white)
//                .frame(minWidth: 4, idealWidth: 4, maxWidth: 4, maxHeight: .infinity, alignment: .topLeading)
            
            LazyVStack(pinnedViews: .sectionHeaders) {
                Section {
                    VStack {
                        ForEach(ue.ECUEs) { ecue in
                            PegasusECUEView(ecue: ecue)
                        }
                    }
                    .padding(.leading, 5)
                } header: {
                    VStack(spacing: 0) {
                        HStack {
                            Text(ue.label)
                            Text((ue.state?.toString() ?? ""))
                            Text(ue.averageNote != nil ? (String(format: "(%.2f)", ue.averageNote!)) : "")
                        }
                        .padding(5)
                        .font(.headline)
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
//
//                        UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 20, bottomTrailingRadius: 20, topTrailingRadius: 20)
//                            .frame(maxWidth: .infinity, minHeight: 4, maxHeight: 4, alignment: .leading)
//                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(
                        RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
