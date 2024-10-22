//
//  DetailsResponse.swift
//  Web Analytics
//
//  Created by Karol Bąk on 20/10/2024.
//

import SwiftyJSON

struct DetailsResponse {
    let totals: Totals
    let totalsPrev: Totals
    let series: [Series]
    let refferers: [Metric]
    let paths: [Metric]
    let browsers: [Metric]
    let os: [Metric]
    let device: [Metric]
    let countries: [Metric]
    
    struct Totals {
        let pageViews: Int
        let visits: Int
        
        init(json: JSON) {
            visits = json["sum"]["visits"].intValue
            pageViews = json["count"].intValue
        }
    }
    
    struct Series {
        let pageViews: Int
        let visits: Int
        let date: String
        
        init(json: JSON) {
            visits = json["sum"]["visits"].intValue
            date = json["dimensions"]["ts"].stringValue
            pageViews = json["count"].intValue
        }
    }
    
    struct Metric: Identifiable {
        var id:String { name }
        
        let value: Int
        let name: String
        
        init(json: JSON) {
            name = json["dimensions"]["metric"].stringValue
            value = json["sum"]["visits"].int ?? json["count"].intValue
        }
        
        init(name: String, value: Int) {
            self.name = name
            self.value = value
        }
    }
    
    init(json: JSON) {
        let base = json["data"]["viewer"]["accounts"][0]
        totals = Totals(json: base["totals"][0])
        totalsPrev = Totals(json: base["totalsPrev"][0])
        series = base["series"].arrayValue.map { Series(json: $0) }
        refferers = base["refferers"].arrayValue.map { Metric(json: $0) }
        paths = base["paths"].arrayValue.map { Metric(json: $0) }
        browsers = base["browsers"].arrayValue.map { Metric(json: $0) }
        os = base["os"].arrayValue.map { Metric(json: $0) }
        device = base["device"].arrayValue.map { Metric(json: $0) }
        countries = base["countries"].arrayValue.map { Metric(json: $0) }
    }
}

