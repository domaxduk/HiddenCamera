//
//  HomeCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import UIKit
import RxSwift
import SwiftUI

struct RouteToNextTool: CoordinatorEvent {  }

final class HomeCoordinator: WindowBasedCoordinator {
    private var navigationController: UINavigationController!

    private var historyCoordinator: HistoryCoordinator?
    private var historyDetailCoordinator: HistoryDetailCoordinator?

    private var infraredCameraCoordinator: InfraredCameraCoordinator?
    private var wifiScannerCoordinator: WifiScannerCoordinator?
    private var bluetoothScannerCoordinator: BluetoothScannerCoordinator?
    private var magneticCoordinator: MagnetometerCoordinator?
    
    private var scanOptionItem: ScanOptionItem?
    private var cctvCountryCoordinator: CCTVCountryCoordinator?
    private var userAdressDialog: UIHostingController<UserAddressDialog>?
    lazy var controller: HomeViewController = {
        let viewModel = HomeViewModel()
        let controller = HomeViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        
        navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.1, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }

    override func stop(completion: (() -> Void)? = nil) {
        super.stop(completion: completion)
    }
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if let child = child as? InfraredCameraCoordinator, child.canRemove() {
            print("remove screen: infraredCameraCoordinator")
            self.infraredCameraCoordinator = nil
            scanOptionItem?.decrease()
        }
        
        if let child = child as? WifiScannerCoordinator, child.canRemove() {
            print("remove screen: wifiScannerCoordinator")
            self.wifiScannerCoordinator = nil
            LocalNetworkDetector.shared.stopScan()
            scanOptionItem?.decrease()
        }
        
        if let child = child as? BluetoothScannerCoordinator, child.canRemove() {
            print("remove screen: bluetoothScannerCoordinator")
            self.bluetoothScannerCoordinator = nil
            BluetoothScanner.shared.stopScanning()
            scanOptionItem?.decrease()
        }
        
        if let child = child as? MagnetometerCoordinator, child.canRemove() {
            print("remove screen: magneticCoordinator")
            self.magneticCoordinator = nil
            scanOptionItem?.decrease()
        }
        
        if child is HistoryDetailCoordinator {
            print("remove screen: historyDetailCoordinator")
            self.historyDetailCoordinator = nil
        }
        
        if child is CCTVCountryCoordinator {
            self.cctvCountryCoordinator = nil
        }
        
        if child is HistoryCoordinator {
            self.historyCoordinator = nil
        }
    }
    
    override func handle(event: any CoordinatorEvent) -> Bool {
        if event is RouteToNextTool {
            if let item = scanOptionItem {
                if let tool = item.nextTool, !item.isEnd {
                    AdsInterstitial.shared.tryToPresent { [weak self] in
                        self?.routeToTool(tool: tool, option: item)
                    }
                } else {
                    routeToHistoryDetail(item: item)
                }
            }
            
            return true
        }
        
        if let event = event as? HistoryDetailRouteToToolEvent {
            switch event.tool {
            case .bluetoothScanner:
                self.routeToBluetoothScanner(scanOption: event.scanOption)
            case .wifiScanner:
                self.routeToWifiScanner(scanOption: event.scanOption)
            case .magnetic:
                self.routeToMagnetic(scanOption: event.scanOption)
            case .infraredCamera:
                self.routeToInfraredCamera(scanOption: event.scanOption)
            }
            return true
        }
        
        if event is HistoryDetailWantToBack {
            if scanOptionItem != nil {
                self.scanOptionItem = nil
            }
            
            self.navigationController.popToRootViewController(animated: true)
            self.stopAllChild()
            return true
        }
        
        return super.handle(event: event)
    }
}

// MARK: - Route
extension HomeCoordinator {
    func routeToCCTVCountry(country: CCTVCountry) {
        self.cctvCountryCoordinator = CCTVCountryCoordinator(country: country, navigationController: navigationController)
        self.cctvCountryCoordinator?.start()
        self.addChild(cctvCountryCoordinator)
    }
    
