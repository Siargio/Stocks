//
//  SearchResultsViewController.swift
//  Stocks
//
//  Created by Sergio on 27.04.23.
//

import UIKit

protocol SearchResultViewControllerDelegate: AnyObject {
    func searchResultsViewControllerDidSelect(searchResult: String)
}

final class SearchResultsViewController: UIViewController {

    weak var delegate: SearchResultViewControllerDelegate?

    private var results: [String] = []

    private lazy var tableVIew: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
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

    public func update(with results: [String]) {
        self.results = results
        tableVIew.reloadData()
    }
}

//MARK: - UITableViewDataSource

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath)
        cell.textLabel?.text = "AAPL"
        cell.detailTextLabel?.text = "Apple Inc."

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.searchResultsViewControllerDidSelect(searchResult: "AAPL")
    }
}
