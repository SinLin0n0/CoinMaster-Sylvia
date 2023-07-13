//
//  Products.swift
//  CryptoApp
//
//  Created by Sin on 2023/6/28.
//

import Foundation

public struct CurrencyPair: Codable, Hashable {
    
    public let id, baseCurrency, quoteCurrency, quoteIncrement: String
    public let baseIncrement, displayName, minMarketFunds: String
    public let marginEnabled, postOnly, limitOnly, cancelOnly: Bool
    public let status, statusMessage: String
    public let tradingDisabled, fxStablecoin: Bool
    public let maxSlippagePercentage: String
    public let auctionMode: Bool
    public let highBidLimitPercentage: String
    
    public enum CodingKeys: String, CodingKey {
        case id
        case baseCurrency = "base_currency"
        case quoteCurrency = "quote_currency"
        case quoteIncrement = "quote_increment"
        case baseIncrement = "base_increment"
        case displayName = "display_name"
        case minMarketFunds = "min_market_funds"
        case marginEnabled = "margin_enabled"
        case postOnly = "post_only"
        case limitOnly = "limit_only"
        case cancelOnly = "cancel_only"
        case status
        case statusMessage = "status_message"
        case tradingDisabled = "trading_disabled"
        case fxStablecoin = "fx_stablecoin"
        case maxSlippagePercentage = "max_slippage_percentage"
        case auctionMode = "auction_mode"
        case highBidLimitPercentage = "high_bid_limit_percentage"
    }
}
