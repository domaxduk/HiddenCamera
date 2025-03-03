//
//  CCTVCountryViewController.swift
//  HiddenCamera
//
//  Created by Tra Le on 11/2/25.
//

import UIKit
import RxSwift

class CCTVCountryViewController: ViewController {
    var viewModel: CCTVCountryViewModel
    weak var coordinator: CCTVCountryCoordinator?

    init(viewModel: CCTVCountryViewModel, coordinator: CCTVCountryCoordinator) {
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
    
    override func updatePremiumVersion() {
        super.updatePremiumVersion()
        viewModel.isPremium = UserSetting.isPremiumUser
    }

    // MARK: - Config
    func config() {
        insertSwiftUIView(rootView: CCTVCountryView(viewModel: viewModel))
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
        
        viewModel.routing.routeToDetail.subscribe(onNext: { [weak self] cctv, info in
            self?.coordinator?.routeToCCTV(cctv: cctv, info: info)
        }).disposed(by: self.disposeBag)
    }
}
