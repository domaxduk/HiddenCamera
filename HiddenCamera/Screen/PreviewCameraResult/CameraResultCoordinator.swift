//
//  CameraResultCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 2/1/25.
//

import UIKit
import RxSwift

final class CameraResultCoordinator: NavigationBasedCoordinator {
    
    private let scanOption: ScanOptionItem?
    let item: CameraResultItem
    
    init(scanOption: ScanOptionItem?, item: CameraResultItem, navigationController: UINavigationController) {
        self.item = item
        self.scanOption = scanOption
        super.init(navigationController: navigationController)
    }
    
    lazy var controller: CameraResultViewController = {
        let viewModel = CameraResultViewModel(item: item, scanOption: scanOption)
        let controller = CameraResultViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        
        if scanOption != nil {
            controller.viewModel.tag = nil
        }
        
        if navigationController.viewControllers.contains(where: { $0 is CameraResultViewController }) {
            navigationController.viewControllers.removeAll(where: { $0 is CameraResultViewController })
        }
        
        navigationController.pushViewController(controller, animated: true)
    }

    override func stop(completion: (() -> Void)? = nil) {
        if navigationController.topViewController == controller {
            navigationController.popViewController(animated: true)
        } else {
            navigationController.viewControllers.removeAll(where: { $0 is CameraResultViewController })
        }
        
        super.stop(completion: completion)
    }
    
    func nextTool() {
        self.send(event: RouteToNextTool())
    }
}
