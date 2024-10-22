//
//  Page.swift
//  Web Analytics
//
//  Created by Karol Bąk on 19/10/2024.
//

import SwiftyJSON

struct Page: Identifiable, Hashable {
    var id: String { siteTag }
    var name: String
    var siteTag: String
    
    init(json: JSON) {
        let siteTag = json["site_tag"].stringValue
        let name = json["ruleset"]["zone_name"].stringValue
        
        self.name = name
        self.siteTag = siteTag
    }
}
