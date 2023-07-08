//
//  WalletViewController.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/6.
//

import UIKit
import Kingfisher
import MJRefresh

class WalletViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var balanceView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    var walletBalanceView: WalletBalanceView?
    var walletHeaderView: WalletHeaderView?
    var accounts: [Account] = []
    var totalBalanceInTWD: Double = 0
    var hideBalanceViewIsHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "WalletCurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "WalletCurrencyTableViewCell")
        // Refresch
        let header  = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header = header
        
    }
    
    @objc func headerRefresh() {
        self.tableView!.reloadData()
        self.tableView.mj_header?.endRefreshing()
    }
    
    @objc func hideBalance(_ sender: Any) {
        if hideBalanceViewIsHidden {
            walletBalanceView?.hideBalanceButton.setImage(UIImage(named: "eye-close"), for: .normal)
            walletBalanceView?.hideBalanceView.isHidden = false
            hideBalanceViewIsHidden = false
        } else {
            walletBalanceView?.hideBalanceButton.setImage(UIImage(named: "eye-open"), for: .normal)
            walletBalanceView?.hideBalanceView.isHidden = true
            hideBalanceViewIsHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // SetUI
        tabBarController?.tabBar.isHidden = false
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationItem.backButtonTitle = ""
        createCustomView(nibName: "WalletBalanceView", containerView: balanceView, customView: &walletBalanceView)
        createCustomView(nibName: "WalletHeaderView", containerView: headerView, customView: &walletHeaderView)
        self.walletBalanceView?.hideBalanceView.isHidden = true
        walletBalanceView?.hideBalanceButton.addTarget(self, action: #selector(hideBalance), for: .touchUpInside)
        // FetchData
        self.totalBalanceInTWD = 0
        self.accounts = []
        let dispatchGroup = DispatchGroup()
        CoinbaseService.shared.getApiResponse(api: CoinbaseApi.accounts,
                                              authRequired: true,
                                              requestPath: RequestPath.accounts,
                                              httpMethod: HttpMethod.get) { [weak self] (accounts: [Account]) in
            for account in accounts {
                if let balance = Double(account.balance) {
                    let rate = account.currency
                    dispatchGroup.enter()
                    balance.convertToTWD(rate: rate) { convertedValue in
                        self?.totalBalanceInTWD += convertedValue
                        //                        print("💵\(rate)換成\(convertedValue)")
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.notify(queue: .main) {
                //                print("💰總餘額\(String(describing: self?.totalBalanceInTWD))")
                guard let totalBalanceInTWD = self?.totalBalanceInTWD else {
                    print("error")
                    return
                }
                self?.walletBalanceView?.balanceLabel.text = NumberFormatter.formattedNumber(totalBalanceInTWD)
                self?.accounts = accounts
                self?.tableView.reloadData()
            }
        }
    }
    
    func createCustomView<T: UIView>(nibName: String, containerView: UIView, customView: inout T?) {
        customView = UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? T
        setNibView(transactionView: customView, containerView: containerView)
    }
    
    func setNibView<T: UIView>(transactionView: T?, containerView: UIView) {
        if let customView = transactionView {
            containerView.addSubview(customView)
            customView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                customView.topAnchor.constraint(equalTo: containerView.topAnchor),
                customView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                customView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                customView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
        }
    }
    
    func getIconUrl(imageView: UIImageView, for coinCode: String) {
        let lowercased = coinCode.lowercased()
        let coinIconUrl = "https://cryptoicons.org/api/icon/\(lowercased)/200"
        imageView.kf.setImage(with: URL(string: coinIconUrl))
    }
    
    @IBAction func assetTracking(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "AssetTrackingViewController") as! AssetTrackingViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WalletCurrencyTableViewCell", for: indexPath) as? WalletCurrencyTableViewCell else {
            print("error")
            return UITableViewCell()
        }
        let currency = accounts[indexPath.row]
        let currencyBalance = Double(currency.balance) ?? 0
        let currencyName = currency.currency
        cell.currencyBalance.text = NumberFormatter.formattedNumber(currencyBalance)
        cell.currencyNameLabel.text = currency.currency
        self.getIconUrl(imageView: cell.currencyImage, for: currencyName)
        currencyBalance.convertToTWD(rate: currencyName) { convertedValue in
            DispatchQueue.main.async {
                let conversionTWD = NumberFormatter.formattedNumber(convertedValue)
                cell.conversionTWDLabel.text = "≈ USD$ \(conversionTWD)"
            }
        }
        return cell
    }
}
