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
    
    var currencyName: String?
    var isSell: Bool = true // true為買入、false為賣出
    var orderId: String? = "28ffde51-64fe-413b-b747-8cb7120c08b2"
    var transactionSuccessView: TransactionSuccessView?
//    var order: ProductOrders?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.completedView.layer.cornerRadius = 5
        self.completedView.layer.shadowColor = UIColor.black.cgColor
        self.completedView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.completedView.layer.shadowOpacity = 0.25
        self.completedView.layer.shadowRadius = 4
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
        print("👽orderId\(orderId)")
        let param = "/\(orderId)"
        CoinbaseService.shared.getApiSingleResponse(api: CoinbaseApi.orderBaseURL,
                                              param: param,
                                              authRequired: true,
                                              requestPath: RequestPath.orderBaseURL,
                                              requestPathParam: param) { [weak self] (order: (ProductOrders)) in
            print("🎃orders\(order)")
            let doneTime = order.doneAt
            let createTime = order.createdAt
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"

            DispatchQueue.main.async {
                if let date = dateFormatter.date(from: doneTime) {
                    let timeIntervalSince1970 = date.timeIntervalSince1970
                    let date = Date(timeIntervalSince1970: timeIntervalSince1970)
                    let taiwanTime = date.date2String(dateFormat: "yyyy-MM-dd HH:mm:ss")
                    self?.transactionSuccessView?.doneAtLabel.text = taiwanTime
                } else {
                    print("error")
                }
                if let date = dateFormatter.date(from: createTime) {
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
                self?.transactionSuccessView?.sideButton.layer.cornerRadius = 5
                self?.transactionSuccessView?.sizeLabel.text = "\(order.size) \(currencyName)"
                self?.transactionSuccessView?.priceLabel.text = "USD$ \(order.price)"
                let pay = (Double(order.size) ?? 0) * (Double(order.price) ?? 0)
                self?.transactionSuccessView?.payLabel.text = "USD$ \(NumberFormatter.formattedNumber(pay ?? 0))"
            }
            
        }
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
        if let tabBarController = presentingViewController as? UITabBarController {
              let desiredIndex = 1

              if desiredIndex >= 0 && desiredIndex < tabBarController.viewControllers?.count ?? 0 {
                tabBarController.selectedIndex = desiredIndex
              }

              UIView.animate(withDuration: 1, animations: {}) { _ in
                self.dismiss(animated: false, completion: nil)
              }
            }
    }

    
}
