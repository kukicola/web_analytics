//
//  MainView.swift
//  Web Analytics
//
//  Created by Karol Bąk on 20/10/2024.
//

import SwiftUI

struct MainView: View {
    @Binding var pages: [Page]
    @State private var currentPage: Page?
    
    var body: some View {
        NavigationSplitView {
            List(pages, selection: $currentPage) { page in
                NavigationLink(page.name, value: page)
            }
            .navigationTitle("Pages")
        }
        detail: {
            if currentPage != nil {
                PageDetailsView(page: $currentPage)
            }
        }
        .task {
            if currentPage == nil && UIDevice.current.userInterfaceIdiom == .pad {
                currentPage = pages.first
            }
        }
    }
}
