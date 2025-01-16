//
//  AdsMultiNativeLoader.swift
//  HiddenCamera
//
//  Created by Duc apple  on 16/1/25.
//

import Foundation
import GoogleMobileAds
import RxSwift

class AdsMultiNativeLoader: NSObject, ObservableObject {
    private var adLoader: GADAdLoader?
    private var timer: Timer?
    private var state: AdsNativeLoaderState = .ready
    private var currentID: String = ""
    var nativeAds = [GADNativeAd]()
    private var numberOfAds: Int
    var loadSuccess = PublishSubject<()>()
    
    init(numberOfAds: Int) {
        self.numberOfAds = numberOfAds
        super.init()
    }
    
    func load() {
        let needLoadNumber = numberOfAds - nativeAds.count
        timer?.invalidate()
        
        if UserSetting.isPremiumUser || state == .isWaitingReload || needLoadNumber <= 0 {
            return
        }
        
        print("[AdsNativeLoader] start requesting \(needLoadNumber)")
        
        let request = GADRequest()
        let multipleAdOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdOptions.numberOfAds = needLoadNumber
        
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
extension AdsMultiNativeLoader: GADAdLoaderDelegate, GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: any Error) {
        if state == .isWaitingReload || adLoader != self.adLoader || self.adLoader == nil {
            return
        }
        
        print("[AdsNativeLoader] didFailToReceiveAdWithError \(error.localizedDescription)")
        print("[AdsNativeLoader] waiting to reload")
        self.adLoader = nil
        self.state = .isWaitingReload
        setTimeToReload()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        print("[AdsNativeLoader] didReceive")
        self.nativeAds.append(nativeAd)
        
        if self.nativeAds.count == self.numberOfAds {
            self.loadSuccess.onNext(())
        }
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

