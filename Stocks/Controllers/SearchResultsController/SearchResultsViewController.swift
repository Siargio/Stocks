//
//  SearchResultsViewController.swift
//  Stocks
//
//  Created by Sergio on 27.04.23.
//

import UIKit

/// Delegate foe search result
protocol SearchResultViewControllerDelegate: AnyObject {
    /// Notify delegate of selection
    /// - Parameter searchResult: Result that was picked
    func searchResultsViewControllerDidSelect(searchResult: SearchResult)
}

/// VC to show search result
final class SearchResultsViewController: UIViewController {

    //MARK: - Properties

    /// delegate to get events
    weak var delegate: SearchResultViewControllerDelegate?

    /// Collection of results
    private var results: [SearchResult] = []

    //MARK: - UIElements

    private lazy var tableVIew: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpTable()
    }

    //MARK: - Setups

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableVIew.frame = view.bounds
    }

    private func setUpTable() {
        view.addSubview(tableVIew)
    }

    public func update(with results: [SearchResult]) {
        self.results = results
        tableVIew.isHidden = results.isEmpty
        tableVIew.reloadData()
    }
}

//MARK: - UITableViewDataSource

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath)
        let model = results[indexPath.row]

        cell.textLabel?.text = model.displaySymbol
        cell.detailTextLabel?.text = model.description

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = results[indexPath.row]
        delegate?.searchResultsViewControllerDidSelect(searchResult: model)
    }
}
