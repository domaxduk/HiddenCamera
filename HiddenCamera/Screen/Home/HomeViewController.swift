//
//  HomeViewController.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import UIKit
import RxSwift
import SakuraExtension
import SwiftUI

class HomeViewController: ViewController {
    var viewModel: HomeViewModel
    weak var coordinator: HomeCoordinator?

    init(viewModel: HomeViewModel, coordinator: HomeCoordinator) {
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
        configViewModelInput()
        configViewModelOutput()
        configRoutingOutput()
    }

    func configViewModelInput() {

    }

    func configViewModelOutput() {
        
    }

    func configRoutingOutput() {
        viewModel.routing.routeToInfraredCamera.subscribe(onNext: { [weak self] _ in
            self?.coordinator?.routeToInfraredCamera()
        }).disposed(by: self.disposeBag)
    }
    
    // MARK: - ConfigUI
    private func configUI() {
        let mainView = HomeView(viewModel: viewModel)
        let hostingView = UIHostingController(rootView: mainView)
        hostingView.view.backgroundColor = .clear
        self.addChild(hostingView)
        hostingView.didMove(toParent: self)
        self.view.addSubview(hostingView.view)
        hostingView.view.fitSuperviewConstraint()
    }
}
