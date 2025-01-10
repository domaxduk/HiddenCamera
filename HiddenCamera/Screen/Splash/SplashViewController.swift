//
//  SplashViewController.swift
//  HiddenCamera
//
//  Created by Duc apple  on 9/1/25.
//

import UIKit
import RxSwift

class SplashViewController: ViewController {
    var viewModel: SplashViewModel
    weak var coordinator: SplashCoordinator?

    init(viewModel: SplashViewModel, coordinator: SplashCoordinator) {
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
    
    override func viewDidFirstAppear() {
        super.viewDidFirstAppear()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.coordinator?.stop()
        }
    }

    // MARK: - Config
    func config() {
        self.insertSwiftUIView(rootView: SplashView())
    }
}
