//
//  TransactionCompletedViewController.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/5.
//

import UIKit

class TransactionCompletedViewController: UIViewController {
    
    @IBOutlet weak var confirmAssetsButton: UIButton!
    @IBOutlet weak var completedView: UIView!
    
    var currencyName: String?
    var isSell: Bool = true // true為買入、false為賣出
    var orderId: String?
    var transactionSuccessView: TransactionSuccessView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.completedView.layer.cornerRadius = 5
        self.completedView.layer.shadowColor = UIColor.black.cgColor
        self.completedView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.completedView.layer.shadowOpacity = 0.25
        self.completedView.layer.shadowRadius = 4
        self.creatCurrencyTransaction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        CoinbaseService.shared.
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func creatCurrencyTransaction() {
        //nibName:View的名稱
        transactionSuccessView = UINib(nibName: "TransactionSuccessView", bundle: nil).instantiate(withOwner: transactionSuccessView, options: nil).first as? TransactionSuccessView
        
        guard let currencyName = currencyName else {
            print("currencyName is nil")
            return
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
