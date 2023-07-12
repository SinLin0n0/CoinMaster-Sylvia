//
//  CurrencyDetailsViewController.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/6/29.
//

import UIKit
import JGProgressHUD

enum TimeIntervalOption {
    case oneDay
    case threeHundredDays
    case oneWeek
    case oneMonth
    case threeMonths
    case oneYear
}
class CurrencyDetailsViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pageTitle: UILabel!
    var currencyName: String?
    var realTimeBid: String?
    var realTimeAsk: String?
    var productOrders: [ProductOrders] = []
    var dataPointAverages: [Double] = []
    var timestamps: [Double] = []
    var exchangeRate: Double?
    let websocketService = WebsocketService()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
        self.sellButton.layer.cornerRadius = 5
        self.buyButton.layer.cornerRadius = 5
        HudLoading.shared.setHud(view: self.view)

    }
    
    var realTimeBidLabel: UILabel?
    var realTimeAskLabel: UILabel?
    
    override func viewWillAppear(  _ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        navigationItem.backButtonTitle = ""
        guard let pageTitleEn = currencyName else { return }
        guard let currency = BaseCurrency.allCases.first(where: { $0.currencyName == pageTitleEn }) else { return }
        let pageTitleCh = currency.currencyChName
        pageTitle.text = "\(pageTitleCh)(\(pageTitleEn))"
        let param = "&product_id=\(pageTitleEn)-USD"
        CoinbaseService.shared.getApiResponse(api: CoinbaseApi.oders,
                                              param: param,
                                              authRequired: true,
                                              requestPath: RequestPath.orders,
                                              requestPathParam: param) { [weak self] (orders: [ProductOrders]) in
            DispatchQueue.main.async {
                self?.productOrders = orders
                self?.tableView.reloadData()
                HudLoading.shared.dismissHud()
                if orders.isEmpty {
                    guard let self = self else { return }
                    AlertUtils.alert(title: "Internal Server Error", message: "資料維護中，請稍後再試。", from: self)
                    
                }
            }
        }
        
        websocketService.realTimeData = { data in
            let currency = Double(data.bestAsk)
            self.exchangeRate = currency
            // 買賣價要寫相反，因為是對user來說的值
            DispatchQueue.main.async {
                let realTimeBid = (Double(data.bestAsk) ?? 0) 
                let realTimeAsk = (Double(data.bestBid) ?? 0)
                let realTimeBidFormatted = NumberFormatter.formattedNumber(realTimeBid)
                let realTimeAskFormatted = NumberFormatter.formattedNumber(realTimeAsk)
                
                self.realTimeBidLabel?.text = realTimeBidFormatted
                self.realTimeAskLabel?.text = realTimeAskFormatted
                
            }
        }
        websocketService.setWebsocket(currency: pageTitleEn)
        let semaphore = DispatchSemaphore(value: 0)
        self.doCalcDate { averages, timestamps, endTime  in
            self.dataPointAverages = averages
            self.timestamps = timestamps
            semaphore.signal()
        }
        
        semaphore.wait()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        websocketService.stopSocket()
    }
    
    func doCalcDate(timeIntervalOption: TimeIntervalOption = TimeIntervalOption.oneDay,
                    endTime: TimeInterval = (Date().timeIntervalSince1970),
                    completion: @escaping ([Double], [Double], TimeInterval) -> Void) {
        DispatchQueue.main.async {
            HudLoading.shared.setHud(view: self.view)
        }
        let currentDate = Date()
        let calendar = Calendar.current
        
        var dateComponents = DateComponents()
        var granularity: Int = 0
        switch timeIntervalOption {
        case .oneDay:
            dateComponents.day = -1
            granularity = 3600
        case .threeHundredDays:
            dateComponents.day = -300
            granularity = 86400
        case .oneWeek:
            dateComponents.weekOfYear = -1
            granularity = 3600
        case .oneMonth:
            dateComponents.month = -1
            granularity = 86400
        case .threeMonths:
            dateComponents.month = -3
            granularity = 86400
        case .oneYear:
            dateComponents.year = -1
            granularity = 86400
            
            break
        }
        
        let nextDate = calendar.date(byAdding: dateComponents, to: currentDate)
        
        let start = Int(nextDate!.timeIntervalSince1970)
        let end = Int(endTime)
        let apiParam = "/\(currencyName!)-USD/candles?start=\(start)&end=\(end)&granularity=\(granularity)"
        CoinbaseService.shared.getApiResponse(api: CoinbaseApi.products,
                                              param: apiParam,
                                              authRequired: false) { [weak self] (candles: [[Double]]) in

            var candlesDataPoint = [CandlesDataPoint]()
            candles.forEach { numbers in
                candlesDataPoint.append(CandlesDataPoint(numbers: numbers))
            }
            let reversedCandlesDataPoint = candlesDataPoint.reversed()
            let averages = reversedCandlesDataPoint.map { point in
                return point.average
            }
            let nextEndTime = nextDate!.timeIntervalSince1970
            let dateFormatter = DateFormatter()
            let timestamps = reversedCandlesDataPoint.map { point in
                let time = point.timestamp
                return time
            }
            completion(averages, timestamps, nextEndTime)
           
        }
    }
    
    @IBAction func returnToPreviousPage(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buyCurrency(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let targetViewController = storyboard.instantiateViewController(withIdentifier: "CurrencyTransactionViewController") as? CurrencyTransactionViewController {
            targetViewController.currencyName = self.currencyName
            targetViewController.isSell = true
            let currencyTransactionVC = UINavigationController(rootViewController: targetViewController)
            
            currencyTransactionVC.modalPresentationStyle = .custom
            currencyTransactionVC.transitioningDelegate = self
            currencyTransactionVC.navigationBar.isHidden = true
            
            present(currencyTransactionVC, animated: true, completion: nil)
        }
    }
    @IBAction func sellCurrency(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let targetViewController = storyboard.instantiateViewController(withIdentifier: "CurrencyTransactionViewController") as? CurrencyTransactionViewController {
            targetViewController.currencyName = self.currencyName
            targetViewController.isSell = false
            let currencyTransactionVC = UINavigationController(rootViewController: targetViewController)
            
            currencyTransactionVC.modalPresentationStyle = .custom
            currencyTransactionVC.transitioningDelegate = self
            currencyTransactionVC.navigationBar.isHidden = true
            
            present(currencyTransactionVC, animated: true, completion: nil)
        }
    }
}

