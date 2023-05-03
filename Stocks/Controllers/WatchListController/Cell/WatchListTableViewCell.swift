//
//  WatchListTableViewCell.swift
//  Stocks
//
//  Created by Sergio on 30.04.23.
//

import UIKit

/// Delegate to Notify of cell events
protocol WatchListTableViewCellDelegate: AnyObject {
    func didUpdateMaxWidth()
}

/// Table cell for watch list item
final class WatchListTableViewCell: UITableViewCell {
    /// Cell id
    static let identifier = "WatchListTableViewCell"
    /// Ideal height of cell
    static let preferredHeight: CGFloat = 60
    /// Delegate
    weak var delegate: WatchListTableViewCellDelegate?

    /// Watchlist table cell viewModel
    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String
        let changeColor: UIColor
        let changePercentage: String
        let chartViewModel: StockChartView.ViewModel
    }

    //MARK: - UIElements

    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .right
        return label
    }()

    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        return label
    }()

    private let miniChartView: StockChartView = {
        let chart = StockChartView()
        chart.isUserInteractionEnabled = false
        chart.clipsToBounds = true
        return chart
    }()

    //MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        addSubviews(symbolLabel, nameLabel, miniChartView, priceLabel, changeLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Setups

    override func layoutSubviews() {
        super.layoutSubviews()
        symbolLabel.sizeToFit()
        nameLabel.sizeToFit()
        priceLabel.sizeToFit()
        changeLabel.sizeToFit()

        let yStart: CGFloat = (contentView.height - symbolLabel.height - nameLabel.height)/2
        symbolLabel.frame = CGRect(
            x: separatorInset.left,
            y: yStart,
            width: symbolLabel.width,
            height: symbolLabel.height)

        nameLabel.frame = CGRect(
            x: separatorInset.left,
            y: symbolLabel.bottom,
            width: nameLabel.width,
            height: nameLabel.height)

        let currentWidth = max(
            max(priceLabel.width, changeLabel.width),
            WatchListViewController.maxChangeWidth
        )

        if currentWidth > WatchListViewController.maxChangeWidth {
            WatchListViewController.maxChangeWidth = currentWidth
            delegate?.didUpdateMaxWidth()
        }

        priceLabel.frame = CGRect(
            x: contentView.width - 10 - currentWidth,
            y: (contentView.height - priceLabel.height - changeLabel.height)/2,
            width: currentWidth,
            height: priceLabel.height)

        changeLabel.frame = CGRect(
            x: contentView.width - 10 - currentWidth,
            y: priceLabel.bottom,
            width: currentWidth,
            height: changeLabel.height)

        miniChartView.frame = CGRect(
            x: priceLabel.left - (contentView.width/3) - 5,
            y: 6,
            width: contentView.width/3,
            height: contentView.height-12)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        nameLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        miniChartView.reset()
    }

    /// Configure view
    /// - Parameter viewModel: View ViewModel
    public func configure(with videoModel: ViewModel) {
        symbolLabel.text = videoModel.symbol
        nameLabel.text = videoModel.companyName
        priceLabel.text = videoModel.price
        changeLabel.text = videoModel.changePercentage
        changeLabel.backgroundColor = videoModel.changeColor
        miniChartView.configure(with: videoModel.chartViewModel)
    }
}
