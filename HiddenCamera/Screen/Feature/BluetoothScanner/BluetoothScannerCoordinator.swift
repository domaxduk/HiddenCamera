//
//  BluetoothScannerCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 6/1/25.
//

import UIKit
import RxSwift

final class BluetoothScannerCoordinator: NavigationBasedCoordinator {
    
    private let scanOption: ScanOptionItem?
    var resultCoordinator: ScannerResultCoordinator?

    init(scanOption: ScanOptionItem?, navigationController: UINavigationController) {
        self.scanOption = scanOption
        super.init(navigationController: navigationController)
    }

    lazy var controller: BluetoothScannerViewController = {
        let viewModel = BluetoothScannerViewModel(scanOption: self.scanOption)
        let controller = BluetoothScannerViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        
        if controller.viewModel.devices.isEmpty {
            if navigationController.viewControllers.contains(where: { $0 is BluetoothScannerViewController }) {
                navigationController.viewControllers.removeAll(where: { $0 is BluetoothScannerViewController })
            }
            
            navigationController.pushViewController(controller, animated: true)
        } else {
            self.routeToResult(device: controller.viewModel.devices)
        }
    }

    override func stop(completion: (() -> Void)? = nil) {
        if navigationController.topViewController == controller {
            navigationController.popViewController(animated: true)
        } else {
            navigationController.viewControllers.removeAll(where: { $0 == controller })
        }
        
        scanOption?.decrease()
        super.stop(completion: completion)
    }
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is ScannerResultCoordinator {
            self.resultCoordinator = nil
        }
    }
    
    func routeToResult(device: [BluetoothDevice]) {
        self.resultCoordinator = ScannerResultCoordinator(scanOption: scanOption, type: .bluetooth, devices: device, navigationController: navigationController)
        self.resultCoordinator?.start()
        self.addChild(resultCoordinator!)
    }
    
    func nextTool() {
        self.send(event: RouteToNextTool())
    }
}
