//
//  WifiScannerCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 3/1/25.
//

import UIKit
import RxSwift

final class WifiScannerCoordinator: NavigationBasedCoordinator {
    
    var resultCoordinator: ScannerResultCoordinator?
    let scanOption: ScanOptionItem?
    
    init(scanOption: ScanOptionItem?, navigationController: UINavigationController) {
        self.scanOption = scanOption
        super.init(navigationController: navigationController)
    }
    
    lazy var controller: WifiScannerViewController = {
        let viewModel = WifiScannerViewModel(scanOption: self.scanOption)
        let controller = WifiScannerViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        
        if controller.viewModel.devices.isEmpty {
            if navigationController.viewControllers.contains(where: { $0 is WifiScannerViewController }) {
                navigationController.viewControllers.removeAll(where: { $0 is WifiScannerViewController })
            }
            
            navigationController.pushViewController(controller, animated: true)
        } else {
            self.routeToResult(device: controller.viewModel.devices)
        }
    }
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is ScannerResultCoordinator {
            self.resultCoordinator = nil
        }
    }

    override func stop(completion: (() -> Void)? = nil) {
        if navigationController.topViewController == controller {
            navigationController.popViewController(animated: true)
        } else {
            navigationController.viewControllers.removeAll(where: { $0 is WifiScannerViewController })
        }
        
        if canRemove() {
            super.stop(completion: completion)
        } else {
            self.stopAllChild()
        }
    }
    
    func routeToResult(device: [Device]) {
        self.resultCoordinator = ScannerResultCoordinator(scanOption: scanOption, type: .wifi, devices: device, navigationController: navigationController)
        self.resultCoordinator?.start()
        self.addChild(resultCoordinator!)
    }
    
    func nextTool() {
        self.send(event: RouteToNextTool())
    }
    
    func canRemove() -> Bool {
        if let scanOption {
            return scanOption.isSave || scanOption.isCurrentTool(tool: .wifiScanner)
        }
        
        return true
    }
}
