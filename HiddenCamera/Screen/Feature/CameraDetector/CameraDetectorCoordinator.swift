//
//  CameraDetectorCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 3/1/25.
//

import UIKit
import RxSwift

final class CameraDetectorCoordinator: NavigationBasedCoordinator {
    
    private let scanOption: ScanOptionItem?
    var previewResult: CameraResultCoordinator?
    var galleryCoodinator: CameraResultGalleryCoordinator?
    
    init(scanOption: ScanOptionItem?, navigationController: UINavigationController) {
        self.scanOption = scanOption
        super.init(navigationController: navigationController)
    }
    
    lazy var controller: CameraDetectorViewController = {
        let viewModel = CameraDetectorViewModel(hasButtonNext: true)
        let controller = CameraDetectorViewController(viewModel: viewModel, coordinator: self)
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
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is CameraResultCoordinator {
            self.previewResult = nil
        }
        
        if child is CameraResultGalleryCoordinator {
            self.galleryCoodinator = nil
        }
    }
    
    func routeToResult(url: URL) {
        let item = CameraResultItem(id: UUID().uuidString, fileName: url.lastPathComponent, type: .aiDetector)
        self.previewResult = CameraResultCoordinator(item: item, navigationController: navigationController)
        self.previewResult?.start()
        self.addChild(self.previewResult!)
    }
    
    func routeToGallery() {
        self.galleryCoodinator = CameraResultGalleryCoordinator(type: .aiDetector, navigationController: navigationController)
        self.galleryCoodinator?.start()
        self.addChild(self.galleryCoodinator!)
    }
    
    func nextTool() {
        self.send(event: RouteToNextTool())
    }
}
