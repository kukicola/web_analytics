//
//  ContentView.swift
//  Web Analytics
//
//  Created by Karol Bąk on 19/10/2024.
//

import SwiftUI
import SwiftData

struct AlertItem: Identifiable {
    let id = UUID()
    let body: String
}

struct ContentView: View {
    @Query private var settingsList: [Settings]
    @State private var pages: [Page] = []
    @State private var alert: AlertItem?
    @State private var loaded = false
    @State private var settings: Settings?
    
    var body: some View {
        ZStack {
            if(settings == nil) {
                NavigationStack {
                    SettingsView(settings: $settings)
                }
            } else if(loaded) {
                MainView(pages: $pages)
            } else {
                ProgressView()
                    .task { await fetchAllPages() }
            }
        }
        .alert(item: $alert) { alert in
            Alert(title: Text(alert.body))
        }
        .task {
            settings = settingsList.first
        }
    }
    
    private func fetchAllPages() async {
        loaded = false
        
        if settings == nil {
            return
        }
        
        do {
            let api = API(settings: settings!)
            pages = try await api.fetchPageList()
        } catch {
            alert = AlertItem(body: "Error fetching data")
        }
        
        loaded = true
    }
}
