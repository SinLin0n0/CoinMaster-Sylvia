//
//  ViewController.swift
//  LineChart
//
//  Created by Sin on 2023/6/28.
//

import UIKit
import MJRefresh
import CoinMasterInfoKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var dataPoints: [CGFloat] = []
    
    var images = [UIImage]()
    var usdPairs: [CurrencyPair] = []
    var productsStats: ProductsStats?
    var usdPairsStats: [String: (Double, Double)] = [:]
    var formattedBalance: String = ""
    var twdExchangeRate: Double?
    var totalBalanceInTWD: Double = 0
    
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
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = true
        HudLoading.shared.setHud(view: self.view)
        self.getApiData()
    }
    func getApiData(completion: (([CurrencyPair]) -> Void)? = nil) {
        var balanceExchange: Double!
//        let semaphore = DispatchSemaphore(value: 0)
        self.totalBalanceInTWD = 0
      
        CoinbaseService.shared.getApiResponse(api: CoinbaseApi.accounts,
                                              authRequired: true,
                                              requestPath: RequestPath.accounts,
                                              httpMethod: HttpMethod.get) { [weak self] (accounts: [Account]) in
            for account in accounts {
                if let balance = Double(account.balance) {
                    let rate = account.currency
                    balance.convertToTWD(rate: rate) { convertedValue in
                        self?.totalBalanceInTWD += convertedValue
                    }
                }
            }
            CoinbaseService.shared.getApiResponse(api: CoinbaseApi.products,
                                                  authRequired: false) { [weak self] (products: [CurrencyPair]) in
                
                self?.usdPairs = products.filter { currencyPair in
                    return String(currencyPair.id.suffix(3)) == "USD" && currencyPair.auctionMode == false && currencyPair.status == "online"
                }
                self?.usdPairsStats = [:]
                let group = DispatchGroup()
                for pair in self!.usdPairs {
                    group.enter()
                    
                    CoinbaseService.shared.getApiSingleResponse(api: CoinbaseApi.products,
                                                                param: "/\(pair.id)/stats",
                                                                authRequired: false) { [weak self] (products: ProductsStats) in
                        let open = Double(products.open) ?? 0
                        let last = Double(products.last) ?? 0
                        let trend = (last - open) / last * 100
                        
                        let low = Double(products.low) ?? 0
                        let high = Double(products.high) ?? 0
                        let average = (low + high) / 2
                        
                        self?.usdPairsStats.updateValue((average, trend), forKey: pair.id)
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    self?.tableView?.reloadData()
                    self?.tableView.mj_header?.endRefreshing()
                    HudLoading.shared.dismissHud()
                }
            }
        }
    }
    
    @objc func headerRefresh() {
        self.getApiData()
        
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
            if self.totalBalanceInTWD == 0 {
                cell.balanceLabel.text = ""
            } else {
                cell.balanceLabel.text = NumberFormatter.formattedNumber(self.totalBalanceInTWD)
            }
            
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
            // productsStats
            if let productStat = usdPairsStats["\(baseCurrency)-USD"] {
                let average = productStat.0
                let trend = productStat.1
                if trend > 0 {
                    cell.trendLabel.text = "+\(String(format: "%.2f", trend))%"
                    cell.trendLabel.textColor = .systemGreen
                    cell.setupLineChartView(with: data, lineColor: .systemGreen)
                } else if trend < 0 {
                    cell.trendLabel.text = "\(String(format: "%.2f", trend))%"
                    cell.trendLabel.textColor = .systemPink
                    cell.setupLineChartView(with: data, lineColor: .systemPink)
                } else {
                    cell.trendLabel.text = "\(String(format: "%.2f", trend))%"
                    cell.trendLabel.textColor = .systemGray
                    cell.setupLineChartView(with: data, lineColor: .systemGreen)
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
