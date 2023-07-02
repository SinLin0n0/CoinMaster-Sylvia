//
//  Double.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/2.
//

import Foundation

extension Double {
    var convertToTWD: Double {
        var convertedValue: Double = 0.0
        
        CoinbaseService.shared.getApiSingleResponse(api: CoinbaseApi.exchangeRate, authRequired: false)  { (exchangeRate: ExchangeRateResponse) in
            if let twdExchangeRate = exchangeRate.data.rates["TWD"] {
                convertedValue = self * (Double(twdExchangeRate) ?? 0)
            }
        }
        
        return convertedValue
    }
}
