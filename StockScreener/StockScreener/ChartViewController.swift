//
//  ChartViewController.swift
//  StockScreener
//
//  Created by Jonathan on 8/7/25.
//

import UIKit
import DGCharts

final class DateAxisFormatter: NSObject, AxisValueFormatter {
    private let labels: [String]
    init(labels: [String]) { self.labels = labels }
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let i = Int(round(value))
        guard i >= 0, i < labels.count else { return "" }
        return labels[i]
    }
}

final class ChartViewController: UIViewController {
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var timeframeControl: UISegmentedControl!   // 1D, 1W, 1M, 3M, 1Y

    private let chart = LineChartView()
    private var current: String?
    private var xLabels: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        chart.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(chart)
        NSLayoutConstraint.activate([
            chart.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            chart.topAnchor.constraint(equalTo: containerView.topAnchor),
            chart.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        configureChartAppearance()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let t = StockStore.shared.selectedTicker else {
            showPlaceholder("Pick a ticker from Search")
            return
        }

        if t != current {
            current = t
            DispatchQueue.main.async { [weak self] in
                self?.tickerLabel.text = t
            }
            fetchAndRender(ticker: t, timeframe: selectedTimeframe())
        }
    }

    @IBAction func timeframeChanged(_ sender: UISegmentedControl) {
        guard let t = current else { return }
        fetchAndRender(ticker: t, timeframe: selectedTimeframe())
    }

    // MARK: - Timeframe mapping
    private func selectedTimeframe() -> Timeframe {
        switch timeframeControl.selectedSegmentIndex {
        case 0: return .d1   // 1D (5m)
        case 1: return .w1   // 1W (15m)
        case 2: return .m1   // 1M (1h)
        case 3: return .m3   // 3M (D)
        default: return .y1  // 1Y (D)
        }
    }

    private func fetchAndRender(ticker: String, timeframe: Timeframe) {
        // Ensure UI updates happen on main
        DispatchQueue.main.async { [weak self] in
            self?.chart.data = nil
            self?.chart.noDataText = "Loading…"
        }

        API.candles(symbol: ticker, timeframe: timeframe) { [weak self] raw in
            guard let self = self else { return }

            var candles = raw
            if timeframe == .d1 { candles = self.mostRecentSessionOnly(raw) }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                if candles.isEmpty {
                    if timeframe == .d1 || timeframe == .w1 || timeframe == .m1 {
                        API.candles(symbol: ticker, timeframe: .m3) { [weak self] daily in
                            guard let self = self else { return }
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                if daily.isEmpty {
                                    self.plotDemo(reason: "No data for this range.")
                                } else {
                                    self.timeframeControl.selectedSegmentIndex = 3 // 3M
                                    self.renderLine(ticker: ticker, candles: daily, timeframe: .m3)
                                }
                            }
                        }
                    } else {
                        self.plotDemo(reason: "No data for this range.")
                    }
                    return
                }

                self.renderLine(ticker: ticker, candles: candles, timeframe: timeframe)
            }
        }
    }

    private func mostRecentSessionOnly(_ candles: [Candle]) -> [Candle] {
        guard let lastDate = candles.last?.date else { return candles }
        let cal = Calendar.current
        let key = cal.dateComponents([.year, .month, .day], from: lastDate)
        return candles.filter { cal.dateComponents([.year, .month, .day], from: $0.date) == key }
    }

    private func renderLine(ticker: String, candles: [Candle], timeframe: Timeframe) {
        let df = DateFormatter()
        df.dateFormat = (timeframe == .d1 || timeframe == .w1 || timeframe == .m1) ? "M/d HH:mm" : "M/d"
        self.xLabels = candles.map { df.string(from: $0.date) }


        let entries = candles.enumerated().map { i, c in
            ChartDataEntry(x: Double(i), y: c.close)
        }

        let set = LineChartDataSet(entries: entries, label: ticker)
        set.drawCirclesEnabled = false
        set.lineWidth = 2
        set.mode = .cubicBezier
        set.drawValuesEnabled = false

        chart.data = LineChartData(dataSet: set)
        chart.xAxis.valueFormatter = DateAxisFormatter(labels: self.xLabels)
        chart.animate(xAxisDuration: 0.25)
        chart.notifyDataSetChanged()
    }


    private func configureChartAppearance() {
        chart.rightAxis.enabled = false
        chart.legend.enabled = true
        chart.legend.form = .line

        chart.dragEnabled = true
        chart.setScaleEnabled(true)
        chart.pinchZoomEnabled = true
        chart.doubleTapToZoomEnabled = true

        let x = chart.xAxis
        x.labelPosition = .bottom
        x.granularityEnabled = true
        x.granularity = 1
        x.drawGridLinesEnabled = true
        x.labelRotationAngle = -30

        let y = chart.leftAxis
        y.labelCount = 6
        y.drawGridLinesEnabled = true

        chart.noDataText = "Pick a ticker from Search"
    }

    
    private func showPlaceholder(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.chart.data = nil
            self?.chart.noDataText = text
        }
    }

    private func plotDemo(reason: String) {
        let entries = (0..<60).map { i in
            ChartDataEntry(x: Double(i), y: sin(Double(i)/8.0) * 8 + 100)
        }
        let set = LineChartDataSet(entries: entries, label: "Demo")
        set.drawCirclesEnabled = false
        set.drawValuesEnabled = false
        set.lineWidth = 2
        chart.data = LineChartData(dataSet: set)
        chart.xAxis.valueFormatter = DateAxisFormatter(labels: entries.map { _ in "" })
        print("ChartVC:", reason)
    }
}
