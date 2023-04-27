//
//  SearchResultsViewController.swift
//  Stocks
//
//  Created by Sergio on 27.04.23.
//

import UIKit

protocol SearchResultViewControllerDelegate: AnyObject {
    func searchResultsViewControllerDidSelect(searchResult: SearchResult)
}

final class SearchResultsViewController: UIViewController {

    weak var delegate: SearchResultViewControllerDelegate?

    private var results: [SearchResult] = []

    private lazy var tableVIew: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpTable()
    }

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
