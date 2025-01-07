//
//  AppDelegate.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var appCoordinator: AppCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configAppCoordinator()
        configNetworkManager()
        return true
    }

    private func configAppCoordinator() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.overrideUserInterfaceStyle = .light
        
        self.window?.makeKeyAndVisible()
        self.appCoordinator = AppCoordinator(window: self.window!)
        self.appCoordinator.start()
        UIView.appearance().isExclusiveTouch = true
    }
    
    private func configNetworkManager() {
        NetworkManager.shared.config()
    }
}

