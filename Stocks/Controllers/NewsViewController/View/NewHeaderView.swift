//
//  NewHeaderView.swift
//  Stocks
//
//  Created by Sergio on 28.04.23.
//

import UIKit

/// Delegate to notify of header events
protocol NewHeaderViewDelegate: AnyObject {
    func newHeaderViewDidTappAddButton(_ headerView: NewHeaderView)
}

/// TableView header for news
final class NewHeaderView: UITableViewHeaderFooterView {
    /// Header identifier
    static let identifier = "NewHeaderView"
    // Ideal height of header
    static let preferredHeight: CGFloat = 70
    /// Delegate instance for events
    weak var delegate: NewHeaderViewDelegate?

    /// ViewModel for header view
    struct ViewModel {
        let title: String
        let shouldShowAddButton: Bool
    }

    //MARK: - UIElements

    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let button: UIButton = {
        let button = UIButton()
        button.setTitle("+ WatchList", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    //MARK: - Init

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubviews(label, button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Setups

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 14, y: 0, width: contentView.width-28, height: contentView.height)

        button.sizeToFit()
        button.frame = CGRect(
            x: contentView.width - button.width-16,
            y: (contentView.height - button.height)/2,
            width: button.width + 8,
            height: button.height)
    }

    override func prepareForReuse() { // для повторного использования
        super.prepareForReuse()
        label.text = nil
    }

    /// Handle button tap
    @objc func didTapButton() {
        delegate?.newHeaderViewDidTappAddButton(self)
    }

    /// Configure view
    /// - Parameter viewModel: View ViewModel
    public func configure(with viewModel: ViewModel) {
        label.text = viewModel.title
        button.isHidden = !viewModel.shouldShowAddButton
    }
}
