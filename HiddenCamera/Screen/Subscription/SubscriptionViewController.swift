//
//  SubscriptionViewController.swift
//  HiddenCamera
//
//  Created by Duc apple  on 10/1/25.
//

import UIKit
import SwiftUI
import RxSwift

class SubscriptionViewController: ViewController {
     
    var viewModel: SubscriptionViewModel
    
    init(viewModel: SubscriptionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let view = SubscriptionView(viewModel: viewModel).environmentObject(HomeViewModel())
        insertSwiftUIView(rootView: view)
        
        viewModel.didTapBack.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true, completion: self?.viewModel.actionAfterDismiss)
        }).disposed(by: self.disposeBag)
        
        viewModel.presentAlert.subscribe(onNext: { [weak self] message in
            self?.presentAlert(title: "Alert", message: message)
        }).disposed(by: self.disposeBag)
    }
    
    override func viewWillFirstAppear() {
        super.viewWillFirstAppear()
        viewModel.loadInfo()
    }
    
    static func open(controller: UIViewController? = nil, actionAfterDismiss: @escaping (() -> Void)) {
        if UserSetting.isPremiumUser {
            actionAfterDismiss()
            return
        }
        
        print("show subscription")
        
        let vc = SubscriptionViewController(viewModel: SubscriptionViewModel(actionAfterDismiss: actionAfterDismiss))
        vc.modalPresentationStyle = .overFullScreen
        let topVC = controller ?? UIApplication.shared.navigationController?.topVC 
        topVC?.present(vc, animated: true)
    }
}
