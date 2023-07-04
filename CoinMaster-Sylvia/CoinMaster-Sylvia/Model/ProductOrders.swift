//
//  ProductOrders.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/3.
//

import Foundation

struct ProductOrders: Codable {
    let id, price, size: String
    let productID, profileID: String
    let side, type, timeInForce: String
    let postOnly, settled: Bool
    let createdAt, doneAt, doneReason, fillFees, filledSize: String
    let executedValue, marketType, status: String
    let fundingCurrency: String?

    enum CodingKeys: String, CodingKey {
        case id
        case price
        case size
        case productID = "product_id"
        case profileID = "profile_id"
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
        case fundingCurrency = "funding_currency"
    }
}

//struct ProductOrders: Codable {
//    let id: String
//    let price: String
//    let size: String
//    let productID: String
//    let profileID: String
//    let side: String
//    let type: String
//    let timeInForce: String
//    let postOnly: Bool
//    let createdAt: String
//    let doneAt: String
//    let doneReason: String
//    let fillFees: String
//    let filledSize: String
//    let executedValue: String
//    let marketType: String
//    let status: String
//    let settled: Bool
//    let fundingCurrency: String
//
//    private enum CodingKeys: String, CodingKey {
//        case id, price, size, productID = "product_id", profileID = "profile_id", side, type, timeInForce = "time_in_force", postOnly = "post_only", createdAt = "created_at", doneAt = "done_at", doneReason = "done_reason", fillFees = "fill_fees", filledSize = "filled_size", executedValue = "executed_value", marketType = "market_type", status, settled, fundingCurrency = "funding_currency"
//    }
//}


