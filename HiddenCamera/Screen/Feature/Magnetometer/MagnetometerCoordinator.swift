//
//  MetalDetectorCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 7/1/25.
//

import UIKit
import RxSwift

final class MagnetometerCoordinator: NavigationBasedCoordinator {
    
    private let scanOption: ScanOptionItem?
    
    init(scanOption: ScanOptionItem?, navigationController: UINavigationController) {
        self.scanOption = scanOption
        super.init(navigationController: navigationController)
    }
    
    lazy var controller: MagnetometerViewController = {
        let viewModel = MagnetometerViewModel(hasButtonNext: self.scanOption != nil)
        let controller = MagnetometerViewController(viewModel: viewModel, coordinator: self)
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
    
    func nextTool() {
        
    }
}
