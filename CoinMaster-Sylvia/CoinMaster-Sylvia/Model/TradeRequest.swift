//
//  TradeRequest.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/5.
//

import Foundation

struct TradeRequest: Codable {
    let id: String
    let price: String?
    let size: String
    let productId: String
    let side: String
    let stp: String
    let type: String
    let timeInForce: String
    let postOnly: Bool
    let createdAt: String
    let fillFees: String
    let filledSize: String
    let executedValue: String
    let status: String
    let settled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case price
        case size
        case productId = "product_id"
        case side
        case stp
        case type
        case timeInForce = "time_in_force"
        case postOnly = "post_only"
        case createdAt = "created_at"
        case fillFees = "fill_fees"
        case filledSize = "filled_size"
        case executedValue = "executed_value"
        case status
        case settled
    }
}
