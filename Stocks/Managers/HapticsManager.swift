//
//  HapticsManager.swift
//  Stocks
//
//  Created by Sergio on 27.04.23.
//

import UIKit

/// Object to manage haptics
final class HapticsManager {
    /// Singletone
    static let shared = HapticsManager()

    /// Private constructor
    private init() {}

    //MARK: - Public

    /// Vibrate slightly for selection
    public func vibrateForSelection() {
        //Vibrate light for a selection tap interaction
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    /// Play haptic for given type interaction
    /// - Parameter type: Type to vibrate for
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
