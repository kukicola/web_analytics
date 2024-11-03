//
//  Provider.swift
//  Web Analytics
//
//  Created by Karol Bąk on 03/11/2024.
//
import WidgetKit
import SwiftUI
import SwiftData

struct AnalyticsEntry: TimelineEntry {
    let date: Date
    let pages: [PageEntry]
    
    struct PageEntry : Identifiable {
        var id:String { name }
        
        let name: String
        let today: Int
        let yesterday: Int
        let yesterdayPrev: Int
        let last7Days: Int
        let last7DaysPrev: Int
    }
}

struct Provider: TimelineProvider {
    let schema = Schema([Settings.self])

    
    private let placeholderEntry =  AnalyticsEntry(date: Date(), pages: [
        AnalyticsEntry.PageEntry(name: "example.com", today: 3, yesterday: 5, yesterdayPrev: 6, last7Days: 40, last7DaysPrev: 40),
        AnalyticsEntry.PageEntry(name: "anything.com", today: 0, yesterday: 1, yesterdayPrev: 6, last7Days: 25, last7DaysPrev: 40),
    ])
    
    func placeholder(in context: Context) -> AnalyticsEntry {
        return placeholderEntry;
    }

    func getSnapshot(in context: Context, completion: @escaping (AnalyticsEntry) -> ()) {
        completion(placeholderEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AnalyticsEntry>) -> ()) {
        Task{
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let fetchDescriptor = FetchDescriptor<Settings>()
            let settings = try! await modelContainer.mainContext.fetch(fetchDescriptor).first!
            let api = API(settings: settings)
            let pages = try await api.fetchPageList()
            let totals = try await api.fetchTotals()
            
            let entry = AnalyticsEntry(date: Date(), pages: pages.map { page in
                AnalyticsEntry.PageEntry(
                    name: page.name,
                    today: totals.today.first { page.siteTag == $0.siteTag }?.visits ?? 0,
                    yesterday: totals.yesterday.first { page.siteTag == $0.siteTag }?.visits ?? 0,
                    yesterdayPrev: totals.yesterdayPrev.first { page.siteTag == $0.siteTag }?.visits ?? 0,
                    last7Days: totals.last7Days.first { page.siteTag == $0.siteTag }?.visits ?? 0,
                    last7DaysPrev: totals.last7DaysPrev.first { page.siteTag == $0.siteTag }?.visits ?? 0
                )
            })
            
            let timeline = Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .hour, value: 1, to: Date())!))
            completion(timeline)
        }
    }
}
