//
//  PersistentManager.swift
//  Stocks
//
//  Created by Sergio on 27.04.23.
//

import Foundation

final class PersistenceManager {
    static let shared = PersistenceManager()

    private let userDefaults: UserDefaults = .standard

    private struct Constants {

    }
    private init() {}

    //MARK: - Public

    private var watchlist: [String] {
        return []
    }

    public func addToWatchList() {

    }

    public func removeFromWatchList() {

    }

    //MARK: - Private

    private var hasOnboarded: Bool {
        return false
    }
}
