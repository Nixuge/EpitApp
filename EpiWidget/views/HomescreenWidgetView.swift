//
//  HomescreenWidgetView.swift
//  EpitApp
//
//  Created by Quenting on 26/09/2025.
//
import SwiftUI

struct HomescreenWidgetView : View {
    var entry: ViewSizeTimelineProvider.Entry

    var body: some View {
        VStack {
            Text("Date:")
            Text(entry.date.description)

            Text("Updated by \(entry.providerInfo)")
            
            Text("WIP")
        }
    }
}
