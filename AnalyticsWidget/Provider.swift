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
        let last7days: Int
    }
}

struct Provider: TimelineProvider {
    let schema = Schema([Settings.self])

    
    private let placeholderEntry =  AnalyticsEntry(date: Date(), pages: [
        AnalyticsEntry.PageEntry(name: "example.com", today: 3, yesterday: 5, last7days: 40),
        AnalyticsEntry.PageEntry(name: "anything.com", today: 0, yesterday: 1, last7days: 25),
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
            
            let entry = AnalyticsEntry(date: Date(), pages: pages.map { AnalyticsEntry.PageEntry(name: $0.name, today: 1, yesterday: 2, last7days: 3) })
            
            let timeline = Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .hour, value: 1, to: Date())!))
            completion(timeline)
        }
    }
}
