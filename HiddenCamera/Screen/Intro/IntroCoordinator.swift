//
//  IntroCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 9/1/25.
//

import UIKit
import RxSwift

final class IntroCoordinator: WindowBasedCoordinator {
    lazy var controller: IntroViewController = {
        let viewModel = IntroViewModel()
        let controller = IntroViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        
        window.rootViewController = controller
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.1, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }

    override func stop(completion: (() -> Void)? = nil) {
        super.stop(completion: completion)
    }
}
