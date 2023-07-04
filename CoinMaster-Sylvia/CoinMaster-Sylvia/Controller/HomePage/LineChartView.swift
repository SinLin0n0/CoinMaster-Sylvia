//
//  LineChartView.swift
//  LineChart
//
//  Created by Sin on 2023/6/28.
//

import SwiftUI

struct LineChartContentView: View {
    let chartData: [Double]
    let lineColor: Color

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
            .stroke(lineColor, style: StrokeStyle(lineWidth: 2.3, lineJoin: .round))
        }
    }
}

