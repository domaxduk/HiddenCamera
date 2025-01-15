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

struct HomeViewModelInput: InputOutputViewModel {
    // Tool
    var didSelectTool = PublishSubject<ToolItem>()
   
    var selectSettingItem = PublishSubject<SettingItem>()
    
    // Scan
    var didTapScanFull = PublishSubject<()>()
    var didTapQuickScan = PublishSubject<()>()
    var didTapStartScanOption = PublishSubject<()>()
    var didTapScanOption = PublishSubject<()>()
    var didSelectToolOption = PublishSubject<ToolItem>()
    var removeAllScanOption = PublishSubject<()>()
    
    // Tab
    var selectTab = PublishSubject<HomeTab>()
}

struct HomeViewModelOutput: InputOutputViewModel {

}

struct HomeViewModelRouting: RoutingOutput {
    var routeToInfraredCamera = PublishSubject<()>()
    var routeToCameraDetector = PublishSubject<()>()
    var routeToWifiScanner = PublishSubject<()>()
    var routeToBluetoothScanner = PublishSubject<()>()
    var routeToMagnetic = PublishSubject<()>()
    
    var routeToScanOption = PublishSubject<ScanOptionItem>()
    var routeToHistoryDetail = PublishSubject<ScanOptionItem>()
    
    var shareApp = PublishSubject<()>()
}

final class HomeViewModel: BaseViewModel<HomeViewModelInput, HomeViewModelOutput, HomeViewModelRouting> {
    @Published var didAppear: Bool = false
    @Published var currentTab: HomeTab {
        didSet {
            if !didLoadTab.contains(where: { $0 == currentTab }) {
                didLoadTab.append(currentTab)
            }
        }
    }
    
    @Published var didLoadTab = [HomeTab]()
    @Published var historyItems = [ScanOptionItem]()
    @Published var scanOptions = [ToolItem]()
    @Published var isShowingScanOption: Bool = false
    
    override init() {
        self.currentTab = .scan
        super.init()
        self.didLoadTab.append(.scan)
    }
    
    override func config() {
        super.config()
        getListHistory()
        NotificationCenter.default.addObserver(self, selector: #selector(getListHistory), name: .updateListHistory, object: nil)
    }
    
    override func configInput() {
        super.configInput()
        
        input.didSelectTool.subscribe(onNext: { [unowned self] tool in
            switch tool {
            case .infraredCamera:
                Analytics.logEvent("feature_tool_ir", parameters: nil)
                if UserSetting.canUsingFeature(.ifCamera) {
                    AdsInterstitial.shared.tryToPresent { [weak self] in
                        self?.routing.routeToInfraredCamera.onNext(())
                    }
                } else {
                    SubscriptionViewController.open { }
                }
            case .cameraDetector:
                Analytics.logEvent("feature_tool_ai", parameters: nil)
                if UserSetting.canUsingFeature(.aiDetector) {
                    AdsInterstitial.shared.tryToPresent { [weak self] in
                        self?.routing.routeToCameraDetector.onNext(())
                    }
                } else {
                    SubscriptionViewController.open { }
                }
            case .wifiScanner:
                Analytics.logEvent("feature_tool_wifi", parameters: nil)
                if UserSetting.canUsingFeature(.wifi) {
                    AdsInterstitial.shared.tryToPresent { [weak self] in
                        self?.routing.routeToWifiScanner.onNext(())
                    }
                } else {
                    SubscriptionViewController.open { }
                }
            case .bluetoothScanner:
                Analytics.logEvent("feature_tool_bluetooth", parameters: nil)
                if UserSetting.canUsingFeature(.bluetooth) {
                    AdsInterstitial.shared.tryToPresent { [weak self] in
                        self?.routing.routeToBluetoothScanner.onNext(())
                    }
                } else {
                    SubscriptionViewController.open { }
                }
            case .magnetic:
                Analytics.logEvent("feature_tool_magnetic", parameters: nil)
                if UserSetting.canUsingFeature(.magnetometer) {
                    AdsInterstitial.shared.tryToPresent { [weak self] in
                        self?.routing.routeToMagnetic.onNext(())
                    }
                } else {
                    SubscriptionViewController.open { }
                }
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapQuickScan.subscribe(onNext: { [weak self] _ in 
            Analytics.logEvent("feature_scan_quick", parameters: nil)
            if UserSetting.canUsingFeature(.quickScan) {
                self?.startScan(item: ScanOptionItem())
                UserSetting.increaseUsedFeature(.quickScan)
            } else {
                SubscriptionViewController.open { }
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapStartScanOption.subscribe(onNext: { [weak self] _ in
            Analytics.logEvent("feature_scan_option", parameters: nil)
            guard let self else { return }
            if UserSetting.canUsingFeature(.scanOption) {
                let item = ScanOptionItem(tools: self.scanOptions, type: .option)
                self.startScan(item: item)
                UserSetting.increaseUsedFeature(.scanOption)
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
        
        input.removeAllScanOption.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            withAnimation {
                self.scanOptions.removeAll()
            }
        }).disposed(by: self.disposeBag)
        
        input.didSelectToolOption.subscribe(onNext: { [weak self] tool in
            guard let self else { return }
            withAnimation {
                if let index = self.scanOptions.firstIndex(where: { $0 == tool }) {
                    self.scanOptions.remove(at: index)
                } else {
                    self.scanOptions.append(tool)
                }
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
                break
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapScanOption.subscribe(onNext: { [unowned self] in
            self.routeToScanOption()
        }).disposed(by: self.disposeBag)
        
        input.selectTab.subscribe(onNext: { [unowned self] tab in
            if tab == .setting {
                AdsInterstitial.shared.tryToPresent { [weak self] in
                    self?.currentTab = .setting
                }
            } else {
                self.currentTab = tab
            }
        }).disposed(by: self.disposeBag)
    }
    
    @objc private func getListHistory() {
        let dao = ScanHistoryDAO()
        self.historyItems = dao.getAll()
    }
    
    private func startScan(item: ScanOptionItem) {
        AdsInterstitial.shared.tryToPresent { [weak self] in
            self?.routing.routeToScanOption.onNext(item)
        }
    }
    
    private func routeToScanOption() {
        AdsInterstitial.shared.tryToPresent { [weak self] in
            withAnimation {
                self?.isShowingScanOption = true
            }
        }
    }
}

// MARK: - Get
extension HomeViewModel {
    func isSelected(tool: ToolItem) -> Bool {
        return self.scanOptions.contains(where: { $0 == tool })
    }
}
