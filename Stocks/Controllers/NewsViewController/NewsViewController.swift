//
//  NewsViewController.swift
//  Stocks
//
//  Created by Sergio on 27.04.23.
//

import UIKit

class NewsViewController: UIViewController {

    //MARK: - Property

    private let type: Type
    private var stories: [NewStory] = [
        NewStory(
            category: "tech",
            datetime: 123,
            headline: "Some headline should go here!",
            image: "",
            related: "Related",
            source: "CNBC",
            summary: "",
            url: "")
    ]

    enum `Type` {
        case topStories
        case compan(symbol: String)

        var title: String {
            switch self {
            case .topStories:
                return "Top Stories"
            case .compan(let symbol):
                return symbol.uppercased()
            }
        }
    }

    init(type: Type) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(NewStoryTableViewCell.self, forCellReuseIdentifier: NewStoryTableViewCell.identifier)
        tableView.register(NewHeaderView.self, forHeaderFooterViewReuseIdentifier: NewHeaderView.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpTable()
        fetchNews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    //MARK: - Setups

    private func setUpTable() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func fetchNews() {

    }

    private func openUrl(url: URL) {

    }
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        NewStoryTableViewCell.preferredHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        NewHeaderView.preferredHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewHeaderView.identifier) as? NewHeaderView else {
            return nil
        }
        header.configure(with: .init(title: self.type.title, shouldShowAddButton: false))
        return header
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //open new story
    }
}
