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
   
    var currencyName: String?
    var pageStatus: Bool = true // true為買入、false為賣出
    var textFieldIsUSD: Bool = true // 控制TextField邏輯
    var transactionView: CoinConvertView?
    var exchangeRateToUSD: ((Double) -> ())?
    var exchangeRate: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // PageStatusLabel
        if pageStatus {
            pageStatusLabel.text = "買入"
            availableBalanceStackView.isHidden = true
        } else {
            pageStatusLabel.text = "賣出"
            availableBalanceStackView.isHidden = false
        }
        // CurrencyNameLabel
        guard let currencyName = currencyName else {
            print("currencyName is nil")
            return
        }
        currencyNameLabel.text = "1 \(String(describing: currencyName)) ="
        // CurrencyTransactionView
        self.creatCurrencyTransaction()
        self.currencyTransactionView.layer.cornerRadius = 5
        self.currencyTransactionView.layer.shadowColor = UIColor.black.cgColor
        self.currencyTransactionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.currencyTransactionView.layer.shadowOpacity = 0.25
        self.currencyTransactionView.layer.shadowRadius = 4
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WebsocketService.shared.realTimeData = { data in
            let currency = Double(data.price) // 即時匯率
            self.exchangeRateToUSD?(currency ?? 0)
            self.currencyAmountLabel.text = NumberFormatter.formattedNumber(currency ?? 0)
            self.exchangeRate = currency
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
        // StatusLable
        self.setStatusLable(transactionView: transactionView)
        // CurrencyName
        transactionView?.currencyLabel.text = currencyName
        // CurrencyIcon
        transactionView?.currencyImage.image = getCurrencyIcon(for: currencyName)
        
        // SetTransactionView and Autolayout
        self.settransactionView(transactionView: transactionView)
        
        // SetTextField
        self.setTextField(transactionView: transactionView)
        transactionView?.bottomTextField.delegate = self
        transactionView?.topTextField.delegate = self
        
        // SetSwitch
        transactionView?.switchCurrencyButton.addTarget(self, action: #selector(switchCurrency), for: .touchUpInside)
    }
    func setStatusLable(transactionView: CoinConvertView?) {
        if pageStatus {
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
    func settransactionView(transactionView: CoinConvertView?) {
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
            
            transactionView?.bottomTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
        } else {
            transactionView?.bottomTextField.isUserInteractionEnabled = false
            transactionView?.topTextField.isUserInteractionEnabled = true
            transactionView?.bottomTextField.textColor = .gray
            transactionView?.topTextField.textColor = .black
            
            transactionView?.topTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, let value = Double(text) {
            self.exchangeRateToUSD = { [weak self] rate in
                if self?.textFieldIsUSD == true{
                    let convertedValue = value / rate
                    self?.transactionView?.topTextField.text = String(format: "%.3f", convertedValue)
                } else {
                    let convertedValue = value * rate
                    self?.transactionView?.bottomTextField.text = String(format: "%.3f", convertedValue)
                }
            }
        } else {
            print("error")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if transactionView?.bottomTextField.text == "0" {
            textField.text = ""
        }
        if transactionView?.topTextField.text == "0" {
            textField.text = ""
        }
        if transactionView?.bottomTextField.text == "nil" {
            textField.text = "0"
        }
        if transactionView?.topTextField.text == "nil" {
            textField.text = "0"
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //        let allowedCharacters = CharacterSet.decimalDigits
        //        let characterSet = CharacterSet(charactersIn: string)
        //        return allowedCharacters.isSuperset(of: characterSet) || string.isEmpty
        if textField == self.transactionView?.bottomTextField {
            let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            let newValue = Double(newString ?? "")
            let convertedValue = (newValue ?? 0) / (self.exchangeRate ?? 1)
            self.transactionView?.topTextField.text = String(format: "%.3f", convertedValue)
            
        } else if textField == self.transactionView?.topTextField {
            let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            let newValue = Double(newString ?? "")
            let convertedValue = (newValue ?? 0) * (self.exchangeRate ?? 1)
            self.transactionView?.bottomTextField.text = String(format: "%.3f", convertedValue)
        }
        
        return true
    }
    
    @IBAction func returnToPreviousPage(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
