//
//  TickerMessage.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/1.
//

import Foundation

struct TickerMessage: Codable {
    
    let type, productId, price: String
    let sequence, tradeId: Int
    let open24h, volume24h, low24h, high24h, volume30d: String
    let bestBid, bestBidSize, bestAsk, bestAskSize: String
    let side, time, lastSize: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case sequence
        case productId = "product_id"
        case price
        case open24h = "open_24h"
        case volume24h = "volume_24h"
        case low24h = "low_24h"
        case high24h = "high_24h"
        case volume30d = "volume_30d"
        case bestBid = "best_bid"
        case bestBidSize = "best_bid_size"
        case bestAsk = "best_ask"
        case bestAskSize = "best_ask_size"
        case side
        case time
        case tradeId = "trade_id"
        case lastSize = "last_size"
    }
}
