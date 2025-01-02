//
//  CameraResultCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 2/1/25.
//

import UIKit
import RxSwift

final class CameraResultCoordinator: NavigationBasedCoordinator {
    
    let item: CameraResultItem
    
    init(item: CameraResultItem, navigationController: UINavigationController) {
        self.item = item
        super.init(navigationController: navigationController)
    }
    
    lazy var controller: CameraResultViewController = {
        let viewModel = CameraResultViewModel(item: item)
        let controller = CameraResultViewController(viewModel: viewModel, coordinator: self)
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
