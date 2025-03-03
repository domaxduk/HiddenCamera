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
import FirebaseAnalytics

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
    
    override func updatePremiumVersion() {
        super.updatePremiumVersion()
        viewModel.isPremium = UserSetting.isPremiumUser
    }
    
    override func viewDidFirstAppear() {
        super.viewDidFirstAppear()
        
        if UserSetting.didShowHome {
            Analytics.logEvent("open_home", parameters: nil)
        } else {
            Analytics.logEvent("first_home", parameters: nil)
            UserSetting.didShowHome = true
        }
        
        SubscriptionViewController.open { [weak self] in
            self?.viewModel.didAppear = true
        }
    }

    // MARK: - Config
    func config() {
        configUI()
        configRoutingOutput()
    }

    func configRoutingOutput() {
        viewModel.routing.routeToScanOption.subscribe(onNext: { [weak self] item in
            self?.coordinator?.startScanOption(item: item)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToCCTVCountry.subscribe(onNext: { [weak self] country in
            self?.coordinator?.routeToCCTVCountry(country: country)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToHistory.subscribe(onNext: { [weak self] in
            Analytics.logEvent("feature_history", parameters: nil)
            self?.coordinator?.routeToHistory()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.presentAlert.subscribe(onNext: { [weak self] message in
            self?.presentAlert(title: "Alert", message: message)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.shareApp
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.showLoading()
                let items = ["https://apps.apple.com/app/apple-store/id\(AppConfig.appID)"]
                let shareActVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
                shareActVC.view.tintColor = UIColor.orange
                shareActVC.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                shareActVC.completionWithItemsHandler = { _, _, _, _ in }
                
                if let popoverController = shareActVC.popoverPresentationController {
                    popoverController.sourceRect = self.view.bounds
                    popoverController.sourceView = self.view
                    popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                }
                
                self.present(shareActVC, animated: true, completion: {
                    self.hideLoading()
                })
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
