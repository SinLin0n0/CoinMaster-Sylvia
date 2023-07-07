//
//  CurrencyDetailsTableViewCell2.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/1.
//

import UIKit

class CurrencyDetailsTableViewCell2: UITableViewCell {
    
    @IBOutlet weak var sideButton: UIButton!
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    enum SideData: String {
        case buy = "BUY"
        case sell = "SELL"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        statusView.layer.cornerRadius = 4
        sideButton.layer.cornerRadius = 4
    }
    
    func setUI(data: ProductOrders, currency: String) {
        
        if let side = SideData(rawValue: data.side) {
            sideButton.setTitle(side.rawValue, for: .normal)
        }
        productNameLabel.text = "購入\(currency)"
        let priceFormatted = NumberFormatter.formattedNumber(Double(data.executedValue) ?? 0)
        
        priceLabel.text = "USD$ \(priceFormatted)"
        let time = data.doneAt
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"

        if let date = dateFormatter.date(from: time) {
            let timeIntervalSince1970 = date.timeIntervalSince1970
            let date = Date(timeIntervalSince1970: timeIntervalSince1970)
            let taiwanTime = date.date2String(dateFormat: "yyyy-MM-dd HH:mm")
            timeLabel.text = taiwanTime
        } else {
            print("error")
        }
    }
}
