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
        
        if UserSetting.didShowIntro {
            SubscriptionViewController.open { [weak self] in
                self?.viewModel.didAppear = true
            }
        } else {
            let item = ScanOptionItem(tools: ToolItem.allCases, type: .full)
            item.isThreadAfterIntro = true
            self.coordinator?.startScanOption(item: item)
        }
    }

    // MARK: - Config
    func config() {
        configUI()
        configRoutingOutput()
    }

    func configRoutingOutput() {
        viewModel.routing.routeToInfraredCamera.subscribe(onNext: { [weak self] _ in
            self?.coordinator?.routeToInfraredCamera()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToCameraDetector.subscribe(onNext: { [weak self] _ in
            self?.coordinator?.routeToCameraDetector()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToWifiScanner.subscribe(onNext: { [weak self] _ in
            self?.coordinator?.routeToWifiScanner()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToBluetoothScanner.subscribe(onNext: { [weak self] _ in
            self?.coordinator?.routeToBluetoothScanner()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToMagnetic.subscribe(onNext: { [weak self] _ in
            self?.coordinator?.routeToMagnetic()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToScanOption.subscribe(onNext: { [weak self] item in
            self?.coordinator?.startScanOption(item: item)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToHistoryDetail.subscribe(onNext: { [weak self] item in
            Analytics.logEvent("feature_history_item", parameters: nil)
            self?.coordinator?.routeToHistoryDetail(item: item)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.presentAlert.subscribe(onNext: { [weak self] message in
            self?.presentAlert(title: "Alert", message: message)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.shareApp
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.viewModel.isShowingLoading = true
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
                
                self.present(shareActVC, animated: true, completion: { [weak self] in
                    self?.viewModel.isShowingLoading = true
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
