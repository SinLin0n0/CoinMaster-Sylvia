//
//  ProductsStats.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/12.
//

import Foundation

struct ProductsStats: Codable {
    let open: String
    let high: String
    let low: String
    let last: String
    let volume: String
    let volume_30day: String
    
    private enum CodingKeys: String, CodingKey {
        case open
        case high
        case low
        case last
        case volume
        case volume_30day = "volume_30day"
    }
}
