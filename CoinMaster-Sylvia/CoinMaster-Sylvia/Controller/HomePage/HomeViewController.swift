//
//  ViewController.swift
//  LineChart
//
//  Created by Sin on 2023/6/28.
//

import UIKit
import MJRefresh

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var dataPoints: [CGFloat] = []
    
    var images = [UIImage]()
    var usdPairs: [CurrencyPair] = []
    var productsStats: ProductsStats?
    var usdPairsStats: [String: (Double, Double)] = [:]
    var formattedBalance: String = ""
    var twdExchangeRate: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Refresch
        let header  = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header = header
        // TableViewUI
        tableView.contentInsetAdjustmentBehavior = .never
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getApiData()
    }

    func getApiData(completion: (([CurrencyPair]) -> Void)? = nil) {
        var balanceExchange: Double!
        
        CoinbaseService.shared.getApiResponse(api: CoinbaseApi.accounts,
                                              authRequired: true,
                                              requestPath: RequestPath.accounts,
                                              httpMethod: HttpMethod.get) { (accounts: [Account]) in
            for account in accounts {
                if account.currency == "USD" {
                    let balance = account.balance
                    balanceExchange = Double(balance) ?? 0
                }
            }
            CoinbaseService.shared.getApiSingleResponse(api: CoinbaseApi.exchangeRate, authRequired: false)  { (exchangeRate: ExchangeRateResponse) in
                if let twdExchangeRate = exchangeRate.data.rates["TWD"] {
                    self.twdExchangeRate = (Double(twdExchangeRate) ?? 0)
                    let balanceTWD = balanceExchange * (Double(twdExchangeRate) ?? 0)
                    let formattedBalance = NumberFormatter.formattedNumber(balanceTWD)
                    self.formattedBalance = formattedBalance
                }
                
                // fetch usdPairsAPI
                CoinbaseService.shared.getApiResponse(api: CoinbaseApi.products,
                                                      authRequired: false) { (products: [CurrencyPair]) in
                    
                    self.usdPairs = products.filter { currencyPair in
                        return String(currencyPair.id.suffix(3)) == "USD" && currencyPair.auctionMode == false && currencyPair.status == "online"
                    }
                    self.usdPairsStats = [:]
                    let group = DispatchGroup()
                    for pair in self.usdPairs {
                        group.enter()
                        
                            CoinbaseService.shared.getApiSingleResponse(api: CoinbaseApi.products,
                                                                        param: "/\(pair.id)/stats",
                                                                        authRequired: false) { (products: ProductsStats) in
                                let open = Double(products.open) ?? 0
                                let last = Double(products.last) ?? 0
                                let trend = (last - open) / last * 100

                                let low = Double(products.low) ?? 0
                                let high = Double(products.high) ?? 0
                                let average = (low + high) / 2
                                
                                self.usdPairsStats.updateValue((average, trend), forKey: pair.id)
                                group.leave()
                        }
                    }
                    group.notify(queue: .main) {
                        self.tableView?.reloadData()
                    }
                }
            }
        }
       
        
        
               
    }
    
    @objc func headerRefresh() {
        self.tableView!.reloadData()
        self.tableView.mj_header?.endRefreshing()
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + usdPairs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell1", for: indexPath) as? HomeTableViewCell1 else {
                print("error")
                return UITableViewCell()
            }
            cell.balanceLabel.text = formattedBalance
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell2", for: indexPath) as? HomeTableViewCell2 else {
                print("error")
                return UITableViewCell()
            }
            // BaseCurrencyName
            let baseCurrency = self.usdPairs[indexPath.row - 1].baseCurrency
            cell.currencyEnLabel.text = baseCurrency
            // BaseCurrencyIcon
            if let currency = BaseCurrency.allCases.first(where: { $0.currencyName == baseCurrency }) {
                cell.currencyChLabel.text = currency.currencyChName
                cell.currencyIconImage.image = currency.currencyIcon
            } else {
                cell.currencyEnLabel.text = ""
                cell.currencyIconImage.image = nil
            }
            // BaseCurrencyLineChart
            var data = [Double]()
            for _ in 0..<10 {
                let randomValue = Double(arc4random_uniform(10))
                data.append(randomValue)
            }
            cell.setupLineChartView(with: data)
            // productsStats
            if let productStat = usdPairsStats["\(baseCurrency)-USD"] {
                let average = productStat.0
                let trend = productStat.1
                if trend > 0 {
                    cell.trendLabel.text = "+\(String(format: "%.2f", trend))%"
                    cell.trendLabel.textColor = .systemGreen
                } else if trend < 0 {
                    cell.trendLabel.text = "\(String(format: "%.2f", trend))%"
                    cell.trendLabel.textColor = .systemPink
                } else {
                    cell.trendLabel.text = "\(String(format: "%.2f", trend))%"
                    cell.trendLabel.textColor = .systemGray
                }
                let twdAverage = average * (self.twdExchangeRate ?? 1)
                cell.exchangeRateLabel.text = NumberFormatter.formattedNumber(twdAverage)
            }

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 && indexPath.row <= usdPairs.count {
            let selectedCurrencyName = usdPairs[indexPath.row - 1].baseCurrency
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewController(withIdentifier: "CurrencyDetailsViewController") as! CurrencyDetailsViewController
            nextViewController.currencyName = selectedCurrencyName
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
}
