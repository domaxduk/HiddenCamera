//
//  CameraDetectorViewController.swift
//  HiddenCamera
//
//  Created by Duc apple  on 3/1/25.
//

import UIKit
import RxSwift
import SwiftUI

class CameraDetectorViewController: ViewController {
    var viewModel: CameraDetectorViewModel
    weak var coordinator: CameraDetectorCoordinator?

    init(viewModel: CameraDetectorViewModel, coordinator: CameraDetectorCoordinator) {
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
        viewModel.startCamera()
    }
    
    // MARK: - Config
    func config() {
        configUI()
        configRoutingOutput()
    }

    func configRoutingOutput() {
        viewModel.routing.stop.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            if viewModel.isRecording {
                self.presentAlert(title: "Oops!", message: "You must stop this feature to back")
            } else {
                self.coordinator?.stop()
            }
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.nextTool.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            if viewModel.isRecording {
                self.presentAlert(title: "Oops!", message: "You must stop this feature to next")
            } else {
                self.coordinator?.nextTool()
            }
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.previewResult.subscribe(onNext: { [weak self] url in
            self?.coordinator?.routeToResult(url: url)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.gallery.subscribe(onNext: { [weak self] url in
            guard let self else { return }
            
            if viewModel.isRecording {
                self.presentAlert(title: "Oops!", message: "You must stop this feature to go to gallery")
            } else {
                self.coordinator?.routeToGallery()
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func configUI() {
        let mainView = CameraDetectorView(viewModel: viewModel)
        let hostingView = UIHostingController(rootView: mainView)
        hostingView.view.backgroundColor = .clear
        self.addChild(hostingView)
        hostingView.didMove(toParent: self)
        self.view.insertSubview(hostingView.view, at: 0)
        hostingView.view.fitSuperviewConstraint()
    }
}
