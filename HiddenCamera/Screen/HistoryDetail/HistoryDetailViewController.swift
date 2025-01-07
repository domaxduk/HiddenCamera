//
//  HistoryDetailViewController.swift
//  HiddenCamera
//
//  Created by Duc apple  on 7/1/25.
//

import UIKit
import RxSwift
import SwiftUI

class HistoryDetailViewController: ViewController {
    var viewModel: HistoryDetailViewModel
    weak var coordinator: HistoryDetailCoordinator?

    init(viewModel: HistoryDetailViewModel, coordinator: HistoryDetailCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    // MARK: - Config
    func config() {
        configUI()
        configRoutingOutput()
    }

    func configRoutingOutput() {
        self.viewModel.routing.stop.subscribe(onNext: { [weak  self] _ in
            guard let self else { return }
            self.coordinator?.stop()
        }).disposed(by: self.disposeBag)
        
        self.viewModel.routing.routeToTool.subscribe(onNext: { [weak  self] tool in
            guard let self else { return }
            self.coordinator?.routeToTool(tool: tool)
        }).disposed(by: self.disposeBag)
    }
    
    private func configUI() {
        let mainView = HistoryDetailView(viewModel: viewModel)
        let hostingView = UIHostingController(rootView: mainView)
        hostingView.view.backgroundColor = .clear
        self.addChild(hostingView)
        hostingView.didMove(toParent: self)
        self.view.addSubview(hostingView.view)
        hostingView.view.fitSuperviewConstraint()
    }
}
