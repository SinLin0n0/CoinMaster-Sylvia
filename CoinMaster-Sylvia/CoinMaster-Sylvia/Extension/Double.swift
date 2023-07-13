//
//  Double.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/2.
//

import Foundation
import CoinMasterInfoKit

extension Double {
    func convertToTWD(rate: String, completion: @escaping (Double) -> Void) {
        CoinbaseService.shared.getApiSingleResponse(api: CoinbaseApi.exchangeRate, param: rate, authRequired: false) { (exchangeRate: ExchangeRateResponse) in
            if let twdExchangeRate = exchangeRate.data.rates["TWD"] {
                let convertedValue = self * (Double(twdExchangeRate) ?? 0)
                completion(convertedValue)
            } else {
                completion(0.0)
            }
        }
    }
}
