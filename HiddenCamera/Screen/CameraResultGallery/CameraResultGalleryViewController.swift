//
//  CameraResultGalleryViewController.swift
//  HiddenCamera
//
//  Created by Duc apple  on 2/1/25.
//

import UIKit
import RxSwift
import SwiftUI

class CameraResultGalleryViewController: ViewController {
    var viewModel: CameraResultGalleryViewModel
    weak var coordinator: CameraResultGalleryCoordinator?

    init(viewModel: CameraResultGalleryViewModel, coordinator: CameraResultGalleryCoordinator) {
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
        viewModel.routing.back.subscribe(onNext: { [weak self] _ in
            self?.coordinator?.stop()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.preview.subscribe(onNext: { [weak self] item in
            self?.coordinator?.routeToPreview(item: item)
        }).disposed(by: self.disposeBag)
    }
    
    private func configUI() {
        let mainView = CameraResultGalleryView(viewModel: viewModel)
        let hostingView = UIHostingController(rootView: mainView)
        hostingView.view.backgroundColor = .clear
        self.addChild(hostingView)
        hostingView.didMove(toParent: self)
        self.view.addSubview(hostingView.view)
        hostingView.view.fitSuperviewConstraint()
    }
}
