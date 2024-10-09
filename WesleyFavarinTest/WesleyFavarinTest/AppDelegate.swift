//
//  AppDelegate.swift
//  WesleyFavarinTest
//
//  Created by Wesley Favarin on 02/10/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let navigationController = UINavigationController(rootViewController: HomeViewController())
        window?.rootViewController = navigationController
        
        window?.makeKeyAndVisible()
        return true
    }
}
