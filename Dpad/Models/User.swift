//
//  User.swift
//  Dpad
//
//  Created by Paul Kim on 10/12/22.
//

import Foundation

struct TwitchUser: Codable {
    
    var id: String
    var userName: String
    var clientID: String
    var expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case userName = "login"
        case clientID = "client_id"
        case expiresIn = "expires_in"
    }
    
}
