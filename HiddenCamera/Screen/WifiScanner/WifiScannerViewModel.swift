//
//  WifiScannerViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 3/1/25.
//

import UIKit
import RxSwift
import SwiftUI

struct WifiScannerViewModelInput: InputOutputViewModel {
    var didTapScan = PublishSubject<()>()
}

struct WifiScannerViewModelOutput: InputOutputViewModel {

}

struct WifiScannerViewModelRouting: RoutingOutput {

}

enum WifiScannerState {
    case ready
    case isScanning
    case done
}

final class WifiScannerViewModel: BaseViewModel<WifiScannerViewModelInput, WifiScannerViewModelOutput, WifiScannerViewModelRouting> {
    @Published var state: WifiScannerState = .ready
    @Published var percent: Double = 0
    @Published var seconds: Double = 0
    private var timer: Timer?
    
    override func configInput() {
        super.configInput()
        
        input.didTapScan.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            withAnimation {
                self.state = .isScanning
            }
            
            self.startTimer()
        }).disposed(by: self.disposeBag)
    }
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            seconds += 0.1
            self.percent = seconds / AppConfig.wifiDuration * 100
            
            if seconds >= AppConfig.wifiDuration {
                timer?.invalidate()
                state = .done
            }
        })
    }
}
