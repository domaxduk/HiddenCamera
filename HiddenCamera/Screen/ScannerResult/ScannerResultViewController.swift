//
//  ScannerResultViewController.swift
//  HiddenCamera
//
//  Created by CucPhung on 5/1/25.
//

import UIKit
import SwiftUI
import RxSwift

class ScannerResultViewController: ViewController {
    var viewModel: ScannerResultViewModel
    weak var coordinator: ScannerResultCoordinator?

    init(viewModel: ScannerResultViewModel, coordinator: ScannerResultCoordinator) {
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
        self.viewModel.routing.stop.subscribe(onNext: { [weak  self] _  in
            self?.coordinator?.stop()
        }).disposed(by: self.disposeBag)
        
        self.viewModel.routing.nextTool.subscribe(onNext: { [weak  self] _  in
            self?.coordinator?.nextTool()
        }).disposed(by: self.disposeBag)
    }
    
    private func configUI() {
        let mainView = ScannerResultView(viewModel: viewModel)
        let hostingView = UIHostingController(rootView: mainView)
        hostingView.view.backgroundColor = .clear
        self.addChild(hostingView)
        hostingView.didMove(toParent: self)
        self.view.addSubview(hostingView.view)
        hostingView.view.fitSuperviewConstraint()
    }
}
