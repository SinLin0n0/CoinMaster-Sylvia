//
//  AssetTrackingViewController.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/8.
//

import UIKit
import MJRefresh
import JGProgressHUD
import CoinMasterInfoKit

class AssetTrackingViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var productOrders: [ProductOrders] = []
    var selectedCurrency: String = "全部幣種"
//    let hud = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "NoDataTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataTableViewCell")
        // Refresch
        let header  = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header = header
        HudLoading.shared.setHud(view: self.view)
      
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // SetUI
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = false
        // FetchData
        var productId = ""
        if selectedCurrency == "全部幣種" {
            self.fetchData(productId: productId)
        } else {
            productId = "&product_id=\(selectedCurrency)-USD"
            self.fetchData(productId: productId)
        }
    }
    
    func fetchData(productId: String, completion: @escaping () -> Void = {}) {
      
        let param = "?limit=100&status=done\(productId)"
        CoinbaseService.shared.getApiResponse(api: CoinbaseApi.orderBaseURL,
                                              param: param,
                                              authRequired: true,
                                              requestPath: RequestPath.orderBaseURL,
                                              requestPathParam: param) { [weak self] (orders: [ProductOrders]) in
            guard let self = self else { return }
            self.productOrders = orders
            DispatchQueue.main.async {
                HudLoading.shared.dismissHud()
                self.tableView.reloadData()
                self.tableView.mj_header?.endRefreshing()
                if orders.isEmpty {
                    AlertUtils.alert(title: "Internal Server Error", message: "資料維護中，請稍後再試。", from: self)
                }
                completion()
            }
        }
    }
    
    @objc func headerRefresh() {
        var productId = ""
        if selectedCurrency == "全部幣種" {
            self.fetchData(productId: productId)
        } else {
            productId = "&product_id=\(selectedCurrency)-USD"
            self.fetchData(productId: productId)
        }
    }
    
    @IBSegueAction func showCategorySelection(_ coder: NSCoder) -> CategorySelectionViewController? {
        let controller = CategorySelectionViewController(coder: coder)
        if let sheetPresentationController = controller?.sheetPresentationController {
            sheetPresentationAppearance(sheetPresentationController: sheetPresentationController)
        }
        return controller
    }
    
    func sheetPresentationAppearance(sheetPresentationController: UISheetPresentationController) {
        sheetPresentationController.detents = [.medium()]
        sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = false
        sheetPresentationController .preferredCornerRadius = 20
    }
}
extension AssetTrackingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productOrders.isEmpty ? 2 : productOrders.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategorySelectionTableViewCell", for: indexPath) as? CategorySelectionTableViewCell else {
                print("error")
                return UITableViewCell()
            }
            cell.separatorInset = UIEdgeInsets.zero
            cell.currencySelectionButton.setTitle(self.selectedCurrency, for: .normal)
            cell.currencySelectionButton.addTarget(self, action: #selector(toNextVC), for: .touchUpInside)
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionRecordsTableViewCell", for: indexPath) as? TransactionRecordsTableViewCell else {
                print("error")
                return UITableViewCell()
            }
            let data = productOrders[indexPath.row - 1]
            cell.setUI(data: data)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 && indexPath.row <= productOrders.count {
            let orderId = productOrders[indexPath.row - 1].id
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewController(withIdentifier: "TransactionCompletedViewController") as! TransactionCompletedViewController
            nextViewController.orderId = orderId
            let inputString = productOrders[indexPath.row - 1].productID
            let separatedComponents = inputString.components(separatedBy: "-")
            let result = separatedComponents.first ?? ""
            nextViewController.currencyName = result
            nextViewController.openConfirmAssetsButton = false
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    @objc func toNextVC () {
        performSegue(withIdentifier: "CategorySelectionSegue", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CategorySelectionSegue" {
            if let destinationVC = segue.destination as? CategorySelectionViewController {
                destinationVC.currencySelection = selectedCurrency
                destinationVC.setCurrency = { [weak self] result in
                    HudLoading.shared.setHud(view: self?.view ?? UIView())
                    var productId = ""
                    if result == "全部幣種" {
                        self?.fetchData(productId: productId)
                        self?.selectedCurrency = result
                    } else {
                        productId = "&product_id=\(result)-USD"
                        self?.fetchData(productId: productId)
                        self?.selectedCurrency = result
                    }
                }
            }
        }
    }
}
