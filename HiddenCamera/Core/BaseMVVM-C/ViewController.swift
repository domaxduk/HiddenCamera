//
//  BaseViewController.swift
//
//

import Foundation
import UIKit
import RxSwift

open class ViewController: UIViewController {
    private(set) var viewWillAppeared: Bool = false
    private(set) var viewDidAppeared: Bool = false
        
    public var isDisplaying: Bool = false
    public let disposeBag = DisposeBag()
    
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
        
    }
    
    @objc func updatePremiumVersion() {
       
    }
}
