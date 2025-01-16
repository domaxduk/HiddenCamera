//
//  ScannerResultCoordinator.swift
//  HiddenCamera
//
//  Created by CucPhung on 5/1/25.
//

import UIKit

enum ScannerResultType {
    case wifi
    case bluetooth
}

final class ScannerResultCoordinator: NavigationBasedCoordinator {
    
    private let scanOption: ScanOptionItem?
    private let type: ScannerResultType
    private var devices: [Device]
    
    init(scanOption: ScanOptionItem?, type: ScannerResultType, devices: [Device], navigationController: UINavigationController) {
        self.devices = devices
        self.scanOption = scanOption
        self.type = type
        super.init(navigationController: navigationController)
    }
    
    lazy var controller: ScannerResultViewController = {
        let viewModel = ScannerResultViewModel(scanOption: scanOption, type: type, devices: devices)
        let controller = ScannerResultViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        
        if navigationController.viewControllers.contains(where: { $0 is ScannerResultViewController }) {
            navigationController.viewControllers.removeAll(where: { $0 is ScannerResultViewController })
        }
        
        navigationController.pushViewController(controller, animated: true)
    }

    override func stop(completion: (() -> Void)? = nil) {
        if navigationController.topViewController == controller {
            navigationController.popViewController(animated: true)
        } else {
            navigationController.viewControllers.removeAll(where: { $0 is ScannerResultViewController })
        }
        
        if scanOption == nil {
            switch type {
            case .wifi:
                LocalNetworkDetector.shared.stopScan()
            case .bluetooth:
                BluetoothScanner.shared.stopScanning()
            }
        }
        
        super.stop(completion: completion)
    }
    
    func nextTool() {
        self.send(event: RouteToNextTool())
    }
}
