//
//  CurrencyDetailsViewController.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/6/29.
//

import UIKit

enum TimeIntervalOption {
    case oneDay
    case threeHundredDays
    case oneWeek
    case oneMonth
    case threeMonths
    case oneYear
}
class CurrencyDetailsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pageTitle: UILabel!
    var currencyName: String?
    var realTimeBid: String?
    var realTimeAsk: String?
    var productOrders: [ProductOrders] = []
    var dataPointAverages: [Double] = []
    var timestamps: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    var realTimeBidLabel: UILabel?
    var realTimeAskLabel: UILabel?
    
    override func viewWillAppear(  _ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        
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
            self?.productOrders = orders
        }
        
        WebsocketService.shared.realTimeData = { data in
            // 買賣價要寫相反，因為是對user來說的值
            DispatchQueue.main.async {
                let realTimeBid = (Double(data[1]) ?? 0)
                let realTimeAsk = (Double(data[0]) ?? 0)
                let realTimeBidFormatted = NumberFormatter.formattedNumber(realTimeBid)
                let realTimeAskFormatted = NumberFormatter.formattedNumber(realTimeAsk)
                
                self.realTimeBidLabel?.text = realTimeBidFormatted
                self.realTimeAskLabel?.text = realTimeAskFormatted
                
            }
        }
        WebsocketService.shared.setWebsocket(currency: pageTitleEn)
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
        WebsocketService.shared.stopSocket()
    }
    
    func doCalcDate(timeIntervalOption: TimeIntervalOption = TimeIntervalOption.oneDay,
                    endTime: TimeInterval = (Date().timeIntervalSince1970),
                    completion: @escaping ([Double], [Double], TimeInterval) -> Void) {
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
        
        var start = Int(nextDate!.timeIntervalSince1970)
        let end = Int(endTime)
        let apiParam = "/\( currencyName!)-USD/candles?start=\(start)&end=\(end)&granularity=\(granularity)"
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
    }
    @IBAction func sellCurrency(_ sender: Any) {
    }
}

extension CurrencyDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productOrders.count + 1
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
}
