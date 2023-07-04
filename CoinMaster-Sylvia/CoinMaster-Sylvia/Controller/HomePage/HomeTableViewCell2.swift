//
//  HomeTableViewCell.swift
//  LineChart
//
//  Created by Sin on 2023/6/28.
//

import UIKit
import SwiftUI

class HomeTableViewCell2: UITableViewCell {
    
    @IBOutlet weak var currencyEnLabel: UILabel!
    @IBOutlet weak var currencyChLabel: UILabel!
    
    @IBOutlet weak var currencyIconImage: UIImageView!
    
    @IBOutlet weak var exchangeRateLabel: UILabel!
    
    @IBOutlet weak var trendLabel: UILabel!
    
    @IBOutlet weak var lineChartView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    private var lineChartContentViewHost: UIHostingController<LineChartContentView>?

    func setupLineChartView(with data: [Double], lineColor: UIColor) {

        let convertedColor = Color(lineColor)
        let lineChartContentView = LineChartContentView(chartData: data, lineColor: convertedColor)
        lineChartContentViewHost = UIHostingController(rootView: lineChartContentView)
        
        guard let lineChartContentViewHost = lineChartContentViewHost else {
            return
        }
        
        lineChartContentViewHost.view.translatesAutoresizingMaskIntoConstraints = false

        lineChartView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        lineChartView.addSubview(lineChartContentViewHost.view)
        
        NSLayoutConstraint.activate([
            lineChartContentViewHost.view.leadingAnchor.constraint(equalTo: lineChartView.leadingAnchor),
            lineChartContentViewHost.view.trailingAnchor.constraint(equalTo: lineChartView.trailingAnchor),
            lineChartContentViewHost.view.topAnchor.constraint(equalTo: lineChartView.topAnchor),
            lineChartContentViewHost.view.bottomAnchor.constraint(equalTo: lineChartView.bottomAnchor)
        ])
    }

}
