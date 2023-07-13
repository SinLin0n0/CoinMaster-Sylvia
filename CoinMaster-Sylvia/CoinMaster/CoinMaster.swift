//
//  CoinMaster.swift
//  CoinMaster
//
//  Created by Sin on 2023/7/12.
//

import WidgetKit
import SwiftUI
import CoinMasterInfoKit
import UIKit

struct Provider: TimelineProvider {
    //  can’t using mutating to tell Swift they will change values, that in SwiftUI because it uses a computed property.
    //    @State var usdPairs: [CurrencyPair] = []
    //    @State var productsStats: ProductsStats?
    //    @State var usdPairsStats: [String: (Double, Double)] = [:]
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }
    // getTimeline更新小工具時會呼叫此方法
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 60, to: currentDate)!
        
        CoinbaseService.shared.getApiResponse(api: CoinbaseApi.products, authRequired: false) { (products: [CurrencyPair]) in
            var usdPairs = products.filter { currencyPair in
                return String(currencyPair.id.suffix(3)) == "USD" && currencyPair.auctionMode == false && currencyPair.status == "online"
                // 📍baseCurrency
            }
            self.fetchUSDStats(usdPairs: usdPairs, completion: completion)
        }
    }
    
    func fetchUSDStats(usdPairs: [CurrencyPair], completion: @escaping (Timeline<Entry>) -> ()) {
        let group = DispatchGroup()
        var dataMapping: [String: (Double, Double, String)] = [:]
        for pair in usdPairs {
            group.enter()
            
            CoinbaseService.shared.getApiSingleResponse(api: CoinbaseApi.products, param: "/\(pair.id)/stats", authRequired: false) { (products: ProductsStats) in
                let open = Double(products.open) ?? 0
                let last = Double(products.last) ?? 0
                let trend = (last - open) / last * 100
                
                let low = Double(products.low) ?? 0
                let high = Double(products.high) ?? 0
                let average = (low + high) / 2
//                guard let firstPair = usdPairs.first else { return }
                let imageName = pair.baseCurrency.lowercased()
                dataMapping.updateValue((average, trend, imageName), forKey: pair.id)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            var entries: [SimpleEntry] = []
            let currentDate = Date()
            //               for hourOffset in 0 ..< 5 {
            //                   let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, data: usdPairs, dataMapping: dataMapping)
            let entry = SimpleEntry(date: currentDate, data: usdPairs, dataMapping: dataMapping)
            //                   entries.append(entry)
            //               }
            //               let timeline = Timeline(entries: entries, policy: .atEnd)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date = Date()
    var data: [CurrencyPair] = []
    var dataMapping: [String: (Double, Double, String)] = [:]
}

// CoinMasterEntryView定義外觀
struct CoinMasterEntryView : View {
    var entry: Provider.Entry
    var chartData: [Double] {
        (0..<10).map { _ in Double.random(in: 0...20) }
    }
    
    var body: some View {
        ZStack{
            Color.black.opacity(0.85)
            VStack {
                ForEach(Array(entry.data.enumerated()), id: \.element.id) { index, currencyPair in
                    if let productStat = entry.dataMapping["\(currencyPair.id)"] {
                        let average = productStat.0
                        let trend = productStat.1
                        let imageName = productStat.2
                        VStack{
                            HStack{
                                Spacer(minLength: 16)
                                Image("\(imageName)")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Spacer(minLength: 16)
                                
                                HStack {
                                    Text("\(currencyPair.baseCurrency)")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                    if trend >= 0 {
                                        LineChartContentView(chartData: chartData, lineColor: .green)
                                            .frame(width: 60, height: 20)
                                    } else {
                                        LineChartContentView(chartData: chartData, lineColor: .pink)
                                            .frame(width: 60, height: 20)
//                                            .layoutPriority(1)
                                    }
                                }
//                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                                
                                Spacer(minLength: 10)
                                VStack{
                                    Text(NumberFormatter.formattedNumber(average))
                                        .font(.system(size: 13))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.trailing)
                                        .lineLimit(nil)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .padding(.bottom, 0)
                                    if trend > 0 {
                                        Text("+\(String(format: "%.2f", trend))%")
                                            .font(.system(size: 13))
                                            .foregroundColor(.green)
                                            .multilineTextAlignment(.trailing)
                                            .lineLimit(nil)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    } else if trend < 0 {
                                        Text("\(String(format: "%.2f", trend))%")
                                            .font(.system(size: 13))
                                            .foregroundColor(.red)
                                            .multilineTextAlignment(.trailing)
                                            .lineLimit(nil)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    } else {
                                        Text("\(String(format: "%.2f", trend))%")
                                            .font(.system(size: 13))
                                            .foregroundColor(.green)
                                            .multilineTextAlignment(.trailing)
                                            .lineLimit(nil)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                }
                                .frame(width: 80)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
//                                Spacer(minLength: 24)
                            }
                        }
                        if index != entry.data.count - 1 {
                            Divider().background(Color.white) // 添加白色分隔线
                        }
                    }
                }
                .padding(.vertical, 1.5)
            }
        }
    }
    
}

// CoinMaster定義顯示名稱和描述
struct CoinMaster: Widget {
    let kind: String = "CoinMaster"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CoinMasterEntryView(entry: entry)
        }
        .configurationDisplayName("CoinMaster")
        .description("This widget is designed to display the Coinbase information.")
        .supportedFamilies([.systemMedium]) // Widget大小
    }
}

struct CoinMaster_Previews: PreviewProvider {
    static var previews: some View {
        CoinMasterEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
