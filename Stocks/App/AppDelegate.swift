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

        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = WatchListViewController()
        let navigationCon = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationCon
        window?.makeKeyAndVisible()

        return true
    }
}
