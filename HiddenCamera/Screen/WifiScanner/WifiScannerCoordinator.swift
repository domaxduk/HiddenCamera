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
    
    lazy var controller: WifiScannerViewController = {
        let viewModel = WifiScannerViewModel()
        let controller = WifiScannerViewController(viewModel: viewModel, coordinator: self)
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
    
    func routeToResult(device: [Device]) {
        self.resultCoordinator = ScannerResultCoordinator(type: .wifi, devices: device, navigationController: navigationController)
        self.resultCoordinator?.start()
        self.addChild(resultCoordinator!)
    }
}
