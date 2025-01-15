//
//  CameraDetectorCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 3/1/25.
//

import UIKit
import RxSwift

final class CameraDetectorCoordinator: NavigationBasedCoordinator {
    
    let scanOption: ScanOptionItem?
    var previewResult: CameraResultCoordinator?
    var galleryCoodinator: CameraResultGalleryCoordinator?
    
    init(scanOption: ScanOptionItem?, navigationController: UINavigationController) {
        self.scanOption = scanOption
        super.init(navigationController: navigationController)
    }
    
    lazy var controller: CameraDetectorViewController = {
        let viewModel = CameraDetectorViewModel(scanOption: scanOption)
        let controller = CameraDetectorViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        
        if let item = controller.viewModel.lastItem {
            self.routeToResult(item: item)
        } else {
            if navigationController.viewControllers.contains(where: { $0 is CameraDetectorViewController }) {
                navigationController.viewControllers.removeAll(where: { $0 is CameraDetectorViewController })
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
        
        if canRemove() {
            super.stop(completion: completion)
        } else {
            self.stopAllChild()
        }
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
        self.galleryCoodinator = CameraResultGalleryCoordinator(type: .aiDetector, navigationController: navigationController)
        self.galleryCoodinator?.start()
        self.addChild(self.galleryCoodinator!)
    }
    
    func nextTool() {
        self.send(event: RouteToNextTool())
    }
    
    func canRemove() -> Bool {
        if let scanOption {
            return scanOption.isSave || scanOption.isCurrentTool(tool: .cameraDetector)
        }
        
        return true
    }
}
