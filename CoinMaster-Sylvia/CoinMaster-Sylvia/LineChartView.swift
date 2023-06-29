//
//  LineChartView.swift
//  LineChart
//
//  Created by Sin on 2023/6/28.
//

import SwiftUI

struct LineChartContentView: View {
    let chartData: [Double]

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            let dataCount = chartData.count

            Path { path in
                for i in 0..<dataCount {
                    let xPosition = width * CGFloat(i) / CGFloat(dataCount - 1)
                    let yPosition = height * CGFloat(chartData[i]) / CGFloat(chartData.max() ?? 1)

                    if i == 0 {
                        path.move(to: CGPoint(x: xPosition, y: height))
                    }

                    path.addLine(to: CGPoint(x: xPosition, y: height - yPosition))
                }
            }
            .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }
}

//struct LineChartContentView: View {
//    let chartData: [(Double)]
//
//    var body: some View {
//            GeometryReader { geometry in
//                let dataCount = chartData.count
//                let stepHeight = (geometry.size.height) / CGFloat(chartData.max() ?? 1)
//                let stepWidth = (geometry.size.width) / CGFloat(dataCount - 1)
//                var path: Path {
//                        let points = self.chartData
//                        return Path.lineChart(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
//                    }
//                Path { path in
//                    for i in 0..<dataCount {

//                        let xPosition = (width / CGFloat(dataCount - 1)) * CGFloat(i)
//                        let yPosition = (height / CGFloat(chartData.max() ?? 1)) * CGFloat(chartData[i])
//                        print(chartData[i])
//                        if i == 0 {
//                            path.move(to: CGPoint(x: xPosition, y: chartData[0] * (height / CGFloat(chartData.max() ?? 1))))
//                            print(chartData[0])
//                        }

//                        path.addLine(to: CGPoint(x: xPosition, y: height - yPosition))
//                    }
//                }
//                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
//            }
//        }
//    var path: Path {
//                   let points = self.chartdata
//                   return Path.lineChart(points: points, step: CGPoint(x: 30, y: 20))
//    var body: some View {
//
//           }
//        VStack {
//            // Line Chart
//            Spacer()
//            MultiLineChartView(data: [(chartdata, .init(start: .yellow, end: .green))], title: "", legend: "", style: ChartStyle.init(formSize: CGSize(width: 300, height: 20)), form: CGSize(width: 300, height: 20), rateValue: 22, dropShadow: false, valueSpecifier: "")
//
//        }
//    }
//}

//struct LineChartView_Previews: PreviewProvider {
//    static var previews: some View {
//        LineChartView()
//    }
//}
//struct Line: View {
//
//}
//extension Path {

//    static func lineChart(points:[Double], step:CGPoint) -> Path {
//        var path = Path()
//        if (points.count < 2){
//            return path
//        }
//        guard let offset = points.min() else { return path }
//        let p1 = CGPoint(x: 0, y: CGFloat(points[0]-offset)*step.y)
//        path.move(to: p1)
//        for pointIndex in 1..<points.count {
//            let p2 = CGPoint(x: step.x * CGFloat(pointIndex), y: step.y*CGFloat(points[pointIndex]-offset))
//            path.addLine(to: p2)
//        }
//        return path
//    }
//}
