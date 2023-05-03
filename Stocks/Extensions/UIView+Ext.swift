//
//  UIView+Ext.swift
//  Stocks
//
//  Created by Sergio on 2.05.23.
//

import UIKit

//MARK: - Add subView

extension UIView {
    /// Adds multiple subviews
    /// - Parameter views: Collection of subview
    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}

//MARK: - Framing

extension UIView {

    var width: CGFloat {
        frame.size.width
    }

    var height: CGFloat {
        frame.size.height
    }

    var left: CGFloat {
        frame.origin.x
    }

    var right: CGFloat {
        left + width
    }

    var top: CGFloat {
        frame.origin.y
    }

    var bottom: CGFloat {
        top + height
    }
}
