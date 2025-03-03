//
//  CCTVViewController.swift
//  HiddenCamera
//
//  Created by Tra Le on 11/2/25.
//

import UIKit
import RxSwift

class CCTVViewController: ViewController {
    var viewModel: CCTVViewModel
    weak var coordinator: CCTVCoordinator?

    init(viewModel: CCTVViewModel, coordinator: CCTVCoordinator) {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.didAppear = true
    }
    
    override func updatePremiumVersion() {
        super.updatePremiumVersion()
        viewModel.isPremium = UserSetting.isPremiumUser
    }

    // MARK: - Config
    func config() {
        insertSwiftUIView(rootView: CCTVDetailView(viewModel: viewModel))
        configViewModelInput()
        configViewModelOutput()
        configRoutingOutput()
    }

    func configViewModelInput() {

    }

    func configViewModelOutput() {
        
    }

    func configRoutingOutput() {
        viewModel.routing.stop.subscribe(onNext: { [weak self] in
            self?.coordinator?.stop()
        }).disposed(by: self.disposeBag)
    }
}
