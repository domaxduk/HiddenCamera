//
//  AppCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import Foundation
import RxSwift
import AppTrackingTransparency

class AppCoordinator: WindowBasedCoordinator {
    private var homeCoordinator: HomeCoordinator?
    private var introCoodinator: IntroCoordinator?
    private var splashCoodinator: SplashCoordinator?
    
    override func start() {
        super.start()
        
        routeToSplash()
    }
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is IntroCoordinator {
            self.introCoodinator = nil
            self.routeToHome()
        }
        
        if child is SplashCoordinator {
            self.splashCoodinator = nil
            
            if ATTrackingManager.trackingAuthorizationStatus != .notDetermined {
                self.routeToHome()
            } else {
                self.routeToIntro()
            }
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
    
    func routeToSplash() {
        let coordinator = SplashCoordinator(window: window)
        coordinator.start()
        addChild(coordinator)
        self.splashCoodinator = coordinator
    }
}
