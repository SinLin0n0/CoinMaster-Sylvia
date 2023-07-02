//
//  BaseCurrency.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/1.
//

import Foundation
import UIKit

enum BaseCurrency: CaseIterable {
    case bch
    case link
    case usdt
    case btc

    var currencyName: String {
        switch self {
        case .bch: return  "BCH"
        case .link: return "LINK"
        case .usdt: return "USDT"
        case .btc: return "BTC"
        }
    }
    var currencyIcon: UIImage! {
        switch self {
        case .bch: return  UIImage(named: "bch")
        case .link: return UIImage(named: "link")
        case .usdt: return UIImage(named: "usdt")
        case .btc: return UIImage(named: "btc")
        }
    }
    var currencyChName: String {
        switch self {
        case .bch: return  "比特幣現金"
        case .link: return "Chainlink"
        case .usdt: return "泰達幣"
        case .btc: return "比特幣"
        }
    }
}
