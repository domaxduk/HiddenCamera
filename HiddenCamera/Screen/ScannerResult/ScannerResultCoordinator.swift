//
//  ScannerResultCoordinator.swift
//  HiddenCamera
//
//  Created by CucPhung on 5/1/25.
//

import UIKit

final class ScannerResultCoordinator: NavigationBasedCoordinator {
    
    var devices: [Device]
    
    init(devices: [Device], navigationController: UINavigationController) {
        self.devices = devices
        super.init(navigationController: navigationController)
    }
    
    lazy var controller: ScannerResultViewController = {
        let viewModel = ScannerResultViewModel(devices: devices)
        let controller = ScannerResultViewController(viewModel: viewModel, coordinator: self)
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
}
