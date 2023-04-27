//
//  WatchListViewController.swift
//  Stocks
//
//  Created by Sergio on 26.04.23.
//

import UIKit

class WatchListViewController: UIViewController {

    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchController()
        setUpTitleView()
    }

    //MARK: - Setups

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
        // Optimize to reduce number of search for when user stops typing

        // Call API to search

        // Update result controller
        resultsVc.update(with: ["GOOGLE"])
    }
}

//MARK: - SearchResultViewControllerDelegate

extension WatchListViewController: SearchResultViewControllerDelegate {
    func searchResultsViewControllerDidSelect(searchResult: String) {
        // Present stock details for selection
    }
}
