//
//  PeriodsHelper.swift
//  Web Analytics
//
//  Created by Karol Bąk on 20/10/2024.
//

import Foundation

enum Periods: String, CaseIterable, Identifiable {
    var id: String { return self.rawValue }
    
    case today, yesterday, last7Days, last30Days
}

struct PeriodsHelper {
    var periodsList: [Periods: Period] {
        return [
            Periods.today: Period(name: "Today", dateFrame: .datetimeHour) {
                let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
                return [
                    Date(),
                    Date(),
                    yesterday,
                    yesterday
                ]
            },
            Periods.yesterday: Period(name: "Yesterday", dateFrame: .datetimeHour) {
                let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
                let dayBefore = calendar.date(byAdding: .day, value: -2, to: Date())!
                return [
                    yesterday,
                    yesterday,
                    dayBefore,
                    dayBefore
                ]
            },
            Periods.last7Days: Period(name: "Last 7 Days", dateFrame: .date) {
                return [
                    calendar.date(byAdding: .day, value: -7, to: Date())!,
                    calendar.date(byAdding: .day, value: -1, to: Date())!,
                    calendar.date(byAdding: .day, value: -14, to: Date())!,
                    calendar.date(byAdding: .day, value: -8, to: Date())!
                ]
            },
            Periods.last30Days: Period(name: "Last 30 Days", dateFrame: .date) {
                return [
                    calendar.date(byAdding: .day, value: -30, to: Date())!,
                    calendar.date(byAdding: .day, value: -1, to: Date())!,
                    calendar.date(byAdding: .day, value: -60, to: Date())!,
                    calendar.date(byAdding: .day, value: -31, to: Date())!
                ]
            },
        ]
    }
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }
    var dateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")!
        return formatter
    }
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }
    
    func get(_ period: Periods) -> Period {
        return periodsList[period]!;
    }
    
    func axisValues(_ period: Periods) -> [String] {
        var result = [String]()
        let realPeriod = get(period)
        let range = realPeriod.range()
        var item = range[0]
        
        if realPeriod.dateFrame == DateFrame.date {
            while item <= range[1] {
                let dateString = dateFormatter.string(from: item)
                item = calendar.date(byAdding: .day, value: 1, to: item)!
                result.append(dateString)
            }
        } else {
            item = calendar.startOfDay(for: range[0])
            let end = calendar.date(byAdding: .day, value: 1, to: item)!
            while item < end && item < Date() {
                let dateString = dateTimeFormatter.string(from: item)
                item = calendar.date(byAdding: .hour, value: 1, to: item)!
                result.append(dateString)
            }
        }
        
        return result
    }
}
