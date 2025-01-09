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
    var didSelectTool = PublishSubject<ToolItem>()
    var didTapQuickScan = PublishSubject<()>()
    var didSelectToolOption = PublishSubject<ToolItem>()
    var didTapStartScanOption = PublishSubject<()>()
    var didTapScanFull = PublishSubject<()>()
    var removeAllScanOption = PublishSubject<()>()
    var selectSettingItem = PublishSubject<SettingItem>()
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
    @Published var currentTab: HomeTab = .scan
    @Published var historyItems = [ScanOptionItem]()
    @Published var scanOptions = [ToolItem]()
    
    override func config() {
        super.config()
        getListHistory()
        NotificationCenter.default.addObserver(self, selector: #selector(getListHistory), name: .updateListHistory, object: nil)
    }
    
    override func configInput() {
        super.configInput()
        
        input.didSelectTool.subscribe(onNext: { [weak self] tool in
            switch tool {
            case .infraredCamera:
                self?.routeToInfraredCamera()
            case .cameraDetector:
                self?.routeToCameraDetector()
            case .wifiScanner:
                self?.routeToWifiScanner()
            case .bluetoothScanner:
                self?.routing.routeToBluetoothScanner.onNext(())
            case .magnetic:
                self?.routeToMetalDetector()
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapQuickScan.subscribe(onNext: { [weak self] _ in 
            self?.routing.routeToScanOption.onNext(.init())
        }).disposed(by: self.disposeBag)
        
        input.didTapStartScanOption.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            let item = ScanOptionItem(tools: self.scanOptions)
            self.routing.routeToScanOption.onNext(item)
        }).disposed(by: self.disposeBag)
        
        input.didTapScanFull.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            let item = ScanOptionItem(tools: ToolItem.allCases)
            self.routing.routeToScanOption.onNext(item)
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
            case .policy: break
               // WatchologyWebViewController.open(input: .init(url: WatchologyConst.policy, title: "Privacy Policy"))
            case .term: break
             //   WatchologyWebViewController.open(input: .init(url: WatchologyConst.term, title: "Terms of Conditions"))
            case .contact: break
             //   WatchologyWebViewController.open(input: .init(url: WatchologyConst.contact, title: "Contact us"))
            case .rate:
                RateManager.rate()
            case .restore:
                break
            }
        }).disposed(by: self.disposeBag)
    }
    
    @objc private func getListHistory() {
        let dao = ScanHistoryDAO()
        self.historyItems = dao.getAll()
    }
    
    private func routeToInfraredCamera() {
        self.routing.routeToInfraredCamera.onNext(())
    }
    
    private func routeToCameraDetector() {
        self.routing.routeToCameraDetector.onNext(())
    }
    
    private func routeToWifiScanner() {
        self.routing.routeToWifiScanner.onNext(())
    }
    
    private func routeToMetalDetector() {
        self.routing.routeToMagnetic.onNext(())
    }
    
    func isSelected(tool: ToolItem) -> Bool {
        return self.scanOptions.contains(where: { $0 == tool })
    }
}
