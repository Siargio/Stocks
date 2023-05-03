//
//  StockChartView.swift
//  Stocks
//
//  Created by Sergio on 30.04.23.
//

import Charts
import UIKit

/// View to show a chart
final class StockChartView: UIView {

    /// Chart View ViewModel
    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
        let fillColor: UIColor
    }

    /// Chart View
    private let charView: LineChartView = {
        let chartView = LineChartView()
        chartView.pinchZoomEnabled = false
        chartView.setScaleEnabled(true)
        chartView.xAxis.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.legend.enabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        return chartView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(charView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        charView.frame = bounds
    }

    /// Reset the chart view
    func reset() {
        charView.data = nil
    }

    /// Configure View
    /// - Parameter viewModel: View ViewModel
    func configure(with viewModel: ViewModel) {
        var entries = [ChartDataEntry]()

        for (index, value) in viewModel.data.enumerated() {
            entries.append(
                .init(
                    x: Double(index),
                    y: value))
        }

        charView.rightAxis.enabled = viewModel.showAxis
        charView.legend.enabled = viewModel.showLegend
        
        let dataSet = LineChartDataSet(entries: entries, label: "7 Days")
        dataSet.fillColor = viewModel.fillColor
        dataSet.drawFilledEnabled = true
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false
        let data = LineChartData(dataSet: dataSet)
        charView.data = data
    }
}
