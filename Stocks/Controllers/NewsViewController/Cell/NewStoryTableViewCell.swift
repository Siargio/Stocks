//
//  NewStoryTableViewCell.swift
//  Stocks
//
//  Created by Sergio on 28.04.23.
//

import SDWebImage
import UIKit

/// News Story tableView Cell
final class NewStoryTableViewCell: UITableViewCell {
    /// Cell id
    static let identifier = "NewStoryTableViewCell"
    /// Ideal height of cell
    static let preferredHeight: CGFloat = 140

    ///Cell viewModel
    struct ViewModel {
        let source: String
        let headline: String
        let dateString: String
        let imageURL: URL?

        //MARK: - Init

        init(model: NewStory) {
            self.source = model.source
            self.headline = model.headline
            self.dateString = .string(from: model.datetime)
            self.imageURL = URL(string: model.image)
        }
    }

    //MARK: - UILabel

    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()

    private let storyImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    //MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        backgroundColor = .secondarySystemBackground
        addSubviews(sourceLabel, headlineLabel, dateLabel, storyImage)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Setups

    override func layoutSubviews() {
        super.layoutSubviews()

        let imageSize: CGFloat = contentView.height / 1.4
        storyImage.frame = CGRect(
            x: contentView.width-imageSize-10,
            y: (contentView.height - imageSize) / 2,
            width: imageSize,
            height: imageSize)

        let avaiLableWidth: CGFloat = contentView.width - separatorInset.left - imageSize - 15
        dateLabel.frame = CGRect(
            x: separatorInset.left,
            y: contentView.height - 40,
            width: avaiLableWidth,
            height: 40)

        sourceLabel.sizeToFit()
        sourceLabel.frame = CGRect(
            x: separatorInset.left,
            y: 4,
            width: avaiLableWidth,
            height: sourceLabel.height)

        headlineLabel.frame = CGRect(
            x: separatorInset.left,
            y: sourceLabel.bottom + 5,
            width: avaiLableWidth,
            height: contentView.height - sourceLabel.bottom - dateLabel.height - 10)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLabel.text = nil
        headlineLabel.text = nil
        dateLabel.text = nil
        storyImage.image = nil
    }

    /// Configure view
    /// - Parameter viewModel: View ViewModel
    public func configure(with viewModel: ViewModel) {
        headlineLabel.text = viewModel.headline
        sourceLabel.text = viewModel.source
        dateLabel.text = viewModel.dateString
        storyImage.sd_setImage(with: viewModel.imageURL)
        //storyImage.setImage(with: viewModel.imageURL)
    }
}
