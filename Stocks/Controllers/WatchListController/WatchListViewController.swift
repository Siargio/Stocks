//
//  WatchListViewController.swift
//  Stocks
//
//  Created by Sergio on 26.04.23.
//

import UIKit
import FloatingPanel

class WatchListViewController: UIViewController {

    private var searchTimer: Timer?
    private var panel: FloatingPanelController?

    private var watchlistMap: [String: [CandleStick]] = [:]
    private var viewModels: [WatchListTableViewCell.ViewModel] = []

    private var observer: NSObjectProtocol?

    static var maxChangeWidth: CGFloat = 0 {
        didSet {

        }
    }

    //MARK: - UIElements

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(WatchListTableViewCell.self, forCellReuseIdentifier: WatchListTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchController()
        setUpTableView()
        fetchWatchlistData()
        setUpFloatingPanel()
        setUpTitleView()
        setUoObserver()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    //MARK: - Setups

    private func setUoObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: .didAddToWatchList,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.viewModels.removeAll()
            self?.fetchWatchlistData()
        }
    }

    private func fetchWatchlistData() {
        let symbols = PersistenceManager.shared.watchlist

        let group = DispatchGroup()

        for symbol in symbols where watchlistMap[symbol] == nil {
            group.enter()

            APICaller.shared.markData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }

                switch result {
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchlistMap[symbol] = candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }

    private func createViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()

        for (symbol, candleStick) in watchlistMap {
            let changePercentage = getChangePercentage(symbol: symbol,
                                                       data: candleStick)
            viewModels.append(
                .init(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                    price: getLatestClosingPrice(from: candleStick),
                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                    changePercentage: .percentage(from: changePercentage),
                    chartViewModel: .init(
                        data: candleStick.reversed().map { $0.close },
                        showLegend: false,
                        showAxis: false)))
        }
        self.viewModels = viewModels
    }

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

    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }

        return String.formatted(number: closingPrice)
    }

    private func  setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setUpFloatingPanel() {
        let vc = NewsViewController(type: .topStories)
        let panel = FloatingPanelController(delegate: self)
        panel.surfaceView.backgroundColor = .systemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.track(scrollView: vc.tableView)
    }

    private func setUpTitleView() {
        let titleView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: navigationController?.navigationBar.height ?? 100))
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width-20, height: titleView.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 40, weight: .medium)
        titleView.addSubview(label)

        navigationItem.titleView = titleView
    }

    private func setUpSearchController() {
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }
}

extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // убирает пробелы и проверяет что не пуста
        guard let query = searchController.searchBar.text,
              let resultsVc = searchController.searchResultsController as? SearchResultsViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        //Reset timer
        searchTimer?.invalidate()

        //Kick off new timer
        // Optimize to reduce number of search for when user stops typing
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            // Call API to search
            APICaller.shared.search(query: query) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        resultsVc.update(with: response.result)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        resultsVc.update(with: [])
                    }
                    print(error)
                }
            }
        })
    }
}

//MARK: - SearchResultViewControllerDelegate

extension WatchListViewController: SearchResultViewControllerDelegate {
    func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()

        let vc = StockDetailsViewController(
            symbol: searchResult.displaySymbol,
            companyName: searchResult.description
        )
        let navVc = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVc, animated: true)
    }
}

//MARK: - FloatingPanelControllerDelegate

extension WatchListViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full // скрывает титл при скроле в верх
    }
}

//MARK: - UITableViewDelegate

extension WatchListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifier, for: indexPath) as? WatchListTableViewCell else {
            fatalError()
        }
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        WatchListTableViewCell.preferredHeight
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            // update ViewModels
            viewModels.remove(at: indexPath.row)

            // update persistence
            PersistenceManager.shared.removeFromWatchList(symbol: viewModels[indexPath.row].symbol)

            //Delete Row
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // open details for selection
        let viewModel = viewModels[indexPath.row]

        let vs = StockDetailsViewController(
            symbol: viewModel.symbol,
            companyName: viewModel.companyName,
            candleStickData: watchlistMap[viewModel.symbol] ?? []
        )
        let navVC = UINavigationController(rootViewController: vs)
        present(navVC, animated: true)
    }
}

//MARK: - WatchListTableViewCellDelegate

extension WatchListViewController: WatchListTableViewCellDelegate {
    func didUpdateMaxWidth() {
        // optimize: Only refresh rows prior to the current row changes the max width
        tableView.reloadData()
    }
}