    func startScanOption(item: ScanOptionItem) {
        let viewModel = UserAddressViewModel()
        viewModel.didChooseAddress.subscribe(onNext: { [weak self] address in
            guard let self else { return }
            self.userAdressDialog?.dismiss(animated: true)
            self.userAdressDialog = nil
            item.address = address
            
            self.scanOptionItem = item
            
            if let tool = item.nextTool {
                self.routeToTool(tool: tool, option: item)
            }
        }).disposed(by: viewModel.disposeBag)
        
        self.userAdressDialog = UIHostingController(rootView: UserAddressDialog(viewModel: viewModel))
        self.userAdressDialog?.view.backgroundColor = .clear
        self.userAdressDialog?.modalTransitionStyle = .crossDissolve
        self.userAdressDialog?.modalPresentationStyle = .overFullScreen
        controller.present(userAdressDialog!, animated: true)
    }
    
    private func routeToTool(tool: ToolItem, option: ScanOptionItem) {
        switch tool {
        case .bluetoothScanner:
            routeToBluetoothScanner(scanOption: option)
        case .wifiScanner:
            routeToWifiScanner(scanOption: option)
        case .magnetic:
            routeToMagnetic(scanOption: option)
        case .infraredCamera:
            routeToInfraredCamera(scanOption: option)
        }
        
        option.increase()
    }
    
    private func routeToHistoryDetail(item: ScanOptionItem) {
        if self.historyDetailCoordinator == nil {
            self.historyDetailCoordinator = HistoryDetailCoordinator(scanOption: item, navigationController: self.navigationController)
            self.addChild(self.historyDetailCoordinator!)
        }
        
        self.historyDetailCoordinator?.start()
    }
    
    func routeToInfraredCamera(scanOption: ScanOptionItem? = nil) {
        if self.infraredCameraCoordinator == nil {
            Permission.requestCamera { [weak self] granted in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.infraredCameraCoordinator = InfraredCameraCoordinator(scanOption: scanOption, navigationController: self.navigationController)
                    self.infraredCameraCoordinator?.start()
                    self.addChild(self.infraredCameraCoordinator!)
                }
            }
        } else {
            self.infraredCameraCoordinator?.start()
        }
    }
    
    func routeToWifiScanner(scanOption: ScanOptionItem? = nil) {
        if self.wifiScannerCoordinator == nil {
            LocationManager.shared.statusObserver.take(1).subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                if self.wifiScannerCoordinator == nil {
                    DispatchQueue.main.async {
                        self.wifiScannerCoordinator = WifiScannerCoordinator(scanOption: scanOption, navigationController: self.navigationController)
                        self.wifiScannerCoordinator?.start()
                        self.addChild(self.wifiScannerCoordinator!)
                    }
                }
            }).disposed(by: controller.disposeBag)
            
            LocationManager.shared.requestPermission()
        } else {
            self.wifiScannerCoordinator?.start()
        }
    }
    
    func routeToBluetoothScanner(scanOption: ScanOptionItem? = nil) {
        if self.bluetoothScannerCoordinator == nil {
            self.bluetoothScannerCoordinator = BluetoothScannerCoordinator(scanOption: scanOption, navigationController: navigationController)
            self.addChild(bluetoothScannerCoordinator!)
        }
        
        self.bluetoothScannerCoordinator?.start()
    }
    
    func routeToMagnetic(scanOption: ScanOptionItem? = nil) {
        if self.magneticCoordinator == nil {
            self.magneticCoordinator = MagnetometerCoordinator(scanOption: scanOption, navigationController: navigationController)
            self.addChild(magneticCoordinator!)
        }
        
        self.magneticCoordinator?.start()
    }
    
    func routeToHistory() {
        self.historyCoordinator = HistoryCoordinator(navigationController: navigationController)
        self.historyCoordinator?.start()
        self.addChild(historyCoordinator)
    }
}
