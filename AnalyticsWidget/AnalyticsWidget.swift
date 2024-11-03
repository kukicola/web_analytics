//
//  AnalyticsWidget.swift
//  AnalyticsWidget
//
//  Created by Karol Bąk on 03/11/2024.
//

import WidgetKit
import SwiftUI
import SwiftData

struct AnalyticsWidgetItem : View {
    var title : String
    var value : Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title).font(.caption)
                Spacer()
            }
            Text(String(value))
        }.frame(maxWidth: .infinity)
    }
}

struct AnalyticsWidgetPage : View {
    var page : AnalyticsEntry.PageEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(page.name).font(.headline).foregroundColor(.red).padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
            HStack {
                AnalyticsWidgetItem(title: "Today", value: page.today)
                AnalyticsWidgetItem(title: "Yesterday", value: page.yesterday)
                AnalyticsWidgetItem(title: "Last 7 days", value: page.last7days)
            }
        }
    }
}

struct AnalyticsWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(entry.pages) { page in
                AnalyticsWidgetPage(page: page).padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
            }
        }
    }
}

struct AnalyticsWidget: Widget {
    @Query private var settingsList: [Settings]
    
    let kind: String = "AnalyticsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AnalyticsWidgetEntryView(entry: entry)
                .containerBackground(.windowBackground, for: .widget)

        }
        .configurationDisplayName("Web Analytics")
        .description("Web Analytics widget")
    }
}

#Preview(as: .systemMedium) {
    AnalyticsWidget()
} timeline: {
    AnalyticsEntry(date: Date(), pages: [
        AnalyticsEntry.PageEntry(name: "example.com", today: 3, yesterday: 5, last7days: 40),
        AnalyticsEntry.PageEntry(name: "anything.com", today: 0, yesterday: 1, last7days: 25),
    ])
}
