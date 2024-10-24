//
//  MetricList.swift
//  Web Analytics
//
//  Created by Karol Bąk on 20/10/2024.
//

import SwiftUI

struct MetricList: View {
    var title: String
    var image: String
    var metrics: [DetailsResponse.Metric]
    var color: Color
    
    var body: some View {
        GroupBox(label: Label(title, systemImage: image).foregroundStyle(color)) {
            VStack(alignment: .leading) {
                if metrics.isEmpty {
                    Spacer()
                    Text("No data")
                    Spacer()
                } else {
                    ForEach(metrics) { metric in
                        if metric.value > 0 {
                            VStack {
                                HStack {
                                    Text(metric.name.count > 0 ? metric.name : "None").lineLimit(1).truncationMode(.tail)
                                    Spacer()
                                    Text(String(metric.value)).fontWeight(.semibold)
                                }
                                ProgressView(value: Double(metric.value) / totalValue()).tint(color)
                            }.padding(5)
                        }
                    }
                    Spacer()
                }
            }
        }.frame(minHeight: 200)
    }
    
    func totalValue() -> Double {
        metrics.reduce(0.0) { $0 + Double($1.value) }
    }
}
