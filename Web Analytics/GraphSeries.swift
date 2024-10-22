//
//  GraphSeries.swift
//  Web Analytics
//
//  Created by Karol Bąk on 21/10/2024.
//

struct GraphSeries : Identifiable {
    var id: String { date }
    let date: String
    let value: Int
    
    static func build(dates: [String], apiData: [DetailsResponse.Series], keyPath: KeyPath<DetailsResponse.Series, Int>) -> [GraphSeries] {
        var result: [GraphSeries] = []
        for date in dates {
            result.append(GraphSeries(date: date, value: apiData.first(where: { $0.date == date })?[keyPath: keyPath] ?? 0))
        }
        return result
    }
}
