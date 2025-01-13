//
//  SubscriptionViewController.swift
//  HiddenCamera
//
//  Created by Duc apple  on 10/1/25.
//

import UIKit
import SwiftUI
import RxSwift

class SubscriptionViewModel: ObservableObject {
    @Published var items: [SubscriptionItem] = [
        SubscriptionItem(type: .week, title: "Weekly",
                         id: "week", priceString: "$9.99", pricePerWeek: "", color: .black, noteString: ""),
        SubscriptionItem(type: .year, title: "Yearly",
                         id: "year", priceString: "$19.99",
                         pricePerWeek: "Only $.. per week", color: .black, noteString: "Save 50%")
    ]
    
    @Published var currentItem: SubscriptionItem?
    var actionAfterDismiss: (() -> Void)
    var didTapBack = PublishSubject<()>()
    
    init(actionAfterDismiss: @escaping (() -> Void)) {
        self.actionAfterDismiss = actionAfterDismiss
    }
}

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

        
        let view = SubscriptionView(viewModel: viewModel)
        insertSwiftUIView(rootView: view)
        
        viewModel.didTapBack.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true, completion: self?.viewModel.actionAfterDismiss)
        }).disposed(by: self.disposeBag)
    }
    
    static func open(actionAfterDismiss: @escaping (() -> Void)) {
        let vc = SubscriptionViewController(viewModel: SubscriptionViewModel(actionAfterDismiss: actionAfterDismiss))
        vc.modalPresentationStyle = .overFullScreen
        let topVC = UIApplication.shared.navigationController?.topVC
        topVC?.present(vc, animated: true)
    }
}
