//
//  PageDetailsView.swift
//  Web Analytics
//
//  Created by Karol Bąk on 19/10/2024.
//

import SwiftUI
import Foundation
import SwiftData

struct PageDetailsView: View {
    @Query private var settingsList: [Settings]
    @Binding var page: Page?
    @Binding var selectedPeriod: Periods
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @Environment(\.scenePhase) var scenePhase
    @State var gridLayout = Constants.oneColumnLayout
    @State private var details: DetailsResponse?
    @State private var isLoading: Bool = true
    
    private let periodsHelper = PeriodsHelper()
    
    enum Constants {
        static let twoColumnLayout = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 0)]
        static let oneColumnLayout = [GridItem(.flexible(), spacing: 0)]
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Constants.oneColumnLayout, spacing: 20) {
                Graph(title: "Visits", image: "person.2.fill", data: GraphSeries.build(dates: periodsHelper.axisValues(selectedPeriod), apiData: details?.series ?? [], keyPath: \.visits), prev: details?.totalsPrev.visits ?? 0, color: .blue)
                Graph(title: "Page Views", image: "eye", data: GraphSeries.build(dates: periodsHelper.axisValues(selectedPeriod), apiData: details?.series ?? [], keyPath: \.pageViews), prev: details?.totalsPrev.pageViews ?? 0, color: .orange)
            }
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
            .opacity(isLoading ? 0.5 : 1)
            
            LazyVGrid(columns: gridLayout, spacing: 20) {
                MetricList(title: "Countries", image: "globe.europe.africa.fill", metrics: mapCountries(details?.countries ?? []), color: .red)
                MetricList(title: "Paths", image: "point.bottomleft.forward.to.point.topright.filled.scurvepath", metrics: details?.paths ?? [], color: .purple)
                MetricList(title: "Refferers", image: "airplane.arrival", metrics: details?.refferers ?? [], color: .cyan)
                MetricList(title: "Browsers", image: "network", metrics: details?.browsers ?? [], color: .green)
                MetricList(title: "OS", image: "bonjour", metrics: details?.os ?? [], color: .teal)
                MetricList(title: "Devices", image: "macbook.and.iphone", metrics: details?.device ?? [], color: .indigo)
            }
            .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
            .opacity(isLoading ? 0.5 : 1)
        }
        .navigationTitle(page?.name ?? "")
        .toolbar {
            Picker("Period", selection: $selectedPeriod) {
                ForEach(Periods.allCases) { period in
                    Text(periodsHelper.get(period).name).tag(period)
                }
            }.id(UUID())
        }
        .onAppear {
            setGridLayout(for: horizontalSizeClass)
            fetchData()
        }
        .onChange(of: selectedPeriod) {
            fetchData()
        }
        .onChange(of: page) {
            fetchData()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                fetchData()
            }
        }
        .refreshable {
            fetchData()
        }
    }
    
    private func setGridLayout(for sizeClass: UserInterfaceSizeClass?) {
        gridLayout = sizeClass == .regular ? Constants.twoColumnLayout : Constants.oneColumnLayout
    }
    
    func fetchData() {
        isLoading = true
        Task {
            do {
                let api = API(settings: settingsList.first!)
                details = try await api.fetchPage(page: page!, period: periodsHelper.get(selectedPeriod))
            } catch {}
            isLoading = false
        }
    }
    
    func mapCountries(_ list: [DetailsResponse.Metric]) -> [DetailsResponse.Metric] {
        let current = Locale(identifier: "en")
        return list.map { DetailsResponse.Metric.init(name: current.localizedString(forRegionCode: $0.name)!, value: $0.value) }
    }
}
