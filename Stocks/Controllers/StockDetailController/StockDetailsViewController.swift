//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by Sergio on 27.04.23.
//
import SafariServices
import UIKit

/// VC to show stock details
final class StockDetailsViewController: UIViewController {

    //MARK: - Properties

    /// Stock symbol
    private let symbol: String
    /// Company name
    private let companyName: String
    /// Company of data
    private var candleStickData: [CandleStick]

    /// Collection of news Stories
    private var stories: [NewStory] = []
    /// company metrics
    private var metric: Metrics?
    
    //MARK: - UIElements

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(NewHeaderView.self, forHeaderFooterViewReuseIdentifier: NewHeaderView.identifier)
        tableView.register(NewStoryTableViewCell.self, forCellReuseIdentifier: NewStoryTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    //MARK: - Init

    init(symbol: String, companyName: String, candleStickData: [CandleStick] = []) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleStickData = candleStickData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = companyName
        setUpCloseButton()
        setUpTable()
        fetchFinancialData()
        fetchNews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    //MARK: - Setups

    /// Sets up close Button
    private func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose))
    }

    /// Handle close button tap
    @objc private func didTapClose() {
        dismiss(animated: true)
    }

    private func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(
            frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.7) + 100))
    }

    /// Fetch financial metrics
    private func fetchFinancialData() {
        let group = DispatchGroup()

        if candleStickData.isEmpty {
            group.enter()
            APICaller.shared.markData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }

                switch result {
                case .success(let response):
                    self?.candleStickData = response.candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }

        group.enter()
        APICaller.shared.financialMetrics(for: symbol) { [weak self] result in
            defer {
                group.leave()
            }

            switch result {
            case .success(let response):
                let metrics = response.metric
                self?.metric = metrics
            case .failure(let error):
                print(error)
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
    }

    /// Fetch news for given type
    private func fetchNews() {
        APICaller.shared.news(for: .compan(symbol: symbol)) { result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self.stories = stories
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    /// Render chart and metrics
    private func renderChart() {
        // Chart VM | FinancialMetricVideoModel
        let headerView = StockDetailHeaderView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: (view.width * 0.7) + 100))

        var viewModels = [MetricCollectionViewCell.ViewModel]()
        if let metric = metric {
            viewModels.append(.init(name: "52W High", value: "\(metric.AnnualWeekHigh)"))
            viewModels.append(.init(name: "52L High", value: "\(metric.AnnualWeekLow)"))
            viewModels.append(.init(name: "52W Return", value: "\(metric.AnnualWeekPriceReturnDaily)"))
            viewModels.append(.init(name: "Beta", value: "\(metric.beta)"))
            viewModels.append(.init(name: "10D Vol.", value: "\(metric.TenDayAverageTradingVolume)"))
        }

        let change = getChangePercentage(symbol: symbol, data: candleStickData)
        headerView.configure(
            chartViewModle: .init(
                data: candleStickData.reversed().map { $0.close },
                showLegend: true,
                showAxis: true,
                fillColor: change < 0 ? .systemRed : .systemGreen),
            metricViewModels: viewModels)

        tableView.tableHeaderView = headerView
    }

    /// Get change percenetage
    /// - Parameters:
    /// - symbol: Symbol of company
    /// - data: Collection of data
    /// - Returns: Percent
    private func getChangePercentage(symbol: String, data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: {
                  !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
              })?.close else {
            return 0
        }

        let diff = 1 - (priorClose/latestClose)
        return diff
    }
}

//MARK: - StockDetailsViewController

extension StockDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewStoryTableViewCell.identifier, for: indexPath) as? NewStoryTableViewCell else {
            fatalError()
        }
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewHeaderView.identifier) as? NewHeaderView else {
            return nil
        }
        header.delegate = self
        header.configure(with: .init(
            title: symbol.uppercased(),
            shouldShowAddButton: !PersistenceManager.shared.watchListContains(symbol: symbol)))
        return header
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        NewStoryTableViewCell.preferredHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        NewHeaderView.preferredHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = URL(string: stories[indexPath.row].url) else { return }

        HapticsManager.shared.vibrateForSelection()

        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}

//MARK: - NewHeaderViewDelegate

extension StockDetailsViewController: NewHeaderViewDelegate {
    func newHeaderViewDidTappAddButton(_ headerView: NewHeaderView) {
        HapticsManager.shared.vibrate(for: .success)

        headerView.button.isHidden = true
        PersistenceManager.shared.addToWatchList(symbol: symbol, companyName: companyName)

        let alert = UIAlertController(
            title: "Added to Watchlist",
            message: "We've added \(companyName) to your watchlist.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
}