extension CurrencyDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        if productOrders.count == 0 {
            numberOfRows = 2
        } else {
            numberOfRows = productOrders.count + 1
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyDetailsTableViewCell1", for: indexPath) as? CurrencyDetailsTableViewCell1 else {
                print("error")
                return UITableViewCell()
            }
            
            self.realTimeBidLabel = cell.realTimeBidLabel
            self.realTimeAskLabel = cell.realTimeAskLabel
            cell.currencyName = self.currencyName
            cell.doCalcDate = self.doCalcDate
            cell.timestamps = self.timestamps
            cell.setChartView(dataArray: dataPointAverages)
            cell.assetTracking.addTarget(self, action: #selector(showAssetTracking), for: .touchUpInside)
            
            return cell
        } else if indexPath.row == 1 && productOrders.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataTableViewCell", for: indexPath) as? NoDataTableViewCell else {
                print("error")
                return UITableViewCell()
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.size.width, bottom: 0, right: 0)
            cell.noDataLabel.text = "尚無資料"
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyDetailsTableViewCell2", for: indexPath) as? CurrencyDetailsTableViewCell2 else {
                print("error")
                return UITableViewCell()
            }
            let data = productOrders[indexPath.row - 1]
            cell.setUI(data: data, currency: self.currencyName ?? "")
            
            return cell
        }
    }
    @objc func showAssetTracking() {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "AssetTrackingViewController") as! AssetTrackingViewController
        guard let currencyName = currencyName else {
            print("currencyName is nil")
            return
        }
        nextVC.selectedCurrency = currencyName
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}
