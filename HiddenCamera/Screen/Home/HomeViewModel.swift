//
//  HomeViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import UIKit
import RxSwift
import CoreLocation
import SwiftUI
import GoogleMobileAds
import FirebaseAnalytics
import SwiftyStoreKit
import AVFoundation

struct HomeViewModelInput: InputOutputViewModel {
    var didTapPremiumButton = PublishSubject<()>()
    // Tool
    var selectSettingItem = PublishSubject<SettingItem>()
    
    // Scan
    var didTapScanFull = PublishSubject<()>()
    var didTapQuickScan = PublishSubject<()>()
    var didTapHistory = PublishSubject<()>()
    
    var didSelectToolOption = PublishSubject<ToolItem>()
    var removeAllScanOption = PublishSubject<()>()
    
    // Tab
    var selectTab = PublishSubject<HomeTab>()
    
    // CCTV
    var selectCCTVCountry = PublishSubject<CCTVCountry>()
    
    // Reel
    var selectReel = PublishSubject<Reel?>()
    var swipeReel = PublishSubject<Reel>()
}

struct HomeViewModelOutput: InputOutputViewModel {

}

struct HomeViewModelRouting: RoutingOutput {
    var routeToScanOption = PublishSubject<ScanOptionItem>()
    var routeToCCTVCountry = PublishSubject<CCTVCountry>()
    
    var routeToHistory = PublishSubject<()>()
    
    var shareApp = PublishSubject<()>()
    var presentAlert = PublishSubject<String>()
}

final class HomeViewModel: BaseViewModel<HomeViewModelInput, HomeViewModelOutput, HomeViewModelRouting> {
    @AppStorage("isTheFirstSwipe") var isTheFirstSwipe: Bool = true
    @Published var didAppear: Bool = false
    @Published var currentTab: HomeTab {
        didSet {
            if !didLoadTab.contains(where: { $0 == currentTab }) {
                didLoadTab.append(currentTab)
            }
        }
    }
    
    @Published var didLoadTab = [HomeTab]()
    @Published var isShowingLoading: Bool = false
    @Published var countries = [CCTVCountry]()
    
    @Published var reels = [Reel]()
    @Published var downloadedReels = [Reel]()
    @Published var currentReel: Reel?
    private var reelSwipeCount: Int = 0
    
    var needToShowSub: Bool = false
    
    override init() {
        self.currentTab = .Scan
        super.init()
        self.didLoadTab.append(.Scan)
    }
    
    override func config() {
        super.config()
        getListCCTVCountries()
        getListReels()
    }
    
