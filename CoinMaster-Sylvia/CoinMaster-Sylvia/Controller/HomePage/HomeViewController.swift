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
        // usdPairsAPI
        CoinbaseService.shared.getApiResponse(api: CoinbaseApi.products,
                                              authRequired: false) { (products: [CurrencyPair]) in
            
            let USDPairs = products.filter { currencyPair in
                return String(currencyPair.id.suffix(3)) == "USD"
            }
            self.usdPairs = USDPairs
//            print("USD Curreny Pairs (Array): \(USDPairs)")
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
            
            cell.balanceLabel.text = "3,456"
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
//            let doubleData = data.map { Double($0) }
            cell.setupLineChartView(with: data)
            // produtsStats
            let productId = self.usdPairs[indexPath.row - 1].id
            let productsRawValue = CoinbaseApi.products
            CoinbaseService.shared.getApiSingleResponse(api: productsRawValue,
                                                        param: "/\(productId)/stats",
                                                        authRequired: false) { (products: ProductsStats) in
                if let open = Double(products.open), let last = Double(products.last) {
                    let trend = open / last
                    DispatchQueue.main.async {
                        if trend > 0 {
                            cell.trendLabel.text = "+\(String(format: "%.2f", trend))"
                            cell.trendLabel.textColor = .systemGreen
                        } else {
                            cell.trendLabel.text = "-\(String(format: "%.2f", trend))"
                            cell.trendLabel.textColor = .systemPink
                        }
                        
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.trendLabel.text = "N/A"
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



//            data.sort { prv, next in
//                prv[0] < next[0]
//            }

//            var doubleData = data.map { $0 Double[2] }
// 標準化
//            doubleData = self.normalizeData(doubleData)

//func normalizeData(_ data: [Double]) -> [Double] {
//    let minValue = data.min() ?? 0
//    let maxValue = data.max() ?? 1
//
//    let normalizedData = data.map { (value) -> Double in
//        return (value - minValue) / (maxValue - minValue)
//    }
//return normalizedData
//}
var data = [
    [
        1687921560,
        1865.21,
        1865.78,
        1865.45,
        1865.41,
        12.26165979
    ],
    [
        1687921500,
        1864.16,
        1865.45,
        1864.49,
        1865.44,
        37.78367272
    ],
    [
        1687921440,
        1863.85,
        1864.48,
        1864.1,
        1864.48,
        11.8946594
    ],
    [
        1687921380,
        1863.41,
        1864.64,
        1864.58,
        1864.15,
        16.08341455
    ],
    [
        1687921320,
        1864.01,
        1865,
        1864.08,
        1864.59,
        43.83813165
    ],
    [
        1687921260,
        1860.62,
        1864.52,
        1860.72,
        1864.09,
        180.06002442
    ]
    ]
