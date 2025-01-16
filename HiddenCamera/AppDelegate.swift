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
import FBSDKCoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var appCoordinator: AppCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configFirebase()
        configGoogleAds()
        configPurchase()
        configFacebook(application: application, launchOptions: launchOptions)
        configNetworkManager()
        configAppCoordinator()
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
    
    // MARK: - Purchase
    private func configPurchase() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            print("App Delegate: completeTransactions")
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    
                case .failed, .purchasing, .deferred:
                    break
                default: break
                }
            }
        }
        
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
            return true
        }
        
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            UserSetting.isPremiumUser = results.restoredPurchases.count > 0
        }
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
    
    // MARK: - FACEBOOK SDK
    private func configFacebook(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        Settings.shared.isAdvertiserTrackingEnabled = true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    
}

