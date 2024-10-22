//
//  ContentView.swift
//  Web Analytics
//
//  Created by Karol Bąk on 19/10/2024.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext;
    @Binding var settings: Settings?
    @State private var accountID: String = ""
    @State private var token: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Cloudflare")) {
                LabeledContent {
                    TextField("Account ID", text: $accountID)
                } label: {
                    Text("Account ID")
                }
                LabeledContent {
                    TextField("Token", text: $token)
                } label: {
                    Text("Token")
                }
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
            }
        }
        .task {
            accountID = settings?.accountID ?? ""
            token = settings?.token ?? ""
        }
    }
    
    private func save() {
        if let settings {
            settings.accountID = accountID
            settings.token = token
        } else {
            settings = Settings(accountID: accountID, token: token)
            modelContext.insert(settings!)
        }
        try? modelContext.save()
    }
}
