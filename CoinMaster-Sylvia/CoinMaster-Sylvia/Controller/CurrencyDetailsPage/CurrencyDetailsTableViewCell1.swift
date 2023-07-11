//
//  CurrencyDetailsTableViewCell1.swift
//  CoinMaster-Sylvia
//
//  Created by Sin on 2023/7/1.
//

import UIKit
import Charts

class CurrencyDetailsTableViewCell1: UITableViewCell {
    var doCalcDate: ((TimeIntervalOption, TimeInterval ,
                      @escaping ([Double], [Double], TimeInterval) -> Void) -> Void)!
    
    @IBOutlet weak var realTimeBidView: UIView!
    @IBOutlet weak var realTimeBidLabel: UILabel!
    
    @IBOutlet weak var realTimeAskView: UIView!
    @IBOutlet weak var realTimeAskLabel: UILabel!
    @IBOutlet weak var historyAverageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var historyAverageView: UIView!
    
    @IBOutlet weak var assetTracking: UIButton!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var threeMonthButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var threeMonthView: UIView!
    @IBOutlet weak var yearView: UIView!
    @IBOutlet weak var allView: UIView!
    
    
    var data: LineChartData!
    var minXIndex: Double!
    var maxXIndex: Double!
    var dataSet: LineChartDataSet!
    var timestamps: [Double] = []
    var dataEntries: [ChartDataEntry] = []
    var currencyName: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        historyAverageView.isHidden = true
        lineChartView.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 20)
        
    }
    
    @IBAction func didDayButtonTapped(_ sender: Any) {
        setButton(exceptButton: dayButton, exceptView: dayView)
        self.doCalcDate(.oneDay, Date().timeIntervalSince1970) { averages, timestamps, endTime in
            DispatchQueue.main.async {
                self.setChartView(dataArray: averages)
            }
            self.timestamps = timestamps
        }
    }
    
    @IBAction func didWeekButtonTapped(_ sender: Any) {
        setButton(exceptButton: weekButton, exceptView: weekView)
        self.doCalcDate(.oneWeek, Date().timeIntervalSince1970) { averages, timestamps, nextEndTime  in
            DispatchQueue.main.async {
                self.setChartView(dataArray: averages)
            }
            self.timestamps = timestamps
        }
    }
    @IBAction func didMonthButtonTapped(_ sender: Any) {
        setButton(exceptButton: monthButton, exceptView: monthView)
        self.doCalcDate(.oneMonth, Date().timeIntervalSince1970) { averages, timestamps, nextEndTime  in
            DispatchQueue.main.async {
                self.setChartView(dataArray: averages)
            }
            self.timestamps = timestamps
        }
    }
    @IBAction func didThreeMonthButtonTapped(_ sender: Any) {
        setButton(exceptButton: threeMonthButton, exceptView: threeMonthView)
        self.doCalcDate(.threeMonths, Date().timeIntervalSince1970) { averages, timestamps, nextEndTime  in
            DispatchQueue.main.async {
                self.setChartView(dataArray: averages)
            }
            self.timestamps = timestamps
        }
    }
    @IBAction func didYearButtonTapped(_ sender: Any) {
        setButton(exceptButton: yearButton, exceptView: yearView)
        self.doCalcDate(.threeHundredDays, Date().timeIntervalSince1970) { averages, timestamps, nextEndTime  in
            let olderAverages = averages
            let olderTimestamps = timestamps
            self.doCalcDate(.oneYear, nextEndTime) { averages, timestamps, nextEndTime in
                let allAverages = olderAverages + averages
                let allTimestamps = olderTimestamps + timestamps
                DispatchQueue.main.async {
                    self.setChartView(dataArray: allAverages)
                }
                self.timestamps = allTimestamps
            }
        }
    }
    @IBAction func didAllButtonTapped(_ sender: Any) {
        setButton(exceptButton: allButton, exceptView: allView)
        self.getAllTransactionRecords()
    }
    
    func getAllTransactionRecords() {
        let calendar = Calendar.current
        var date = Date()
        
        var array = [CandlesDataPoint]()
        var candlesTemp = [CandlesDataPoint]()
        var index: Int = 0
        
        let semaphore = DispatchSemaphore(value: 0)
        
        repeat {
            let threeHundredDaysAgo = calendar.date(byAdding: .day, value: -300, to: date)!
            
            print("---------------------")
            print("Start = \(threeHundredDaysAgo)")
            print("End = \(date)")
            let granularity = 86400
            let start = Int(threeHundredDaysAgo.timeIntervalSince1970)
            let end = Int(date.timeIntervalSince1970)
            let apiParam = "/\( currencyName!)-USD/candles?start=\(start)&end=\(end)&granularity=\(granularity)"
            CoinbaseService.shared.getApiResponse(api: CoinbaseApi.products,
                                                  param: apiParam,
                                                  authRequired: false) { [weak self] (candles: [[Double]]) in
                candlesTemp = candles.map({ candle in
                    return CandlesDataPoint(numbers: candle)
                })
                
                array += candlesTemp
                date = threeHundredDaysAgo
                index += 1
                
                semaphore.signal()
                print("第\(index)趟完成")
            }
            
            semaphore.wait()
            
            print(array.count)
            print(candlesTemp.count)
            print("---------------------")
        } while(candlesTemp.count != 0)
        let reversedCandlesDataPoint = array.reversed()
        let averages = reversedCandlesDataPoint.map { point in
            return point.average
        }
        let timestamps = array.map { point in
            let time = point.timestamp
            //            let date = Date(timeIntervalSince1970: time)
            //            let taiwanTime = date.date2String(dateFormat: "yyyy-MM-dd HH:mm")
            return time
        }
        DispatchQueue.main.async {
            self.setChartView(dataArray: averages)
        }
        self.timestamps = timestamps
        print(array.count)
    }

    
}

