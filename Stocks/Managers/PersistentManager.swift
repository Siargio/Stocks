//
//  PersistentManager.swift
//  Stocks
//
//  Created by Sergio on 27.04.23.
//

import Foundation

/// Object to manage saved caches
final class PersistenceManager {
    /// Singleton
    static let shared = PersistenceManager()

    /// Reference to user defaults
    private let userDefaults: UserDefaults = .standard

    /// Constants
    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchListKey = "watchlist"
    }

    /// Privatized constructor
    private init() {}

    //MARK: - Public

    /// get user watch list
    var watchlist: [String] {
        if !hasOnboarded {
            userDefaults.set(true, forKey: Constants.onboardedKey)
            setUpDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchListKey) ?? []
    }

    /// Check if watch list contains item
    /// - Parameter symbol: Symbol to check
    /// - Returns: Boolean
    public func watchListContains(symbol: String) -> Bool {
        return watchlist.contains(symbol)
    }

    /// Add a symbol to watch list
    /// - Parameter symbol: Symbol to add
    /// - CompanyName: Company name for symbol being added
    public func addToWatchList(symbol: String, companyName: String) {
        var current = watchlist
        current.append(symbol)
        userDefaults.set(current, forKey: Constants.watchListKey)
        userDefaults.set(companyName, forKey: symbol)

        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
    }

    /// Remove item from watchlist
    /// - Parameter symbol: Symbol to remove
    public func removeFromWatchList(symbol: String) {
        var newList = [String]()

        userDefaults.set(nil, forKey: symbol)
        for item in watchlist where item != symbol {
            newList.append(item)
        }

        userDefaults.set(newList, forKey: Constants.watchListKey)
    }

    //MARK: - Private

    /// Check if user has been onboarded
    private var hasOnboarded: Bool {
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }

    /// Set up default watch list items
    private func setUpDefaults() {
        let map: [String: String] = [
            "AAPL": "Apple Inc",
            "MSFT": "Microsoft Corporation",
            "SNAP": "Snap Inc.",
            "GOOG": "Alphabet",
            "AMZN": "Amazon.com, Inc.",
            "WORK": "Slack Technologies",
            "FB": "Facebook Inc.",
            "NVDA": "Nvidia Inc.",
            "NIKE": "Nike",
            "PINS": "Pinterest Inc."
        ]

        let symbols = map.keys.map { $0 }
        userDefaults.set(symbols, forKey: Constants.watchListKey)

        for (symbol, name) in map {
            userDefaults.set(name, forKey: symbol)
        }
    }
}
