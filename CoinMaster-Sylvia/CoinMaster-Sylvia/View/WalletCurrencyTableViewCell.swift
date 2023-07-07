//
//  WalletCurrencyTableViewCell.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/6.
//

import UIKit

class WalletCurrencyTableViewCell: UITableViewCell {

    @IBOutlet weak var currencyImage: UIImageView!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var currencyBalance: UILabel!
    @IBOutlet weak var conversionTWDLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

}
