//
//  Page.swift
//  Web Analytics
//
//  Created by Karol Bąk on 19/10/2024.
//

import SwiftyJSON

public struct Page: Identifiable, Hashable {
    public var id: String { siteTag }
    public var name: String
    public var siteTag: String
    
    public init(json: JSON) {
        let siteTag = json["site_tag"].stringValue
        let name = json["ruleset"]["zone_name"].stringValue
        
        self.name = name
        self.siteTag = siteTag
    }
}
