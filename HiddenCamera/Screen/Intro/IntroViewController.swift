//
//  IntroViewController.swift
//  HiddenCamera
//
//  Created by Duc apple  on 9/1/25.
//

import UIKit
import RxSwift
import SwiftUI

class IntroViewController: ViewController {
    var viewModel: IntroViewModel
    weak var coordinator: IntroCoordinator?

    init(viewModel: IntroViewModel, coordinator: IntroCoordinator) {
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
        configUI()
        configRoutingOutput()
    }

    func configRoutingOutput() {
        self.viewModel.routing.stop.subscribe(onNext: { [weak self] _ in
            self?.coordinator?.stop()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.showConsent.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.requestConsent()
        }).disposed(by: self.disposeBag)
    }
    
    private func requestConsent() {
        AdsConsentManager.shared.gatherConsent(from: self) { [weak self] _ in
            DispatchQueue.main.async {
                withAnimation {
                    self?.viewModel.isRequested = true
                }
            }
        }
    }
    
    // MARK: - ConfigUI
    private func configUI() {
        let mainView = IntroView(viewModel: viewModel)
        let hostingView = UIHostingController(rootView: mainView)
        hostingView.view.backgroundColor = .clear
        self.addChild(hostingView)
        hostingView.didMove(toParent: self)
        self.view.addSubview(hostingView.view)
        hostingView.view.fitSuperviewConstraint()
    }
}