extension CurrencyDetailsTableViewCell1: ChartViewDelegate, ValueFormatter {
    func changeChartViewData(dataArray: [Double], timeArray: [Double]) {
        lineChartView.data = nil
        lineChartView.xAxis.valueFormatter = nil
        lineChartView.marker = nil
        lineChartView.notifyDataSetChanged()
        if timeArray.isEmpty == false {
            minXIndex = timeArray[dataArray.firstIndex(of: dataArray.min() ?? 0) ?? 0]
            maxXIndex = timeArray[dataArray.firstIndex(of: dataArray.max() ?? 0) ?? 0]
        }
        dataEntries = []
        dataSet = nil
        for i in 0..<dataArray.count {
            let formattedValue = String(format: "%.2f", dataArray[i])
            let dataEntry = ChartDataEntry(x: timeArray[i], y: Double(formattedValue) ?? 0)
            dataEntries.append(dataEntry)
        }
        
        dataSet = LineChartDataSet(entries: dataEntries)
        dataSet.mode = .linear
        dataSet.drawCirclesEnabled = false
        dataSet.valueFormatter = self
        dataSet.highlightLineWidth = 1.5
        dataSet.highlightColor = .red
        dataSet.highlightEnabled = true
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.lineWidth = 1.2
        dataSet.colors = [UIColor.red]
        dataSet.valueColors = [UIColor.red]
        dataSet.valueFont = .systemFont(ofSize: 12)
        data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
        
        if let data = lineChartView.data {
            if let lineDataSet = data.dataSets.first as? LineChartDataSet {
                let startColor = UIColor.red
                let endColor = UIColor.white
                let gradientColors = [startColor.cgColor, endColor.cgColor] as CFArray
                let colorLocations: [CGFloat] = [0.0, 1.0]
                if let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: colorLocations) {
                    lineDataSet.fill = LinearGradientFill(gradient: gradient, angle: 270)
                    lineDataSet.drawFilledEnabled = true
                }
            }
        }
        
        if let selectedEntry = dataEntries.first {
            
            let coinImage = UIImage(named: "fulldown")
            let coinMarker = MarkerViewImage(color: .clear, font: .systemFont(ofSize: 10), textColor: .white, insets: .zero, image: coinImage)
            coinMarker.refreshContent(entry: selectedEntry, highlight: Highlight(x: selectedEntry.x, y: selectedEntry.y, dataSetIndex: 0))
            lineChartView.marker = coinMarker
        }
        
        lineChartView.notifyDataSetChanged()
    }
    
    func setButton(exceptButton currentButton: UIButton, exceptView currentView: UIView) {
        let buttons: [UIButton] = [
            dayButton, weekButton, monthButton,
            threeMonthButton, yearButton, allButton
        ]
        
        let views: [UIView] = [
            dayView, weekView, monthView,
            threeMonthView, yearView, allView
        ]
        
        for button in buttons {
            if button != currentButton {
                button.setTitleColor(.lightGray, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            } else {
                button.setTitleColor(.systemPink, for: .normal)
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            }
        }
        
        for view in views {
            if view != currentView {
                view.backgroundColor = UIColor.white
            } else {
                view.backgroundColor = UIColor.systemPink
            }
        }
    }
    
    func setChartView(dataArray: [Double]) {
        lineChartView.delegate = self
        lineChartView.chartDescription.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.xAxis.enabled = false
        lineChartView.leftAxis.enabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        
        changeChartViewData(dataArray: dataArray, timeArray: timestamps)
        print("🤡\(dataArray)")
    }
    
    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        guard let lineChartView = chartView as? LineChartView else {
            return
        }
        historyAverageView.isHidden = true
        realTimeAskView.isHidden = false
        realTimeBidView.isHidden = false
        lineChartView.data?.dataSets.forEach { dataSet in
            if dataSet is LineChartDataSet {
                lineChartView.highlightValues([])
            }
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        historyAverageLabel.text = "\(entry.y)"
        let time = entry.x
        let date = Date(timeIntervalSince1970: time)
        let taiwanTime = date.date2String(dateFormat: "yyyy-MM-dd HH:mm")
        timestampLabel.text = taiwanTime
        historyAverageView.isHidden = false
        realTimeAskView.isHidden = true
        realTimeBidView.isHidden = true
    }
    
    func stringForValue(_ value: Double, entry: Charts.ChartDataEntry, dataSetIndex: Int, viewPortHandler: Charts.ViewPortHandler?) -> String {
        if entry.x == minXIndex || entry.x == maxXIndex {
            entry.icon = UIImage(named: "down")
            return "\(entry.y)"
        } else {
            return ""
        }
    }
}

class MarkerViewImage: MarkerView {
    private var circleImageView: UIImageView?
    private var circleImage: UIImage?
    private var imageSize: CGSize
    
    init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets, image: UIImage?) {
        self.circleImage = image
        self.imageSize = image?.size ?? CGSize.zero
        
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.backgroundColor = .clear
        
        circleImageView = UIImageView(image: circleImage)
        circleImageView?.frame.size = imageSize
        addSubview(circleImageView!)
        
        circleImageView?.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
