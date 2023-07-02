//
//  CurrencyDetailsTableViewCell1.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/1.
//

import UIKit

class CurrencyDetailsTableViewCell1: UITableViewCell {
    @IBOutlet weak var realTimeBidLabel: UILabel!
    @IBOutlet weak var realTimeAskLabel: UILabel!
    @IBOutlet weak var pastAveragePriceLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var lineChartView: UIView!
    @IBOutlet weak var pastAveragePriceView: UIView!
    
    @IBOutlet var timeIntervalsBtns: [UIButton]!
    @IBOutlet var timeIntervalsViews: [UIView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pastAveragePriceView.isHidden = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func timeIntervalsBtns(_ sender: UIButton) {
        for btn in timeIntervalsBtns {
            btn.isSelected = false
        }
        sender.isSelected = true
    }
    
    @IBAction func showAllTradeHistory(_ sender: Any) {
    }
    
    
}
