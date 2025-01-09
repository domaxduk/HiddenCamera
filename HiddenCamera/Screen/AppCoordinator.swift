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
    private var introCoodinator: IntroCoordinator?
    
    override func start() {
        super.start()
        
      //  routeToHome()
        routeToIntro()
    }
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is IntroCoordinator {
            self.introCoodinator = nil
            self.routeToHome()
        }
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
    
    func routeToIntro() {
        let coordinator = IntroCoordinator(window: window)
        coordinator.start()
        addChild(coordinator)
        self.introCoodinator = coordinator
    }
}
