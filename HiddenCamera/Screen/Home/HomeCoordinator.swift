//
//  HomeCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import UIKit
import RxSwift

struct RouteToNextTool: CoordinatorEvent {  }

final class HomeCoordinator: WindowBasedCoordinator {
    private var navigationController: UINavigationController!

    private var infraredCameraCoordinator: InfraredCameraCoordinator?
    private var cameraDetectorCoordinator: CameraDetectorCoordinator?
    
    private var wifiScannerCoordinator: WifiScannerCoordinator?
    private var bluetoothScannerCoordinator: BluetoothScannerCoordinator?
    private var magneticCoordinator: MagnetometerCoordinator?
    
    private var historyDetailCoordinator: HistoryDetailCoordinator?
    private var scanOptionItem: ScanOptionItem?

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
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }

    override func stop(completion: (() -> Void)? = nil) {
        super.stop(completion: completion)
    }
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is InfraredCameraCoordinator {
            self.infraredCameraCoordinator = nil
        }
        
        if child is CameraDetectorCoordinator {
            self.cameraDetectorCoordinator = nil
        }
        
        if child is WifiScannerCoordinator {
            self.wifiScannerCoordinator = nil
        }
        
        if child is BluetoothScannerCoordinator {
            self.bluetoothScannerCoordinator = nil
        }
        
        if child is MagnetometerCoordinator {
            self.magneticCoordinator = nil
        }
        
        if child is HistoryDetailCoordinator {
            self.historyDetailCoordinator = nil
            self.stopAllChild()
        }
    }
    
    override func handle(event: any CoordinatorEvent) -> Bool {
        if event is RouteToNextTool {
            if let item = scanOptionItem {
                if let tool = item.nextTool {
                    self.routeToTool(tool: tool, option: item)
                } else {
                    routeToHistoryDetail(item: item)
                }
            }
            
            return true
        }
        
        if let event = event as? HistoryDetailRouteToToolEvent {
            switch event.tool {
            case .bluetoothScanner:
                self.bluetoothScannerCoordinator?.start()
            case .wifiScanner:
                break
            case .cameraDetector:
                break
            case .magnetic:
                break
            case .infraredCamera:
                break
            }
            return true
        }
        
        return super.handle(event: event)
    }
}

// MARK: - Route
extension HomeCoordinator {
    func startScanOption(item: ScanOptionItem) {
        self.scanOptionItem = item
        
        if let tool = item.nextTool {
            self.routeToTool(tool: tool, option: item)
        }
    }
    
    private func routeToTool(tool: ToolItem, option: ScanOptionItem) {
        switch tool {
        case .bluetoothScanner:
            routeToBluetoothScanner(scanOption: option)
        case .wifiScanner:
            routeToWifiScanner(scanOption: option)
        case .cameraDetector:
            routeToCameraDetector(scanOption: option)
        case .magnetic:
            routeToMagnetic(scanOption: option)
        case .infraredCamera:
            routeToInfraredCamera(scanOption: option)
        }
        
        option.increase()
    }
    
    private func routeToHistoryDetail(item: ScanOptionItem) {
        self.historyDetailCoordinator = HistoryDetailCoordinator(scanOption: item, navigationController: self.navigationController)
        self.historyDetailCoordinator?.start()
        self.addChild(self.historyDetailCoordinator!)
    }
    
    func routeToInfraredCamera(scanOption: ScanOptionItem? = nil) {
        Permission.requestCamera { [weak self] granted in
            guard let self else { return }
            DispatchQueue.main.async {
                self.infraredCameraCoordinator = InfraredCameraCoordinator(scanOption: scanOption, navigationController: self.navigationController)
                self.infraredCameraCoordinator?.start()
                self.addChild(self.infraredCameraCoordinator!)
            }
        }
    }
    
    func routeToCameraDetector(scanOption: ScanOptionItem? = nil) {
        Permission.requestCamera { [weak self] granted in
            guard let self else { return }
            DispatchQueue.main.async {
                self.cameraDetectorCoordinator = CameraDetectorCoordinator(scanOption: scanOption, navigationController: self.navigationController)
                self.cameraDetectorCoordinator?.start()
                self.addChild(self.cameraDetectorCoordinator!)
            }
        }
    }
    
    func routeToWifiScanner(scanOption: ScanOptionItem? = nil) {
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
    }
    
    func routeToBluetoothScanner(scanOption: ScanOptionItem? = nil) {
        if self.bluetoothScannerCoordinator != nil {
            return
        }
        
        self.bluetoothScannerCoordinator = BluetoothScannerCoordinator(scanOption: scanOption, navigationController: navigationController)
        self.bluetoothScannerCoordinator?.start()
        self.addChild(bluetoothScannerCoordinator!)
    }
    
    func routeToMagnetic(scanOption: ScanOptionItem? = nil) {
        if self.magneticCoordinator != nil {
            return
        }
        
        self.magneticCoordinator = MagnetometerCoordinator(scanOption: scanOption, navigationController: navigationController)
        self.magneticCoordinator?.start()
        self.addChild(magneticCoordinator!)
    }
}
