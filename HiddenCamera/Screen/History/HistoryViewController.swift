//
//  HistoryViewController.swift
//  HiddenCamera
//
//  Created by Tra Le on 12/2/25.
//

import UIKit
import RxSwift
import FirebaseAnalytics

class HistoryViewController: ViewController {
    var viewModel: HistoryViewModel
    weak var coordinator: HistoryCoordinator?

    init(viewModel: HistoryViewModel, coordinator: HistoryCoordinator) {
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
        insertSwiftUIView(rootView: HistoryView(viewModel: viewModel))
        configRoutingOutput()
    }

    func configRoutingOutput() {
        viewModel.routing.stop.subscribe(onNext: { [weak self] in
            self?.coordinator?.stop()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToHistoryDetail.subscribe(onNext: { [weak self] item in
            Analytics.logEvent("feature_history_item", parameters: nil)
            self?.coordinator?.routeToHistoryDetail(item: item)
        }).disposed(by: self.disposeBag)
    }
}
