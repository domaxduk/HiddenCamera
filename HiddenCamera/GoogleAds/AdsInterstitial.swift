//
//  AdsInterstitial.swift
//  HiddenCamera
//
//  Created by Duc apple  on 10/1/25.
//

import Foundation
import GoogleMobileAds
import RxSwift

class AdsInterstitial: NSObject {
    static let shared = AdsInterstitial()
    private override init() { }
    
    private var interstitial: GADInterstitialAd?
    private var status: AdsState = .none
    private var didDismiss = PublishSubject<()>()
    private let disposeBag = DisposeBag()
    private var lastShowingDate: Date?
    
    func start() {
        Task {
            await request()
        }
        
        registerNotificationCenter()
    }
    
    private func registerNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleChangeNetworkStatusNotification), name: .didChangeNetworkStatus, object: nil)
    }
    
    @objc private func handleChangeNetworkStatusNotification() {
        Task {
            await request()
        }
    }
    
    func tryToPresent(completionHandler: @escaping (() -> Void)) {
        if let lastShowingDate, abs(lastShowingDate.timeIntervalSinceNow) < GoogleAdsKey.interCapping {
            completionHandler()
            return
        }
        
        if let interstitial, !UserSetting.isPremiumUser {
            didDismiss.take(1).subscribe(onNext: completionHandler).disposed(by: disposeBag)
            interstitial.present(fromRootViewController: rootViewController)
        } else {
            completionHandler()
        }
    }
    
    @objc private func request() async {
        if UserSetting.isPremiumUser || status != .none || !NetworkManager.shared.isConnectedNetwork() { return }
        
        status = .requesting
        Task {
            do {
                interstitial = try await GADInterstitialAd.load(withAdUnitID: GoogleAdsKey.inter, request: GADRequest())
                interstitial?.fullScreenContentDelegate = self
                status = .ready
            } catch {
                print("[Interstitial] load error: \(error.localizedDescription)")
                status = .none
            }
        }
    }
    
    var rootViewController: UIViewController? {
        return UIApplication.shared.navigationController?.topVC
    }
}

// MARK: - GADFullScreenContentDelegate
extension AdsInterstitial: GADFullScreenContentDelegate {
    func ad(_ ad: any GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        print("[Interstitial] present error: \(error.localizedDescription)")
        self.interstitial = nil
        self.status = .none
        self.didDismiss.onNext(())
        
        Task {
            await request()
        }
    }
    
    func adWillPresentFullScreenContent(_ ad: any GADFullScreenPresentingAd) {
        print("[Interstitial] adWillPresentFullScreenContent")
        self.lastShowingDate = Date()
    }
    
    func adWillDismissFullScreenContent(_ ad: any GADFullScreenPresentingAd) {
        print("[Interstitial] adWillDismissFullScreenContent")
        self.interstitial = nil
        self.status = .none
        
        Task {
            await request()
        }
    }
    
    func adDidDismissFullScreenContent(_ ad: any GADFullScreenPresentingAd) {
        print("[Interstitial] adDidDismissFullScreenContent")
        self.didDismiss.onNext(())
    }
}
