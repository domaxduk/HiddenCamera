//
//  SplashCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 9/1/25.
//

import UIKit
import RxSwift

final class SplashCoordinator: WindowBasedCoordinator {
    lazy var controller: SplashViewController = {
        let viewModel = SplashViewModel()
        let controller = SplashViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        
        window.rootViewController = controller
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }

    override func stop(completion: (() -> Void)? = nil) {
        super.stop(completion: completion)
    }
}
