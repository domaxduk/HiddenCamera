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
    @Published var currentTab: HomeTab = .scan
    @Published var historyItems = [ScanOptionItem]()
    @Published var scanOptions = [ToolItem]()
    @Published var isShowingScanOption: Bool = false
    
    override func config() {
        super.config()
        getListHistory()
        NotificationCenter.default.addObserver(self, selector: #selector(getListHistory), name: .updateListHistory, object: nil)
    }
    
    override func configInput() {
        super.configInput()
        
        input.didSelectTool.subscribe(onNext: { [unowned self] tool in
            AdsInterstitial.shared.tryToPresent { [weak self] in
                guard let self else { return }
                switch tool {
                case .infraredCamera:
                    self.routing.routeToInfraredCamera.onNext(())
                case .cameraDetector:
                    self.routing.routeToCameraDetector.onNext(())
                case .wifiScanner:
                    self.routing.routeToWifiScanner.onNext(())
                case .bluetoothScanner:
                    self.routing.routeToBluetoothScanner.onNext(())
                case .magnetic:
                    self.routing.routeToMagnetic.onNext(())
                }
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapQuickScan.subscribe(onNext: { [weak self] _ in 
            self?.startScan(item: ScanOptionItem())
        }).disposed(by: self.disposeBag)
        
        input.didTapStartScanOption.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            let item = ScanOptionItem(tools: self.scanOptions, type: .option)
            self.startScan(item: item)
        }).disposed(by: self.disposeBag)
        
        input.didTapScanFull.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            let item = ScanOptionItem(tools: ToolItem.allCases, type: .full)
            self.startScan(item: item)
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
                WebViewController.open(urlString: AppConfig.term, title: "Contact us")
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
