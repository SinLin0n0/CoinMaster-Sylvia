//
//  TransactionCompletedViewController.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/5.
//

import UIKit

class TransactionCompletedViewController: UIViewController {
    
    enum SideData: String {
        case buy = "BUY"
        case sell = "SELL"
    }
    
    @IBOutlet weak var confirmAssetsButton: UIButton!
    @IBOutlet weak var completedView: UIView!
    var openConfirmAssetsButton: Bool = true
    var currencyName: String?
    var orderId: String?
    var transactionSuccessView: TransactionSuccessView?
    //    var order: ProductOrders?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.completedView.layer.cornerRadius = 5
        self.completedView.layer.shadowColor = UIColor.black.cgColor
        self.completedView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.completedView.layer.shadowOpacity = 0.25
        self.completedView.layer.shadowRadius = 4
        self.confirmAssetsButton.layer.cornerRadius = 5
        
        if openConfirmAssetsButton {
            confirmAssetsButton.isHidden = false
        } else {
            navigationController?.navigationBar.isHidden = true
            confirmAssetsButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.creatCurrencyTransaction()
        guard let currencyName = currencyName else {
            print("currencyName is nil")
            return
        }
        guard let orderId = orderId else {
            print("error")
            return
        }
//        print("👽orderId\(orderId)")
        let param = "/\(orderId)"
        let semaphore = DispatchSemaphore(value: 0)
        CoinbaseService.shared.getApiSingleResponse(api: CoinbaseApi.orderBaseURL,
                                                    param: param,
                                                    authRequired: true,
                                                    requestPath: RequestPath.orderBaseURL,
                                                    requestPathParam: param) { [weak self] (order: (ProductOrders)) in
            print("🎃orders\(order)")
            guard let doneTime = order.doneAt else { return }
            guard let createTime = order.createdAt else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
            DispatchQueue.main.async {
                if let date = dateFormatter.date(from: doneTime ) {
                    let timeIntervalSince1970 = date.timeIntervalSince1970
                    let date = Date(timeIntervalSince1970: timeIntervalSince1970)
                    let taiwanTime = date.date2String(dateFormat: "yyyy-MM-dd HH:mm:ss")
                    self?.transactionSuccessView?.doneAtLabel.text = taiwanTime
                } else {
                    print("error")
                }
                if let date = dateFormatter.date(from: createTime ) {
                    let timeIntervalSince1970 = date.timeIntervalSince1970
                    let date = Date(timeIntervalSince1970: timeIntervalSince1970)
                    let taiwanTime = date.date2String(dateFormat: "yyyy-MM-dd HH:mm:ss")
                    self?.transactionSuccessView?.createAtLabel.text = taiwanTime
                } else {
                    print("error")
                }
                if let side = SideData(rawValue: order.side) {
                    self?.transactionSuccessView?.sideButton.setTitle(side.rawValue, for: .normal)
                }
                if order.side == "buy" {
                    self?.transactionSuccessView?.sideButton.setTitle("BUY", for: .normal)
                    self?.transactionSuccessView?.sideButton.backgroundColor = .systemGreen
                } else {
                    self?.transactionSuccessView?.sideButton.setTitle("SELL", for: .normal)
                    self?.transactionSuccessView?.sideButton.backgroundColor = .systemCyan
                }
                self?.transactionSuccessView?.sideButton.layer.cornerRadius = 5
                guard let size = order.size else {
                    print("currencyName is nil")
                    return
                }
                self?.transactionSuccessView?.sizeLabel.text = "\(size) \(currencyName)"
                var price = (Double(order.executedValue ) ?? 0) / (Double(order.size ?? "") ?? 0)
                if price.isNaN {
                    self?.transactionSuccessView?.priceLabel.text = "USD$ 0"
                } else {
                    self?.transactionSuccessView?.priceLabel.text = "USD$ \(price)"
                }
                
                let pay = Double(order.executedValue)
                self?.transactionSuccessView?.payLabel.text = "USD$ \(NumberFormatter.formattedNumber(pay ?? 0))"
            }
            semaphore.signal()
        }
        semaphore.wait()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func creatCurrencyTransaction() {
        //nibName:View的名稱
        transactionSuccessView = UINib(nibName: "TransactionSuccessView", bundle: nil).instantiate(withOwner: transactionSuccessView, options: nil).first as? TransactionSuccessView
        self.setNibView(transactionView: transactionSuccessView)
    }
    func setNibView(transactionView: TransactionSuccessView?) {
        if let transactionView = transactionView {
            self.completedView.addSubview(transactionView)
            transactionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                transactionView.topAnchor.constraint(equalTo: self.completedView.topAnchor),
                transactionView.bottomAnchor.constraint(equalTo: self.completedView.bottomAnchor),
                transactionView.leadingAnchor.constraint(equalTo: self.completedView.leadingAnchor),
                transactionView.trailingAnchor.constraint(equalTo: self.completedView.trailingAnchor)
            ])
        }
    }
    
    @IBAction func returnToPreviousPage(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func confirmAssets(_ sender: Any) {
        let tabBar = self.navigationController?.presentingViewController as? UITabBarController
        
        tabBar?.selectedIndex = 1
        self.navigationController?.dismiss(animated: true)
        (tabBar?.viewControllers![0] as? UINavigationController)!.popToRootViewController(animated: false)
    }
}
