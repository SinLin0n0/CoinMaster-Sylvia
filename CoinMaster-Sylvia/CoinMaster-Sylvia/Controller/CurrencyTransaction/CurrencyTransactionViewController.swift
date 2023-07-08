//
//  CurrencyTransactionViewController.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/4.
//

import UIKit

class CurrencyTransactionViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var pageStatusLabel: UILabel!
    @IBOutlet weak var currencyAmountLabel: UILabel!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencyTransactionView: UIView!
    @IBOutlet weak var availableBalanceStackView: UIStackView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!
    
    var currencyName: String?
    var isSell: Bool = true // true為買入、false為賣出
    var textFieldIsUSD: Bool = true // 控制TextField邏輯
    var transactionView: CoinConvertView?
    var exchangeRate: Double?
    var accountCurrency: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // PageStatusLabel
        if isSell {
            pageStatusLabel.text = "買入"
            textFieldIsUSD = true
            availableBalanceStackView.isHidden = true
            actionButton.setTitle("買入", for: .normal)
        } else {
            pageStatusLabel.text = "賣出"
            textFieldIsUSD = false
            availableBalanceStackView.isHidden = false
            actionButton.setTitle("賣出", for: .normal)
            CoinbaseService.shared.getApiResponse(api: CoinbaseApi.accounts,
                                                  authRequired: true,
                                                  requestPath: RequestPath.accounts,
                                                  httpMethod: HttpMethod.get) { [weak self] (accounts: [Account]) in
                guard let currencyName = self?.currencyName else {
                    print("currencyName is nil")
                    return
                }
                for account in accounts {
                    if account.currency == currencyName {
                        let balance = String(format: "%.8f", Double(account.balance)!)
                        let trimmedBalance = balance.trimmingCharacters(in: CharacterSet(charactersIn: "0"))
                        self?.accountCurrency = balance
                        DispatchQueue.main.async {
                            self?.balanceLabel.text = "\(balance) \(currencyName)"
                        }
                    }
                }
            }
        }
        // CurrencyNameLabel
        guard let currencyName = currencyName else {
            print("currencyName is nil")
            return
        }
        self.currencyAmountLabel.text = NumberFormatter.formattedNumber(exchangeRate ?? 0)
        currencyNameLabel.text = "1 \(String(describing: currencyName)) ="
        // CurrencyTransactionView
        self.creatCurrencyTransaction()
        self.currencyTransactionView.layer.cornerRadius = 5
        self.currencyTransactionView.layer.shadowColor = UIColor.black.cgColor
        self.currencyTransactionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.currencyTransactionView.layer.shadowOpacity = 0.25
        self.currencyTransactionView.layer.shadowRadius = 4
        self.actionButton.layer.cornerRadius = 5
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WebsocketService.shared.realTimeData = { data in
            let currency = Double(data.bestAsk) // 即時匯率
            self.exchangeRateToUSD(currency ?? 0)
            self.currencyAmountLabel.text = NumberFormatter.formattedNumber(currency ?? 0)
            self.exchangeRate = currency
        }
        WebsocketService.shared.setWebsocket(currency: currencyName ?? "")
    }
    
    
    func exchangeRateToUSD(_ rate: Double) {
        if self.textFieldIsUSD == true {
            let value = Double(self.transactionView?.bottomTextField.text ?? "0")
            let convertedValue = (value ?? 0) / rate
            self.transactionView?.topTextField.text = String(format: "%.8f", convertedValue)
        } else {
            let value = Double(self.transactionView?.topTextField.text ?? "0")
            let convertedValue = (value ?? 0) * rate
            self.transactionView?.bottomTextField.text = String(format: "%.3f", convertedValue)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        WebsocketService.shared.stopSocket()
    }
    func creatCurrencyTransaction() {
        //nibName:View的名稱
        transactionView = UINib(nibName: "CoinConvertView", bundle: nil).instantiate(withOwner: transactionView, options: nil).first as? CoinConvertView
        
        guard let currencyName = currencyName else {
            print("currencyName is nil")
            return
        }
        // StatusLable
        self.setStatusLable(transactionView: transactionView)
        // CurrencyName
        transactionView?.currencyLabel.text = currencyName
        // CurrencyIcon
        transactionView?.currencyImage.image = getCurrencyIcon(for: currencyName)
        
        // SetTransactionView and Autolayout
        self.setTransactionView(transactionView: transactionView)
        
        // SetTextField
        self.setTextField(transactionView: transactionView)
        transactionView?.bottomTextField.delegate = self
        transactionView?.topTextField.delegate = self
        
        // SetSwitch
        transactionView?.switchCurrencyButton.addTarget(self, action: #selector(switchCurrency), for: .touchUpInside)
    }
    func setStatusLable(transactionView: CoinConvertView?) {
        if isSell {
            transactionView?.topTextFieldDescribingLabel.text = "買入"
            transactionView?.bottomTextFieldDescribingLabel.text = "花費"
        } else {
            transactionView?.topTextFieldDescribingLabel.text = "賣出"
            transactionView?.bottomTextFieldDescribingLabel.text = "獲得"
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
    func setTransactionView(transactionView: CoinConvertView?) {
        if let transactionView = transactionView {
            self.currencyTransactionView.addSubview(transactionView)
            transactionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                transactionView.topAnchor.constraint(equalTo: self.currencyTransactionView.topAnchor),
                transactionView.bottomAnchor.constraint(equalTo: self.currencyTransactionView.bottomAnchor),
                transactionView.leadingAnchor.constraint(equalTo: self.currencyTransactionView.leadingAnchor),
                transactionView.trailingAnchor.constraint(equalTo: self.currencyTransactionView.trailingAnchor)
            ])
        }
    }
    
    @objc func switchCurrency() {
        if textFieldIsUSD {
            self.textFieldIsUSD = false
            self.setTextField(transactionView: transactionView)
        } else {
            self.textFieldIsUSD = true
            self.setTextField(transactionView: transactionView)
        }
    }
    
    func setTextField(transactionView: CoinConvertView?) {
        
        if textFieldIsUSD {
            transactionView?.bottomTextField.isUserInteractionEnabled = true
            transactionView?.topTextField.isUserInteractionEnabled = false
            transactionView?.bottomTextField.textColor = .black
            transactionView?.topTextField.textColor = .gray
        } else {
            transactionView?.bottomTextField.isUserInteractionEnabled = false
            transactionView?.topTextField.isUserInteractionEnabled = true
            transactionView?.bottomTextField.textColor = .gray
            transactionView?.topTextField.textColor = .black
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if transactionView?.bottomTextField.text == "0.000" {
            textField.text = ""
        }
        if transactionView?.topTextField.text == "0.00000000" {
            textField.text = ""
        }
        if transactionView?.bottomTextField.text == "nil" {
            textField.text = "0"
        }
        if transactionView?.topTextField.text == "nil" {
            textField.text = "0.00000000"
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.transactionView?.bottomTextField {
            let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            let newValue = Double(newString ?? "")
            let convertedValue = (newValue ?? 0) / (self.exchangeRate ?? 1)
            self.transactionView?.topTextField.text = String(format: "%.8f", convertedValue)
            
        } else if textField == self.transactionView?.topTextField {
            let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            let newValue = Double(newString ?? "")
            let convertedValue = (newValue ?? 0) * (self.exchangeRate ?? 1)
            self.transactionView?.bottomTextField.text = String(format: "%.3f", convertedValue)
        }
        return true
    }
    
    @IBAction func max(_ sender: Any) {
        self.transactionView?.topTextField.text = self.accountCurrency
        let balance = Double(accountCurrency ?? "")
        let convertedValue = (balance ?? 0) * (self.exchangeRate ?? 1)
        self.transactionView?.bottomTextField.text = String(format: "%.3f", convertedValue)
    }
    
    @IBAction func returnToPreviousPage(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func send(_ sender: Any) {
        let size = self.transactionView?.topTextField.text ?? ""
        let side: String = isSell ? "buy" : "sell"
        guard let currencyName = self.currencyName else {
            print("currencyName is nil")
            return
        }
        let productId = "\(currencyName)-USD"
        print("👾\("{\"type\": \"market\", \"size\": \"\(size)\", \"side\": \"\(side)\", \"product_id\": \"\(productId)\", \"time_in_force\": \"FOK\"}")")
        self.createOrders(size: size, side: side, productId: productId) { orderId in
            print("😈\(orderId)")
            DispatchQueue.main.async {
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "TransactionCompletedViewController") as! TransactionCompletedViewController
                nextVC.currencyName = self.currencyName
                nextVC.orderId = orderId
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    self.navigationController?.pushViewController(nextVC, animated: true)
                }
            }
        }
    }
    
    func createOrders(size: String, side: String, productId: String, completion: @escaping (String) -> Void) {
        let body = "{\"type\": \"market\", \"size\": \"\(size)\", \"side\": \"\(side)\", \"product_id\": \"\(productId)\", \"time_in_force\": \"FOK\"}"
        
        CoinbaseService.shared.getApiSingleResponse(api: CoinbaseApi.orderBaseURL, authRequired: true, requestPath: RequestPath.orderBaseURL, httpMethod: HttpMethod.post, body: body, completion: { (order: ProductOrders) in
//            print("👻\(order)")
            completion(order.id)
        })
    }
}
