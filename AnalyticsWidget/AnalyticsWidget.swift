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
    var prev : Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title).font(.caption).foregroundStyle(.secondary)
                Spacer()
            }
            HStack(alignment: .lastTextBaseline) {
                Text(String(value))
                
                let diff = difference()
                
                if (diff > 0) {
                    Text(String("+\(diff)%")).font(.caption).foregroundStyle(.green)
                } else if (diff < 0) {
                    Text(String("\(diff)%")).font(.caption).foregroundStyle(.red)
                } else {
                    Text(String("=\(diff)%")).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }
        }.frame(maxWidth: .infinity)
    }
    
    private func difference() -> Int {
        let prev = prev == 0 ? 1 : prev
        let diff = Double(value) / Double(prev) - 1
        return Int((diff * 100).rounded())
    }
}

struct AnalyticsWidgetPage : View {
    var page : AnalyticsEntry.PageEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(page.name).font(.headline).padding(EdgeInsets(top: 0, leading: 0, bottom: 1, trailing: 0))
            HStack {
                AnalyticsWidgetItem(title: "Today", value: page.today, prev: page.yesterday)
                AnalyticsWidgetItem(title: "Yesterday", value: page.yesterday, prev: page.yesterdayPrev)
                AnalyticsWidgetItem(title: "Last 7 days", value: page.last7Days, prev: page.last7DaysPrev)
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
        AnalyticsEntry.PageEntry(name: "example.com", today: 3, yesterday: 5, yesterdayPrev: 6, last7Days: 40, last7DaysPrev: 40),
        AnalyticsEntry.PageEntry(name: "anything.com", today: 0, yesterday: 1, yesterdayPrev: 6, last7Days: 25, last7DaysPrev: 40),
    ])
}
