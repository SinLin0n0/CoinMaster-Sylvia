//
//  DateFormatter.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/3.
//
import UIKit
import Foundation

extension Date {
    func date2String(dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(identifier: "Asia/Taipei")
        formatter.locale = Locale.init(identifier: "zh_Hant_TW")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: self)
        return date
    }
}
