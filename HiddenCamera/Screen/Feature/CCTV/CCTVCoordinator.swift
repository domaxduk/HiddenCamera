//
//  CCTVCoordinator.swift
//  HiddenCamera
//
//  Created by Tra Le on 11/2/25.
//

import UIKit

final class CCTVCoordinator: NavigationBasedCoordinator {
    let cctv: CCTV
    let info: CCTVInfoFetcher.Result?
    
    init(cctv: CCTV, info: CCTVInfoFetcher.Result?, navigationController: UINavigationController) {
        self.cctv = cctv
        self.info = info
        super.init(navigationController: navigationController)
    }
    
    lazy var controller: CCTVViewController = {
        let viewModel = CCTVViewModel(cctv: cctv)
        let controller = CCTVViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        navigationController.pushViewController(controller, animated: true)
    }

    override func stop(completion: (() -> Void)? = nil) {
        navigationController.popViewController(animated: true)
        super.stop(completion: completion)
    }
}
