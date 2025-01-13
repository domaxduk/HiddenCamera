//
//  AdsNativeLoader.swift
//  FontsKey4U
//
//  Created by Hangmai on 16/12/24.
//

import Foundation
import GoogleMobileAds
import RxSwift
import SwiftUI

enum AdsNativeLoaderState {
    case isWaitingReload
    case ready
}

class AdsNativeLoader: NSObject, ObservableObject {
    private var adLoader: GADAdLoader?
    private var timer: Timer?
    private var state: AdsNativeLoaderState = .ready
    private var currentID: String = ""

    @Published var nativeAd: GADNativeAd?
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(updatePremiumVersion), name: .updatePremiumVersion, object: nil)
    }
    
    @objc private func updatePremiumVersion() {
        if UserSetting.isPremiumUser {
            self.nativeAd = nil
        }
    }
    
    func load() {
        timer?.invalidate()
        if UserSetting.isPremiumUser || state == .isWaitingReload || nativeAd != nil {
            return
        }
        
        print("[AdsNativeLoader] start requesting")
        
        let request = GADRequest()
        let multipleAdOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdOptions.numberOfAds = 1
        
        switch currentID {
        case GoogleAdsKey.highNative:
            currentID = GoogleAdsKey.mediumNative
        case GoogleAdsKey.mediumNative:
            currentID = GoogleAdsKey.allNative
        case GoogleAdsKey.allNative: break
        default: currentID = GoogleAdsKey.highNative
        }
        
        adLoader = GADAdLoader(adUnitID: currentID,
                               rootViewController: nil,
                               adTypes: [.native],
                               options: [multipleAdOptions])
        
        adLoader?.delegate = self
        adLoader?.load(request)
    }
}

// MARK: - AdsNativeLoader
extension AdsNativeLoader: GADAdLoaderDelegate, GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: any Error) {
        if state == .isWaitingReload || adLoader != self.adLoader || self.adLoader == nil {
            return
        }
        
        print("[AdsNativeLoader] didFailToReceiveAdWithError \(error.localizedDescription)")
        print("[AdsNativeLoader] waiting to reload")
        self.state = .isWaitingReload
        setTimeToReload()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        print("[AdsNativeLoader] didReceive")
        self.nativeAd = nativeAd
    }
    
    private func setTimeToReload() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { [weak self] _ in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.state = .ready
                self.load()
            }
        })
    }
}
