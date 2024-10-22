//
//  Web_AnalyticsApp.swift
//  Web Analytics
//
//  Created by Karol Bąk on 19/10/2024.
//

import SwiftUI
import SwiftData

@main
struct Web_AnalyticsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Settings.self])
        }
    }
}