    override func configInput() {
        super.configInput()
        
        input.didTapQuickScan.subscribe(onNext: { [weak self] _ in
            Analytics.logEvent("feature_scan_quick", parameters: nil)
            if UserSetting.canUsingFeature(.quickScan) {
                self?.startScan(item: ScanOptionItem())
                UserSetting.increaseUsedFeature(.quickScan)
            } else {
                SubscriptionViewController.open { }
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapScanFull.subscribe(onNext: { [weak self] _ in
            Analytics.logEvent("feature_scan_full", parameters: nil)
            guard let self else { return }
            if UserSetting.canUsingFeature(.scanFull) {
                let item = ScanOptionItem(tools: ToolItem.allCases, type: .full)
                self.startScan(item: item)
                UserSetting.increaseUsedFeature(.scanFull)
            } else {
                SubscriptionViewController.open { }
            }
        }).disposed(by: self.disposeBag)
        
        input.selectSettingItem.subscribe(onNext: { [weak self] item in
            guard let self else { return }
            switch item {
            case .share:
                self.routing.shareApp.onNext(())
            case .policy:
                WebViewController.open(urlString: AppConfig.policy, title: "Privacy Policy")
            case .term:
                WebViewController.open(urlString: AppConfig.term, title: "Terms of Conditions")
            case .contact:
                WebViewController.open(urlString: AppConfig.contact, title: "Contact us")
            case .rate:
                RateManager.rate()
            case .restore:
                self.isShowingLoading = true
                
                SwiftyStoreKit.restorePurchases { [weak self] result in
                    guard let self else { return }
                    self.isShowingLoading = false
                    UserSetting.isPremiumUser = result.restoredPurchases.count > 0
                    
                    if result.restoredPurchases.count > 0 {
                        self.routing.presentAlert.onNext("Restore successed!")
                    } else {
                        self.routing.presentAlert.onNext("Nothing to restore!")
                    }
                }
            }
        }).disposed(by: self.disposeBag)
        
        input.selectTab.subscribe(onNext: { [unowned self] tab in
            if tab != .Scan  {
                AdsInterstitial.shared.tryToPresent { [weak self] in
                    self?.currentTab = tab
                }
            } else {
                self.currentTab = tab
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapPremiumButton.subscribe(onNext: { _ in 
            SubscriptionViewController.open { }
        }).disposed(by: self.disposeBag)
        
        input.didTapHistory.subscribe(onNext: { [weak self] in
            guard let self else { return }
            AdsInterstitial.shared.tryToPresent { [weak self] in
                self?.routing.routeToHistory.onNext(())
            }
        }).disposed(by: self.disposeBag)
        
        configCCTVAction()
        configReelAction()
    }
    
    private func startScan(item: ScanOptionItem) {
        AdsInterstitial.shared.tryToPresent { [weak self] in
            guard let self else { return }
            LocationManager.shared.statusObserver.take(1).subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.routing.routeToScanOption.onNext(item)
            }).disposed(by: self.disposeBag)
            
            LocationManager.shared.requestPermission()
        }
    }
}

// MARK: - CCTV
extension HomeViewModel {
    private func configCCTVAction() {
        input.selectCCTVCountry.subscribe(onNext: { [weak self] country in
            AdsInterstitial.shared.tryToPresent { [weak self] in
                self?.routing.routeToCCTVCountry.onNext(country)
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func getListCCTVCountries() {
        Task {
            if let objects = try? await DecodeHelper.decode(urlString: AppConfig.cctv, type: [CCTVCountry].self) {
                DispatchQueue.main.async {
                    self.countries = objects.sorted(by: { $0.priority < $1.priority })
                }
            }
        }
    }
}

// MARK: - Reel
extension HomeViewModel {
    private func configReelAction() {
        input.selectReel.subscribe(onNext: { [weak self] reel in
            guard let self else { return }
            if reel == nil {
                self.reelSwipeCount = 0
                withAnimation {
                    self.currentReel = reel
                }
            } else {
                AdsInterstitial.shared.tryToPresent { [weak self] in
                    withAnimation {
                        self?.currentReel = reel
                    }
                }
            }
        }).disposed(by: self.disposeBag)
        
        input.swipeReel.subscribe(onNext: { [weak self] reel in
            guard let self else { return }
            self.reelSwipeCount += 1
            
            if reelSwipeCount % 3 == 0 {
                AdsInterstitial.shared.tryToPresent { [weak self] in
                    withAnimation {
                        self?.currentReel = reel
                    }
                }
            } else {
                self.currentReel = reel
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func downloadReels(reels: [Reel]) async {
        DispatchQueue.main.async {
            self.reels = reels
        }

        let successfulDownloads = await withTaskGroup(of: Reel?.self) { taskGroup in
            var results: [Reel] = []  // Local variable to store results

            for reel in reels {
                taskGroup.addTask {
                    print("Downloading \(reel.path)")
                    if let _ = await ReelDownloader.download(reel) {
                        print("Download success \(reel.path)")
                        return reel
                    } else {
                        print("Download failed \(reel.path)")
                        return nil
                    }
                }
            }

            // Collect results safely without modifying a shared variable inside the task group
            for await result in taskGroup {
                if let reel = result {
                    results.append(reel)
                }
            }

            return results  // Return collected results
        }

        // Update UI safely on the main thread after all downloads complete
        await MainActor.run {
            self.downloadedReels.append(contentsOf: successfulDownloads)
        }
    }
    
    private func getListReels() {
        Task {
            if let objects = try? await DecodeHelper.decode(urlString: AppConfig.reels, type: [Reel].self) {
                await self.downloadReels(reels: objects)
            }
        }
    }
}

// MARK: - Get
extension HomeViewModel {
    func findPreviousReel(from reel: Reel) -> Reel {
        let currentIndex = reels.firstIndex(of: reel) ?? 0
        let index = (currentIndex - 1 + reels.count) % reels.count
        let newReel = reels[index]
        return newReel
    }
    
    func findNextReel(from reel: Reel) -> Reel {
        let currentIndex = reels.firstIndex(of: reel) ?? 0
        let index = (currentIndex + 1) % reels.count
        let newReel = reels[index]
        return newReel
    }
}

// MARK: - Extension
extension Reel {
    var duration: Double {
        let asset = AVAsset(url: localURL)
        return asset.duration.seconds
    }
}
