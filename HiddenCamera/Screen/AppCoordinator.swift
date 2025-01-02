//
//  AppCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import Foundation
import RxSwift

class AppCoordinator: WindowBasedCoordinator {
    private var homeCoordinator: HomeCoordinator?
    let dispose = DisposeBag()
    
    override func start() {
        super.start()
        
        routeToHome()
    }
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
    }
}

// MARK: - Route
extension AppCoordinator {
    func routeToHome() {
        let coordinator = HomeCoordinator(window: window)
        coordinator.start()
        addChild(coordinator)
        self.homeCoordinator = coordinator
    }
}
