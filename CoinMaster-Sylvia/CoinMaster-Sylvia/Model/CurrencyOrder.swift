//
//  CurrencyOrder.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/2.
//

import Foundation

struct CurrencyOrder: Codable {
    let id, price, size, productId, profileId: String
    let side, type, timeInForce, createdAt, doneAt: String
    let postOnly, settled: Bool
    let doneReason, fillFees, filledSize: String
    let executedValue, marketType, status: String

    private enum CodingKeys: String, CodingKey {
        case id
        case price
        case size
        case productId = "product_id"
        case profileId = "profile_id"
        case side
        case type
        case timeInForce = "time_in_force"
        case postOnly = "post_only"
        case createdAt = "created_at"
        case doneAt = "done_at"
        case doneReason = "done_reason"
        case fillFees = "fill_fees"
        case filledSize = "filled_size"
        case executedValue = "executed_value"
        case marketType = "market_type"
        case status
        case settled
    }
}
