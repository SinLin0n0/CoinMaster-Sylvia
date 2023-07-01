//
//  ViewController.swift
//  LineChart
//
//  Created by Sin on 2023/6/28.
//

import UIKit
import MJRefresh
import Starscream

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var dataPoints: [CGFloat] = []
   
    var images = [UIImage]()
    var usdPairs: [CurrencyPair] = []
    var productsStats: ProductsStats?
     
    override func viewDidLoad() {
        super.viewDidLoad()
        // Refresch
        let header  = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header = header
        // TableViewUI
        tableView.contentInsetAdjustmentBehavior = .never
        
//        WebsocketService.shared.setWebsocket()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // fetch usdPairsAPI
        CoinbaseService.shared.getApiResponse(api: CoinbaseApi.products,
                                              authRequired: false) { (products: [CurrencyPair]) in
            
            let USDPairs = products.filter { currencyPair in
                return String(currencyPair.id.suffix(3)) == "USD" && currencyPair.auctionMode == false
            }
            self.usdPairs = USDPairs
        }
        
       

    }
    
    @objc func headerRefresh() {
        self.tableView!.reloadData()
        self.tableView.mj_header?.endRefreshing()
    }
    
    func updateLabelWithValue(_ value: Double?, in label: UILabel) {
        guard let value = value else {
            label.text = "N/A"
            return
        }
        
        let formattedValue: String
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            formattedValue = String(format: "%.0f", value)
        } else {
            formattedValue = String(format: "%.3f", value)
        }
        
        label.text = formattedValue
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
            // account balance
            CoinbaseService.shared.getApiResponse(api: CoinbaseApi.accounts,
                                                  authRequired: true,
                                                  requestPath: RequestPath.accounts,
                                                  httpMethod: HttpMethod.get) { (accounts: [Account]) in

                for account in accounts {
                    if account.currency == "USD" {
                        let balance = account.balance
                        if let decimalBalance = Decimal(string: balance) {
                            let roundingBehavior = NSDecimalNumberHandler(roundingMode: .plain, scale: 5, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
                            let roundedBalance = NSDecimalNumber(decimal: decimalBalance).rounding(accordingToBehavior: roundingBehavior)
                            let formattedBalance = "\(roundedBalance)"
                            
                            DispatchQueue.main.async {
                                cell.balanceLabel.text = formattedBalance
                                print(formattedBalance)
                            }
                        }
                    }
                }
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
            cell.setupLineChartView(with: data)
            // produtsStats
            let productId = self.usdPairs[indexPath.row - 1].id
            let productsRawValue = CoinbaseApi.products
            CoinbaseService.shared.getApiSingleResponse(api: productsRawValue,
                                                        param: "/\(productId)/stats",
                                                        authRequired: false) { (products: ProductsStats) in
                if let open = Double(products.open), let last = Double(products.last) {
                    let trend = (last - open) / last * 100
                    DispatchQueue.main.async {
                        cell.trendLabel.text = trend >= 0 ? "+\(String(format: "%.2f", trend))" : "\(String(format: "%.2f", trend))"
                        cell.trendLabel.textColor = trend > 0 ? .systemGreen : .systemPink
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.trendLabel.text = "N/A"
                    }
                }
                
                if let low = Double(products.low), let high = Double(products.high) {
                    let average = (low + high) / 2
                    DispatchQueue.main.async {
                        self.updateLabelWithValue(average, in: cell.exchangeRateLabel)
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.exchangeRateLabel.text = "N/A"
                    }
                }
            
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                if indexPath.row >= 1 && indexPath.row <= usdPairs.count {
                    let selectedCurrencyPair = usdPairs[indexPath.row - 1]
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                               let nextViewController = storyboard.instantiateViewController(withIdentifier: "CurrencyDetailsViewController") as! CurrencyDetailsViewController
                    nextViewController.currencyPair = selectedCurrencyPair
                    navigationController?.pushViewController(nextViewController, animated: true)
                }
            }
}

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
