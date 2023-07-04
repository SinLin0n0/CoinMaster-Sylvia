//
//  DateFormatter.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/3.
//
import UIKit
import Foundation

extension DateFormatter {
    func convertGMTtoTaiwanTime(
        encodeFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'",
        gmtTimeString: String
    ) -> String? {
        self.dateFormat = encodeFormat
        
        if let date = self.date(from: gmtTimeString) {
            let taiwanTimeZone = TimeZone(abbreviation: "GMT+8")
            self.timeZone = taiwanTimeZone
            self.dateFormat = "yyyy-MM-dd HH:mm"
            let taiwanTime = self.string(from: date)
            return taiwanTime
        }
        
        return nil
    }
}

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
