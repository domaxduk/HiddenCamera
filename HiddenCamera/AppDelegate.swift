//
//  AppDelegate.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import SwiftyStoreKit
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var appCoordinator: AppCoordinator!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configFirebase()
        configGoogleAds()
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
    
    // MARK: - Firebase
    private func configFirebase() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }
    
    // MARK: - Google Ads
    private func configGoogleAds() {
        GADMobileAds.sharedInstance().start()
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [""]
        
        AdsAppOpen.shared.start()
        AdsInterstitial.shared.start()
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    
}

