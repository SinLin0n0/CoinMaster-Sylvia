//
//  CandlesDataPoint.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/3.
//

import Foundation

struct CandlesDataPoint {
    var timestamp: TimeInterval
    var open: Double
    var high: Double
    var low: Double
    var close: Double
    var volume: Double
    var average: Double {
        return (high + low) / 2
    }
    
    init(numbers: [Double]) {
        self.timestamp = numbers[0]
        self.low = numbers[1]
        self.high = numbers[2]
        self.open = numbers[3]
        self.close = numbers[4]
        self.volume = numbers[5]
    }
}
