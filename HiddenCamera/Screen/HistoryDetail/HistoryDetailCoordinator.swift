//
//  HistoryDetailCoordinator.swift
//  HiddenCamera
//
//  Created by Duc apple  on 7/1/25.
//

import UIKit
import RxSwift

struct HistoryDetailRouteToToolEvent: CoordinatorEvent {
    var tool: ToolItem
    var scanOption: ScanOptionItem
}

struct HistoryDetailWantToBack: CoordinatorEvent { }

final class HistoryDetailCoordinator: NavigationBasedCoordinator {
    
    private var scanOption: ScanOptionItem
    
    init(scanOption: ScanOptionItem, navigationController: UINavigationController) {
        self.scanOption = scanOption
        super.init(navigationController: navigationController)
    }
    
    lazy var controller: HistoryDetailViewController = {
        let viewModel = HistoryDetailViewModel(scanOption: scanOption)
        let controller = HistoryDetailViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        
        scanOption.isEnd = true
        
        if navigationController.viewControllers.contains(where: { $0 is HistoryDetailViewController }) {
            navigationController.viewControllers.removeAll(where: { $0 is HistoryDetailViewController })
        }
        
        navigationController.pushViewController(controller, animated: true)
    }

    override func stop(completion: (() -> Void)? = nil) {
        super.stop(completion: completion)
       
        if navigationController.topViewController == controller {
            navigationController.popViewController(animated: true)
        } else {
            navigationController.viewControllers.removeAll(where: { $0 is HistoryDetailViewController })
        }
    }
    
    func routeToTool(tool: ToolItem) {
        self.send(event: HistoryDetailRouteToToolEvent(tool: tool, scanOption: scanOption))
    }
    
    func wantToBack() {
        self.send(event: HistoryDetailWantToBack())
    }
}
