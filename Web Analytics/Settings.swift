//
//  Settings.swift
//  Web Analytics
//
//  Created by Karol Bąk on 19/10/2024.
//

import SwiftData

@Model
class Settings {
    var accountID: String
    var token: String
    
    init(accountID: String, token: String) {
        self.accountID = accountID
        self.token = token
    }
}
