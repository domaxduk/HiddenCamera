//
//  MetalDetectorViewController.swift
//  HiddenCamera
//
//  Created by Duc apple  on 7/1/25.
//

import UIKit
import RxSwift
import SwiftUI

class MagnetometerViewController: ViewController {
    var viewModel: MagnetometerViewModel
    weak var coordinator: MagnetometerCoordinator?

    init(viewModel: MagnetometerViewModel, coordinator: MagnetometerCoordinator) {
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
    }
    
    private func configUI() {
        let mainView = MagnetometerView(viewModel: viewModel)
        let hostingView = UIHostingController(rootView: mainView)
        hostingView.view.backgroundColor = .clear
        self.addChild(hostingView)
        hostingView.didMove(toParent: self)
        self.view.addSubview(hostingView.view)
        hostingView.view.fitSuperviewConstraint()
    }
}
