//
//  StockDetailHeaderView.swift
//  Stocks
//
//  Created by Sergio on 1.05.23.
//

import UIKit

class StockDetailHeaderView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var metricViewModels: [MetricCollectionViewCell.ViewModel] = []

    //MARK: - UIElements

    private let chartView = StockChartView()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collection.register(MetricCollectionViewCell.self, forCellWithReuseIdentifier: MetricCollectionViewCell.identifier)
        collection.backgroundColor = .secondarySystemBackground
        return collection
    }()

    //MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubviews(chartView, collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Setups

    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = CGRect(x: 0, y: 0, width: width, height: height-100)
        collectionView.frame = CGRect(x: 0, y: height-100, width: width, height: 100)
    }

    func configure(chartViewModle: StockChartView.ViewModel, metricViewModels: [MetricCollectionViewCell.ViewModel]) {
        chartView.configure(with: chartViewModle)
        self.metricViewModels = metricViewModels
        collectionView.reloadData()
    }

    //MARK: - CollectionView

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        metricViewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = metricViewModels[indexPath.row]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MetricCollectionViewCell.identifier, for: indexPath) as? MetricCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: viewModel)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: width/2, height: 100/3)
    }
}
