//
//  CCTVCountryCoordinator.swift
//  HiddenCamera
//
//  Created by Tra Le on 11/2/25.
//

import UIKit

final class CCTVCountryCoordinator: NavigationBasedCoordinator {
    private var detailCoordinator: CCTVCoordinator?
    private let country: CCTVCountry
    
    init(country: CCTVCountry, navigationController: UINavigationController) {
        self.country = country
        super.init(navigationController: navigationController)
    }
    
    lazy var controller: CCTVCountryViewController = {
        let viewModel = CCTVCountryViewModel(country: country)
        let controller = CCTVCountryViewController(viewModel: viewModel, coordinator: self)
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
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is CCTVCoordinator {
            self.detailCoordinator = nil
        }
    }
    
    func routeToCCTV(cctv: CCTV, info: CCTVInfoFetcher.Result?) {
        self.detailCoordinator = CCTVCoordinator(cctv: cctv, info: info, navigationController: navigationController)
        self.detailCoordinator?.start()
        self.addChild(detailCoordinator)
    }
}
