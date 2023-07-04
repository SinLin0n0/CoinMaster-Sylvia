//
//  CurrencyTransactionViewController.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/4.
//

import UIKit

class CurrencyTransactionViewController: UIViewController {

    
    @IBOutlet weak var pageStatusLabel: UILabel!
    @IBOutlet weak var currencyAmountLabel: UILabel!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencyTransactionView: UIView!
    @IBOutlet weak var availableBalanceStackView: UIStackView!
    @IBOutlet weak var actionButton: UIButton!
   
    var currencyName: String?
    var pageStatus: Bool = true //true為買入、false為賣出
    var transactionView: CoinConvertView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // PageStatusLabel
        if pageStatus {
            pageStatusLabel.text = "買入"
        } else {
            pageStatusLabel.text = "賣出"
        }
        // CurrencyNameLabel
        guard let currencyName = currencyName else {
            print("currencyName is nil")
            return
        }
        currencyNameLabel.text = "1 \(String(describing: currencyName)) ="
        // CurrencyTransactionView
        self.creatCurrencyTransaction()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WebsocketService.shared.realTimeData = { data in
            let currency = Double(data.price)
            currency?.convertToTWD { convertedValue in
                print("轉換後的值為：\(convertedValue)")
                DispatchQueue.main.async {
                    self.currencyAmountLabel.text = NumberFormatter.formattedNumber(convertedValue)
                }
            }
        }
        WebsocketService.shared.setWebsocket(currency: currencyName ?? "")
    }
    
    func creatCurrencyTransaction() {
        //nibName:View的名稱
        transactionView = UINib(nibName: "CoinConvertView", bundle: nil).instantiate(withOwner: transactionView, options: nil).first as? CoinConvertView
        
        guard let currencyName = currencyName else {
            print("currencyName is nil")
            return
        }
        transactionView?.currencyImage.image = getCurrencyIcon(for: currencyName)
    
        if let transactionView = transactionView {
            self.currencyTransactionView.addSubview(transactionView)
            // 為 transactionView 設置自動佈局約束
            transactionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                transactionView.topAnchor.constraint(equalTo: self.currencyTransactionView.topAnchor),
                transactionView.bottomAnchor.constraint(equalTo: self.currencyTransactionView.bottomAnchor),
                transactionView.leadingAnchor.constraint(equalTo: self.currencyTransactionView.leadingAnchor),
                transactionView.trailingAnchor.constraint(equalTo: self.currencyTransactionView.trailingAnchor)
            ])
        }
    }
    
    func getCurrencyIcon(for currencyName: String) -> UIImage? {
        if let baseCurrency = BaseCurrency.allCases.first(where: { $0.currencyName == currencyName }) {
            return baseCurrency.currencyIcon
        } else {
            print("Currency not found")
            return nil
        }
    }
    
    @IBAction func returnToPreviousPage(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
