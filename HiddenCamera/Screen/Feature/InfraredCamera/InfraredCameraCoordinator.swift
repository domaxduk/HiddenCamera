//
//  InfraredCameraCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import UIKit
import RxSwift

final class InfraredCameraCoordinator: NavigationBasedCoordinator {
    var previewResult: CameraResultCoordinator?
    var galleryCoodinator: CameraResultGalleryCoordinator?
    private let scanOption: ScanOptionItem?
    
    init(scanOption: ScanOptionItem?, navigationController: UINavigationController) {
        self.scanOption = scanOption
        super.init(navigationController: navigationController)
    }

    lazy var controller: InfraredCameraViewController = {
        let viewModel = InfraredCameraViewModel(scanOption: self.scanOption)
        let controller = InfraredCameraViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        if let item = controller.viewModel.lastItem {
            self.routeToResult(item: item)
        } else {
            if navigationController.viewControllers.contains(where: { $0 is InfraredCameraViewController }) {
                navigationController.viewControllers.removeAll(where: { $0 is InfraredCameraViewController })
            }
            
            navigationController.pushViewController(controller, animated: true)
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
        
        if child is CameraResultCoordinator {
            self.previewResult = nil
        }
        
        if child is CameraResultGalleryCoordinator {
            self.galleryCoodinator = nil
        }
    }
    
    func routeToResult(item: CameraResultItem) {
        if self.previewResult == nil {
            self.previewResult = CameraResultCoordinator(scanOption: scanOption, item: item, navigationController: navigationController)
            self.addChild(self.previewResult!)
        }
        
        self.previewResult?.start()
    }
    
    func routeToGallery() {
        self.galleryCoodinator = CameraResultGalleryCoordinator(type: .infrared, navigationController: navigationController)
        self.galleryCoodinator?.start()
        self.addChild(self.galleryCoodinator!)
    }
    
    func nextTool() {
        self.send(event: RouteToNextTool())
    }
}
