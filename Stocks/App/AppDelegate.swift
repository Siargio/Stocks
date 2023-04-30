//
//  AppDelegate.swift
//  Stocks
//
//  Created by Sergio on 26.04.23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        debug()

        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = WatchListViewController()
        let navigationCon = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationCon
        window?.makeKeyAndVisible()

        return true
    }

    private func debug() {
        APICaller.shared.markData(for: "AAPL", numberOfDays: 1) { result in
            switch result {
            case .success(let data):
                let candleStick = data.candleSticks
            case .failure(let error):
                print(error)
            }
        }
//        APICaller.shared.news(for: .compan(symbol: "MSFT")) { result in
//            switch result {
//            case .success(let news):
//                print(news.count)
//            case .failure: break
//            }
//        }
    }
}
