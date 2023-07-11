//
//  CategorySelectionViewController.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/8.
//

import UIKit
import Kingfisher

class CategorySelectionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var accounts: [Account] = []
    var currencySelection: String = ""
    var setCurrency: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(UINib(nibName: "SelectCurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectCurrencyTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CoinbaseService.shared.getApiResponse(api: CoinbaseApi.accounts,
                                              authRequired: true,
                                              requestPath: RequestPath.accounts,
                                              httpMethod: HttpMethod.get) { [weak self] (accounts: [Account]) in
            self?.accounts = accounts
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func getIconUrl(imageView: UIImageView, for coinCode: String) {
        let lowercased = coinCode.lowercased()
        let coinIconUrl = "https://cryptoicons.org/api/icon/\(lowercased)/200"
        imageView.kf.setImage(with: URL(string: coinIconUrl))
    }
}

extension CategorySelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectCurrencyTableViewCell", for: indexPath) as? SelectCurrencyTableViewCell else {
            print("error")
            return UITableViewCell()
        }
        if indexPath.row == 0 {
            cell.currencyImage.image = UIImage(named: "icon_32px_allCurrancy")
            cell.currencyNameLabel.text = "全部幣種"
            if currencySelection == cell.currencyNameLabel.text {
                cell.sellectedImage.isHidden = false
            } else {
                cell.sellectedImage.isHidden = true
            }
        } else {
            let currency = accounts[indexPath.row - 1]
            cell.currencyNameLabel.text = currency.currency
            let currencyName = currency.currency
            self.getIconUrl(imageView: cell.currencyImage, for: currencyName)
            if currencySelection == currencyName {
                cell.sellectedImage.isHidden = false
            } else {
                cell.sellectedImage.isHidden = true
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.setCurrency?("全部幣種")
        } else {
            let result = accounts[indexPath.row - 1].currency
            self.setCurrency?(result)
        }
        dismiss(animated: true, completion: nil)
    }
    
}
