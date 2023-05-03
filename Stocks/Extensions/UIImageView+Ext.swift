//
//  UIImageView+Ext.swift
//  Stocks
//
//  Created by Sergio on 2.05.23.
//

import UIKit

extension UIImageView {
    /// Sets image from remote url
    /// - Parameter url: URL to fetch from
    func setImage(with url: URL?) {
        guard let url = url else { return }

        DispatchQueue.global(qos: .userInteractive).async {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
}
