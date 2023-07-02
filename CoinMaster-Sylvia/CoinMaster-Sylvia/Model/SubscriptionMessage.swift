//
//  SubscriptionMessage.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/1.
//

import Foundation

struct SubscriptionMessage: Codable {
    let type: String
    let productIds: [String]
    let channels: [String]
    
    enum CodingKeys: String, CodingKey {
        case type
        case productIds = "product_ids"
        case channels
    }
}
