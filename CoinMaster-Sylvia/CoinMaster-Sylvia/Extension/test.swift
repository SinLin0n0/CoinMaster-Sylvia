//
//  test.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/10.
//

import Foundation

//func getApiData(completion: (([CurrencyPair]) -> Void)? = nil) {
//    var balanceExchange: Double!
//    let semaphore = DispatchSemaphore(value: 0)
//    CoinbaseService.shared.getApiResponse(api: CoinbaseApi.accounts,
//                                          authRequired: true,
//                                          requestPath: RequestPath.accounts,
//                                          httpMethod: HttpMethod.get) { [weak self] (accounts: [Account]) in
//        for account in accounts {
//            if account.currency == "USD" {
//                let balance = account.balance
//                balanceExchange = Double(balance) ?? 0
//            }
//        }
//        let rate = "USD"
//        CoinbaseService.shared.getApiSingleResponse(api: CoinbaseApi.exchangeRate, param: rate, authRequired: false)  { [weak self] (exchangeRate: ExchangeRateResponse) in
//            if let twdExchangeRate = exchangeRate.data.rates["TWD"] {
//                self?.twdExchangeRate = (Double(twdExchangeRate) ?? 0)
//                let balanceTWD = balanceExchange * (Double(twdExchangeRate) ?? 0)
//                let formattedBalance = NumberFormatter.formattedNumber(balanceTWD)
//                self?.formattedBalance = formattedBalance
//            }
//            
//            // fetch usdPairsAPI
//            CoinbaseService.shared.getApiResponse(api: CoinbaseApi.products,
//                                                  authRequired: false) { [weak self] (products: [CurrencyPair]) in
//                
//                self?.usdPairs = products.filter { currencyPair in
//                    return String(currencyPair.id.suffix(3)) == "USD" && currencyPair.auctionMode == false && currencyPair.status == "online"
//                }
//                self?.usdPairsStats = [:]
//                let group = DispatchGroup()
//                for pair in self!.usdPairs {
//                    group.enter()
//                    
//                        CoinbaseService.shared.getApiSingleResponse(api: CoinbaseApi.products,
//                                                                    param: "/\(pair.id)/stats",
//                                                                    authRequired: false) { [weak self] (products: ProductsStats) in
//                            let open = Double(products.open) ?? 0
//                            let last = Double(products.last) ?? 0
//                            let trend = (last - open) / last * 100
//
//                            let low = Double(products.low) ?? 0
//                            let high = Double(products.high) ?? 0
//                            let average = (low + high) / 2
//                            
//                            self?.usdPairsStats.updateValue((average, trend), forKey: pair.id)
//                            group.leave()
//                    }
//                }
//                group.notify(queue: .main) {
//                    self?.tableView?.reloadData()
//                }
//            }
//        }
//        semaphore.signal()
//    }
//    semaphore.wait()
//}
