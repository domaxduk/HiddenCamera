//
//  MetalDetectorViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 7/1/25.
//

import UIKit
import RxSwift
import SwiftUI

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
    }
    
    override func configInput() {
        super.configInput()
        
        input.didTapNext.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.isDetecting = false
            Magnetometer.shared.stop()
            
            if scanOption?.suspiciousResult[.magnetic] == nil {
                scanOption?.suspiciousResult[.magnetic] = 0
            }
            
            self.routing.nextTool.onNext(())
        }).disposed(by: self.disposeBag)
        
        input.didTapStart.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            withAnimation {
                self.isDetecting.toggle()
            }
            
            if isDetecting {
                Magnetometer.shared.start()
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
}

// MARK: - MagnetometerLocationDelegate
extension MagnetometerViewModel: MagnetometerLocationDelegate {
    func didFailWithError(error: any Error) {
        
    }
    
    func getUpdatedData(magnet: Magnetometer) {
        self.strength = magnet.magneticStrength
        self.x = magnet.x
        self.y = magnet.y
        self.z = magnet.z
        
        if magnet.magneticStrength >= 200 {
            self.scanOption?.suspiciousResult[.magnetic] = 1
        }
    }
}
