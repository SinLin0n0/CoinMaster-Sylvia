//
//  ExchangeRateResponse.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/1.
//

import Foundation
import UIKit

struct ExchangeRateResponse: Codable {
    let data: ExchangeRateData
}

struct ExchangeRateData: Codable {
    let currency: String
    let rates: [String: String]
}
