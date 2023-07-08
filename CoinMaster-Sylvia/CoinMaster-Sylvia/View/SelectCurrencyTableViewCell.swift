//
//  SelectCurrencyTableViewCell.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/8.
//

import UIKit

class SelectCurrencyTableViewCell: UITableViewCell {
    @IBOutlet weak var currencyImage: UIImageView!
    @IBOutlet weak var currencyNameLabel: UILabel!
    @IBOutlet weak var sellectedImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sellectedImage.isHidden = true
    }

}
