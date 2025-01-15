//
//  MetalDetectorViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 7/1/25.
//

import UIKit
import RxSwift
import SwiftUI
import FirebaseAnalytics

struct MetalDetectorViewModelInput: InputOutputViewModel {
    var didTapBack = PublishSubject<()>()
    var didTapStart = PublishSubject<()>()
    var didTapNext = PublishSubject<()>()
}

struct MetalDetectorViewModelOutput: InputOutputViewModel {

}

struct MetalDetectorViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var nextTool = PublishSubject<()>()
}

final class MagnetometerViewModel: BaseViewModel<MetalDetectorViewModelInput, MetalDetectorViewModelOutput, MetalDetectorViewModelRouting> {

    @Published var x: Double = 0
    @Published var y: Double = 0
    @Published var z: Double = 0
    @Published var strength: Double = 0
    @Published var isDetecting: Bool = false
    
    let scanOption: ScanOptionItem?
    
    init(scanOption: ScanOptionItem?) {
        self.scanOption = scanOption
        super.init()
        Magnetometer.shared.locationDelegate = self
        
        if let scanOption {
            switch scanOption.type {
            case .option:
                Analytics.logEvent("feature_option_magnetic", parameters: nil)
            case .full:
                if scanOption.isThreadAfterIntro {
                    Analytics.logEvent("first_magnetic", parameters: nil)
                }
            default: break
            }
        }
    }
    
    override func configInput() {
        super.configInput()
        
        input.didTapNext.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.isDetecting = false
            Magnetometer.shared.stop()
            self.routing.nextTool.onNext(())
            self.strength = 0
            self.x = 0
            self.y = 0
            self.z = 0
        }).disposed(by: self.disposeBag)
        
        input.didTapStart.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            
            if !self.isDetecting {
                if !UserSetting.canUsingFeature(.magnetometer) && scanOption == nil {
                    SubscriptionViewController.open { }
                    return
                }
                
                if scanOption == nil {
                    UserSetting.increaseUsedFeature(.magnetometer)
                }
            }
            
            withAnimation {
                self.isDetecting.toggle()
            }
            
            if isDetecting {
                Magnetometer.shared.start()
                scanOption?.suspiciousResult[.magnetic] = 0
            } else {
                Magnetometer.shared.stop()
                withAnimation {
                    self.strength = 0
                    self.x = 0
                    self.y = 0
                    self.z = 0
                }
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapBack.subscribe(onNext: { [weak self] _ in
            Magnetometer.shared.stop()
            self?.routing.stop.onNext(())
        }).disposed(by: self.disposeBag)
    }
    
    func showBackButton() -> Bool {
        if let scanOption, scanOption.isThreadAfterIntro {
            return scanOption.isEnd && !isDetecting
        }
        
        return !isDetecting
    }
}

// MARK: - MagnetometerLocationDelegate
extension MagnetometerViewModel: MagnetometerLocationDelegate {
    func didFailWithError(error: any Error) {
        
    }
    
    func getUpdatedData(magnet: Magnetometer) {
        DispatchQueue.main.async {
            self.strength = magnet.magneticStrength
            self.x = magnet.x
            self.y = magnet.y
            self.z = magnet.z
        }
       
        if magnet.magneticStrength >= 200 {
            self.scanOption?.suspiciousResult[.magnetic] = 1
        }
    }
}
