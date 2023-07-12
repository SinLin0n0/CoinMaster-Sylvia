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
    case bat
    case eth
    case eur
    case gbp
    case usdc
    case usd

    var currencyName: String {
        switch self {
        case .bch: return  "BCH"
        case .link: return "LINK"
        case .usdt: return "USDT"
        case .btc: return "BTC"
        case .bat: return  "BAT"
        case .eth: return  "ETH"
        case .eur: return  "EUR"
        case .gbp: return  "GBP"
        case .usdc: return  "USDC"
        case .usd: return  "USD"
        }
    }
    var currencyIcon: UIImage! {
        switch self {
        case .bch: return  UIImage(named: "bch")
        case .link: return UIImage(named: "link")
        case .usdt: return UIImage(named: "usdt")
        case .btc: return UIImage(named: "btc")
        case .bat: return  UIImage(named: "bat")
        case .eth: return  UIImage(named: "eth")
        case .eur: return  UIImage(named: "eur")
        case .gbp: return  UIImage(named: "gbp")
        case .usdc: return  UIImage(named: "usdc")
        case .usd: return  UIImage(named: "usd")
        }
    }
    var currencyChName: String {
        switch self {
        case .bch: return  "比特幣現金"
        case .link: return "Chainlink"
        case .usdt: return "泰達幣"
        case .btc: return "比特幣"
        case .bat: return "BAT"
        case .eth: return "以泰幣"
        case .eur: return "EUR"
        case .gbp: return "GBP"
        case .usdc: return "美金幣"
        case .usd: return "USD"
        }
    }
    var currencyIconBlack: UIImage! {
        switch self {
        case .bch: return  UIImage(named: "bch_black")
        case .link: return UIImage(named: "link_black")
        case .usdt: return UIImage(named: "usdt_black")
        case .btc: return UIImage(named: "btc_black")
        case .bat: return  UIImage(named: "bat_black")
        case .eth: return  UIImage(named: "eth_black")
        case .eur: return  UIImage(named: "eur_black")
        case .gbp: return  UIImage(named: "gbp_black")
        case .usdc: return  UIImage(named: "usdc_black")
        case .usd: return  UIImage(named: "usd_black")
        }
    }
}
