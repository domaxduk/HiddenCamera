//
//  WifiScannerViewController.swift
//  HiddenCamera
//
//  Created by Duc apple  on 3/1/25.
//

import UIKit
import RxSwift
import SwiftUI

class WifiScannerViewController: ViewController {
    var viewModel: WifiScannerViewModel
    weak var coordinator: WifiScannerCoordinator?

    init(viewModel: WifiScannerViewModel, coordinator: WifiScannerCoordinator) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.objectWillChange.send()
    }

    // MARK: - Config
    func config() {
        configUI()
        configRoutingOutput()
    }

    func configRoutingOutput() {
        viewModel.routing.routeToResult.subscribe(onNext: { [weak self] devices in
            self?.coordinator?.routeToResult(device: devices)
        }).disposed(by: self.disposeBag)
        
        self.viewModel.routing.stop.subscribe(onNext: { [weak  self] _ in
            guard let self else { return }
            self.coordinator?.stop()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.showErrorMessage.subscribe(onNext: { [weak self] message in
            self?.presentAlert(title: "Oops!", message: message)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.nextTool.subscribe(onNext: { [weak self] _ in
            self?.coordinator?.nextTool()
        }).disposed(by: self.disposeBag)
    }
    
    private func configUI() {
        let mainView = WifiScannerView(viewModel: viewModel)
        let hostingView = UIHostingController(rootView: mainView)
        hostingView.view.backgroundColor = .clear
        self.addChild(hostingView)
        hostingView.didMove(toParent: self)
        self.view.addSubview(hostingView.view)
        hostingView.view.fitSuperviewConstraint()
    }
}
