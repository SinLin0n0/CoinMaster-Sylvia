//
//  LineChartView.swift
//  LineChart
//
//  Created by Sin on 2023/6/28.
//

import SwiftUI

//struct LineChartContentView: View {
//    let chartData: [Double]
//
//    var body: some View {
//        GeometryReader { geometry in
//            let height = geometry.size.height
//            let width = geometry.size.width
//            let dataCount = chartData.count
//
//            Path { path in
//                for i in 0..<dataCount {
//                    let xPosition = width * CGFloat(i) / CGFloat(dataCount - 1)
//                    let yPosition = height * CGFloat(chartData[i]) / CGFloat(chartData.max() ?? 1)
//
//                    if i == 0 {
//                        path.move(to: CGPoint(x: xPosition, y: height))
//                    }
//
//                    path.addLine(to: CGPoint(x: xPosition, y: height - yPosition))
//                }
//            }
//            .stroke(Color.green ,style: StrokeStyle(lineWidth: 3, lineJoin: .round))
////                            .rotationEffect(.degrees(180), anchor: .center)
////                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
////                            .drawingGroup()
////            .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
//        }
//    }
//}

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
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    }

                    let previousData = chartData[max(0, i-1)]
                    let previousYPosition = height * CGFloat(previousData) / CGFloat(chartData.max() ?? 1)

                    let controlPoint = CGPoint(x: xPosition - (xPosition - width * CGFloat(min(dataCount - 1, i+1)) / CGFloat(dataCount - 1)) / 2, y: height - yPosition)

                    path.addQuadCurve(to: controlPoint, control: CGPoint(x: xPosition, y: height - yPosition))
                }
            }
            .stroke(Color.green, style: StrokeStyle(lineWidth: 2.3, lineJoin: .round))
        }
    }
}

