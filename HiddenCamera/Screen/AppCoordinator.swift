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
    private var splashCoodinator: SplashCoordinator?
    
    var didShowIntro: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "didShowIntro")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "didShowIntro")
        }
    }

    override func start() {
        super.start()
        
        routeToSplash()
    }
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is IntroCoordinator {
            self.introCoodinator = nil
            self.didShowIntro = true
            self.routeToHome()
        }
        
        if child is SplashCoordinator {
            self.splashCoodinator = nil
            
            if didShowIntro {
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
