//
//  AdsAppOpen.swift
//  HiddenCamera
//
//  Created by Duc apple  on 10/1/25.
//

import Foundation
import GoogleMobileAds

enum AdsState {
    case none
    case ready
    case requesting
}

class AdsAppOpen: NSObject {
    static let shared = AdsAppOpen()
    private override init() { }
    
    private var openAd: GADAppOpenAd?
    private var status: AdsState = .none
    private var didEnterBackground: Bool = false
    
    func start() {
        Task {
            await request()
        }
        
        registerNotificationCenter()
    }
    
    private func registerNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(tryToPresent), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleChangeNetworkStatusNotification), name: .didChangeNetworkStatus, object: nil)
    }
    
    @objc private func handleChangeNetworkStatusNotification() {
        Task {
            await request()
        }
    }
    
    @objc private func appDidEnterBackground() {
        self.didEnterBackground = true
    }
    
    @objc private func tryToPresent() {
        if !didEnterBackground || status != .ready {
            return
        }
        
        openAd?.present(fromRootViewController: UIApplication.shared.navigationController?.topVC)
    }
    
    @objc private func request() async {
        if UserSetting.isPremiumUser || status != .none || !NetworkManager.shared.isConnectedNetwork() { return }
        
        status = .requesting
        do {
            openAd = try await GADAppOpenAd.load(withAdUnitID: GoogleAdsKey.appOpen, request: GADRequest())
            status = .ready
            openAd?.fullScreenContentDelegate = self
            print("[APP OPEN] load success")
        } catch {
            print("[APP OPEN] load with error: \(error.localizedDescription)")
            status = .none
            
            Task {
                try await Task.sleep(nanoseconds: 3_000_000_000)
                await request()
            }
        }
    }
}

// MARK: - GADFullScreenContentDelegate
extension AdsAppOpen: GADFullScreenContentDelegate {
    func ad(_ ad: any GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        print("[APP OPEN] present fail because: \(error.localizedDescription)")
        self.openAd = nil
        self.status = .none

        Task {
            await self.request()
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: any GADFullScreenPresentingAd) {
        print("[APP OPEN] did dismiss")
        self.openAd = nil
        self.status = .none
       
        Task {
            await self.request()
        }
    }
    
    func adWillPresentFullScreenContent(_ ad: any GADFullScreenPresentingAd) {
        print("[APP OPEN] will present ")
    }
}
