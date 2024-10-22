//
//  Graph.swift
//  Web Analytics
//
//  Created by Karol Bąk on 21/10/2024.
//

import SwiftUI
import Charts

struct Graph: View {
    var title: String
    var image: String
    var data: [GraphSeries]
    var total: Int
    var prev: Int
    var color: Color
    
    @State private var chartSelection: Int?
    
    private let periodsHelper = PeriodsHelper()
    
    var body: some View {
        GroupBox(label: Label(title, systemImage: image).foregroundStyle(color)) {
            HStack(alignment: .lastTextBaseline) {
                Text(String(total)).font(.system(size: 26, weight: .bold))
                let diff = difference()
                
                if (diff > 0) {
                    Text(String("+\(diff)%")).font(.subheadline).foregroundStyle(.green)
                } else if (diff < 0) {
                    Text(String("\(diff)%")).font(.subheadline).foregroundStyle(.red)
                } else {
                    Text(String("=\(diff)%")).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
            .opacity(chartSelection == nil ? 1 : 0)
            
            Chart(Array(data.enumerated()), id: \.offset) { index, series in
                LineMark(
                    x: .value("Date", index),
                    y: .value("Value", series.value)
                )
                .foregroundStyle(color)
                
                AreaMark(
                    x: .value("Date", index),
                    y: .value("Value", series.value)
                )
                .foregroundStyle(areaBackground)
                
                if let chartSelection {
                    PointMark(x: .value("Date", chartSelection), y: .value("Value", data[chartSelection].value))
                        .foregroundStyle(color)
                    
                    RuleMark(x: .value("Date", chartSelection))
                        .foregroundStyle(color)
                        .annotation(
                            position: .top,
                            overflowResolution: .init(x: .fit, y: .disabled)
                        ) {
                            VStack {
                                Text(formatDate(data[chartSelection].date)).font(.caption).foregroundStyle(.secondary)
                                Text(String(data[chartSelection].value)).font(.headline).foregroundStyle(.primary)
                            }.offset(x: 0, y: -5)
                        }
                }
            }
            .frame(height: 100)
            .chartXScale(domain: [0, data.count - 1])
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: UIDevice.current.userInterfaceIdiom == .pad ? 7 : 3)) {
                    let index = $0.as(Int.self)!
                    AxisGridLine()
                    AxisValueLabel(formatDate(data[index].date))
                }
            }
            .chartXSelection(value: $chartSelection)
        }
    }
    
    private var areaBackground: Gradient {
        return Gradient(colors: [color.opacity(0.66), color.opacity(0.33)])
    }
    
    private func formatDate(_ value: String) -> String {
        if(value.count > 10) {
            let range = value.index(value.startIndex, offsetBy: 11)..<value.index(value.startIndex, offsetBy: 16)
            return String(value[range])
        }
        return value
    }
    
    private func difference() -> Int {
        let prev = prev == 0 ? 1 : prev
        let diff = Double(total) / Double(prev) - 1
        return Int(diff * 100)
    }
}
