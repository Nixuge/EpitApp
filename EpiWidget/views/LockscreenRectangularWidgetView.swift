//
//  LockscreenRectangularWidgetView.swift
//  EpitApp
//
//  Created by Quenting on 26/09/2025.
//

import WidgetKit
import SwiftUI

struct LockscreenRectangularWidgetView: View {
    var entry: ViewSizeTimelineProvider.Entry
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AccessoryWidgetBackground()
                    .cornerRadius(8)
                GeometryReader { geometry in
//                    Text("\(Int(geometry.size.width)) x \(Int(geometry.size.height)). Date: \(entry.date.description)")
//                        .font(.headline)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Text("\(entry.date.description) - \(entry.providerInfo)")
                }
            }
        }
    }
}
