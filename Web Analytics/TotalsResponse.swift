//
//  DetailsResponse.swift
//  Web Analytics
//
//  Created by Karol Bąk on 20/10/2024.
//

import SwiftyJSON

struct TotalsResponse {
    let today: [Item]
    let yesterday: [Item]
    let yesterdayPrev: [Item]
    let last7Days: [Item]
    let last7DaysPrev: [Item]
    
    struct Item {
        let siteTag: String
        let visits: Int
        
        init(json: JSON) {
            visits = json["sum"]["visits"].intValue
            siteTag = json["dimensions"]["siteTag"].stringValue
        }
    }
    
    init(json: JSON) {
        let base = json["data"]["viewer"]["accounts"][0]
        today = base["today"].arrayValue.map { Item(json: $0) }
        yesterday = base["yesterday"].arrayValue.map { Item(json: $0) }
        yesterdayPrev = base["yesterdayPrev"].arrayValue.map { Item(json: $0) }
        last7Days = base["last7Days"].arrayValue.map { Item(json: $0) }
        last7DaysPrev = base["last7DaysPrev"].arrayValue.map { Item(json: $0) }
    }
}

