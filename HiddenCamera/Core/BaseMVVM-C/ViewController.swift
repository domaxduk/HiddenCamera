//
//  BaseViewController.swift
//
//

import Foundation
import UIKit
import RxSwift
import SwiftUI
import SwiftUI

open class ViewController: UIViewController {
    private(set) var viewWillAppeared: Bool = false
    private(set) var viewDidAppeared: Bool = false
        
    public var isDisplaying: Bool = false
    public let disposeBag = DisposeBag()
    private var loadingView: UIHostingController<LoadingView>!
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    // MARK: - Life Cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        registerNotificationCenter()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !viewWillAppeared {
            viewWillAppeared = true
            self.viewWillFirstAppear()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isDisplaying = true

        if !viewDidAppeared {
            self.viewDidFirstAppear()
            viewDidAppeared = true
        }
    }
    
    open func viewWillFirstAppear() {
    }
    
    open func viewDidFirstAppear() {
    }
    
    public func actionAfterInter() {
        
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isDisplaying = false
    }
    
    open override func viewWillTransition(to size: CGSize,
                                          with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
    }
    
    func registerNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updatePremiumVersion), name: .updatePremiumVersion, object: nil)
    }
    
    @objc func updatePremiumVersion() {
       
    }
    
    func insertSwiftUIView<Content: View>(rootView: Content) {
        let hostingView = UIHostingController(rootView: rootView)
        hostingView.view.backgroundColor = .clear
        self.addChild(hostingView)
        hostingView.didMove(toParent: self)
        self.view.addSubview(hostingView.view)
        hostingView.view.fitSuperviewConstraint()
    }
}

// MARK: - Loading
extension ViewController {
    func showLoading() {
        if self.loadingView == nil {
            self.loadingView = UIHostingController(rootView: LoadingView())
            self.loadingView.view.backgroundColor = .clear
            self.loadingView.modalPresentationStyle = .overFullScreen
            self.loadingView.modalTransitionStyle = .crossDissolve
        }
        
        self.view.addSubview(self.loadingView.view)
        self.loadingView.view.alpha = 0
        self.loadingView.view.fitSuperviewConstraint()
        
        UIView.animate(withDuration: 0.3) {
            self.loadingView.view.alpha = 1
        }
    }
    
    func hideLoading() {
        if self.loadingView != nil {
            UIView.animate(withDuration: 0.3) {
                self.loadingView.view.alpha = 0
            } completion: { [weak self] isDone in
                self?.loadingView.view.removeFromSuperview()
            }
        }
    }
}
