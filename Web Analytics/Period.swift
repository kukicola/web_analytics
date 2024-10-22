//
//  Page.swift
//  Web Analytics
//
//  Created by Karol Bąk on 19/10/2024.
//

import Foundation

enum DateFrame: Hashable {
    case datetimeHour
    case date
    
    var stringValue : String {
        switch self {
        case .datetimeHour: return "datetimeHour"
        case .date: return "date"
        }
    }
}

struct Period: Identifiable, Hashable {
    var id: String { name }
    var name: String
    var dateFrame: DateFrame
    var range: () -> [Date]
    
    init(name: String, dateFrame: DateFrame, range: @escaping () -> [Date]) {
        self.name = name
        self.dateFrame = dateFrame
        self.range = range
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Period, rhs: Period) -> Bool {
        return lhs.name == rhs.name
    }
}
