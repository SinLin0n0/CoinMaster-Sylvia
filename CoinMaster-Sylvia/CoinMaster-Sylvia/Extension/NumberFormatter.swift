//
//  NumberFormatter.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/2.
//

import Foundation

extension NumberFormatter {
    static func formattedNumber(_ number: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 3
        
        if number > 10000 {
            return numberFormatter.string(from: NSNumber(value: Int(number))) ?? ""
        } else {
            let decimalNumber = Decimal(number)
            if let formattedNumber = numberFormatter.string(from: NSDecimalNumber(decimal: decimalNumber) as NSNumber) {
                return formattedNumber
            }
        }
        return ""
    }
}
