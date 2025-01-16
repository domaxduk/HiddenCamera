//
//  CameraResultGalleryCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 2/1/25.
//

import UIKit
import RxSwift

final class CameraResultGalleryCoordinator: NavigationBasedCoordinator {
    
    var previewCoordinator: CameraResultCoordinator?
    let type: CameraType
    
    init(type: CameraType, navigationController: UINavigationController) {
        self.type = type
        super.init(navigationController: navigationController)
    }
    
    lazy var controller: CameraResultGalleryViewController = {
        let viewModel = CameraResultGalleryViewModel(type: type)
        let controller = CameraResultGalleryViewController(viewModel: viewModel, coordinator: self)
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
            navigationController.viewControllers.removeAll(where: { $0 is CameraResultGalleryViewController })
        }
        
        super.stop(completion: completion)
    }
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is CameraResultCoordinator {
            self.previewCoordinator = nil 
        }
    }
    
    func routeToPreview(item: CameraResultItem) {
        self.previewCoordinator = CameraResultCoordinator(scanOption: nil, item: item, navigationController: navigationController)
        self.previewCoordinator?.start()
        self.addChild(self.previewCoordinator!)
    }
}
