//
//  CurrencyDetailsViewController.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/6/29.
//

import UIKit

class CurrencyDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pageTitle: UILabel!
    var currencyName: String?
    var realTimeBid: String?
    var realTimeAsk: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(  _ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        
        guard let pageTitleEn = currencyName else { return }
        guard let currency = BaseCurrency.allCases.first(where: { $0.currencyName == pageTitleEn }) else { return }
        let pageTitleCh = currency.currencyChName
        pageTitle.text = "\(pageTitleCh)(\(pageTitleEn))"
        
        WebsocketService.shared.setWebsocket(currency: pageTitleEn)
        WebsocketService.shared.realTimeData = { data in
            CoinbaseService.shared.getApiSingleResponse(api: CoinbaseApi.exchangeRate, authRequired: false)  { (exchangeRate: ExchangeRateResponse) in
                if let twdExchangeRate = exchangeRate.data.rates["TWD"] {
                    // 買賣價要寫相反，因為是對user來說的值
                    DispatchQueue.main.async {
                        
                        let realTimeBid = (Double(data[1]) ?? 0) * (Double(twdExchangeRate) ?? 0)
                        let realTimeAsk = (Double(data[0]) ?? 0) * (Double(twdExchangeRate) ?? 0)

                        let realTimeBidFormatted = NumberFormatter.formattedNumber(realTimeBid)
                        let realTimeAskFormatted = NumberFormatter.formattedNumber(realTimeAsk)

                        self.realTimeBid = realTimeBidFormatted
                        self.realTimeAsk = realTimeAskFormatted
                        self.tableView?.reloadData()
                    }
                } else {
                    print("error")
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        WebsocketService.shared.stopSocket()
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
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyDetailsTableViewCell1", for: indexPath) as? CurrencyDetailsTableViewCell1 else {
                print("error")
                return UITableViewCell()
            }
            cell.realTimeBidLabel.text = realTimeBid
            cell.realTimeAskLabel.text = realTimeAsk
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyDetailsTableViewCell2", for: indexPath) as? CurrencyDetailsTableViewCell2 else {
                print("error")
                return UITableViewCell()
            }
            return cell
        }
    }


}
