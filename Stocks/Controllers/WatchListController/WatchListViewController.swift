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

    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchController()
        setUpFloatingPanel()
        setUpTitleView()
    }

    //MARK: - Setups

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
        // Present stock details for selection
        print("Did select: \(searchResult.displaySymbol)")
        navigationItem.searchController?.searchBar.resignFirstResponder()
        let vc = StockDetailsViewController()
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
