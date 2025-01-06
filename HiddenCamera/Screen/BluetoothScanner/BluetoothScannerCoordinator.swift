//
//  BluetoothScannerCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 6/1/25.
//

import UIKit
import RxSwift

final class BluetoothScannerCoordinator: NavigationBasedCoordinator {
    var resultCoordinator: ScannerResultCoordinator?

    lazy var controller: BluetoothScannerViewController = {
        let viewModel = BluetoothScannerViewModel()
        let controller = BluetoothScannerViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        navigationController.pushViewController(controller, animated: true)
    }

    override func stop(completion: (() -> Void)? = nil) {
        if navigationController.topViewController == controller {
            navigationController.popViewController(animated: true)
        } else {
            navigationController.viewControllers.removeAll(where: { $0 == controller })
        }
        
        super.stop(completion: completion)
    }
    
    func routeToResult(device: [BluetoothDevice]) {
        self.resultCoordinator = ScannerResultCoordinator(type: .bluetooth, devices: device, navigationController: navigationController)
        self.resultCoordinator?.start()
        self.addChild(resultCoordinator!)
    }
}
