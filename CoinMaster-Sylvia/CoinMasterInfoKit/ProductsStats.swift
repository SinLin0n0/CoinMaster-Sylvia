//
//  ProductsStats.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/12.
//

import Foundation

public struct ProductsStats: Codable {
    public let open: String
    public let high: String
    public let low: String
    public let last: String
    public let volume: String
    public let volume_30day: String
    
    public enum CodingKeys: String, CodingKey {
        case open
        case high
        case low
        case last
        case volume
        case volume_30day = "volume_30day"
    }
}
