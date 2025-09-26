//
//  EpiWidgetBundle.swift
//  EpiWidget
//
//  Created by Quenting on 24/09/2025.
//

import WidgetKit
import SwiftUI

// MARK: - The Timeline Entry
struct ViewSizeEntry: TimelineEntry {
    let date: Date
    let providerInfo: String
}



// MARK: - The Widget View
struct EpiWidgetWrapperView : View {
    let entry: ViewSizeTimelineProvider.Entry

    // Obtain the widget family value
    @Environment(\.widgetFamily)
    var family

    var body: some View {

        switch family {
        case .accessoryRectangular:
            LockscreenRectangularWidgetView(entry: entry)
        case .accessoryCircular:
            Text("EpiWidget Unavailable")
        case .accessoryInline:
            Text("EpiWidget Unavailable")
        default:
            HomescreenWidgetView(entry: entry)
        }
    }
}

// MARK: - The Timeline Provider
struct ViewSizeTimelineProvider: TimelineProvider {
    
    typealias Entry = ViewSizeEntry
    
    func placeholder(in context: Context) -> Entry {
        // This data will be masked
        return ViewSizeEntry(date: Date(), providerInfo: "placeholder")
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = ViewSizeEntry(date: Date(), providerInfo: "snapshot")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = ViewSizeEntry(date: Date(), providerInfo: "timeline")
        let date = Calendar.current.date(byAdding: .second, value: 60*5+10, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(date))
        completion(timeline)
    }
}

// MARK: - The Widget Configuration
@main
struct EpiWidget: Widget {
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "me.nixuge.EpiWidget",
            provider: ViewSizeTimelineProvider()
        ) { entry in
            EpiWidgetWrapperView(entry: entry)
        }
        .configurationDisplayName("View Size Widget")
        .description("This is a demo widget.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryRectangular,
        ])
    }
}
