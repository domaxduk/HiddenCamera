//
//  HistoryCoordinator.swift
//  HiddenCamera
//
//  Created by Tra Le on 12/2/25.
//

import UIKit

final class HistoryCoordinator: NavigationBasedCoordinator {
    private var historyDetailCoordinator: HistoryDetailCoordinator?

    lazy var controller: HistoryViewController = {
        let viewModel = HistoryViewModel()
        let controller = HistoryViewController(viewModel: viewModel, coordinator: self)
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
        
        if child is HistoryDetailCoordinator {
            self.historyDetailCoordinator = nil
        }
    }
    
    func routeToHistoryDetail(item: ScanOptionItem) {
        self.historyDetailCoordinator = HistoryDetailCoordinator(scanOption: item, navigationController: navigationController)
        self.addChild(self.historyDetailCoordinator)
        self.historyDetailCoordinator?.start()
    }
}
