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
        let viewModel = InfraredCameraViewModel(hasButtonNext: self.scanOption != nil)
        let controller = InfraredCameraViewController(viewModel: viewModel, coordinator: self)
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
        let item = CameraResultItem(id: UUID().uuidString, fileName: url.lastPathComponent, type: .infrared)
        self.previewResult = CameraResultCoordinator(item: item, navigationController: navigationController)
        self.previewResult?.start()
        self.addChild(self.previewResult!)
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
