//
//  IntroViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 9/1/25.
//

import UIKit
import RxSwift
import SwiftUI
import AppTrackingTransparency

struct IntroViewModelInput: InputOutputViewModel {
    var didTapContinue = PublishSubject<()>()
}

struct IntroViewModelOutput: InputOutputViewModel {

}

struct IntroViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
}

final class IntroViewModel: BaseViewModel<IntroViewModelInput, IntroViewModelOutput, IntroViewModelRouting> {
    @Published var currentIndex: Int = 0
    
    @Published var intros: [IntroItem] = [
        .init(title: "Bluetooth Locator", description: "Use Bluetooth technology right on your phone to determine the location and distance of suspicious devices around you"),
        .init(title: "Wifi Devices Finder", description: "Allow the app to access your local network to detect any suspicious hidden devices, such as hidden cameras or other spy devices connected to the same network"),
        .init(title: "AI Camera Scanner", description: "Use your phone's camera combined with AI technology to detect hidden cameras in your surroundings in real time."),
        .init(title: "IR Vision Camera", description: "Easily and quickly detect infrared cameras using your device's camera and the app's bright color filter feature."),
        .init(title: "Magnetometer", description: "Use your phone's camera combined with AI technology to detect hidden cameras in your surroundings in real time.")
    ]
    
    @Published var isRequested: Bool = false
    
    override func config() {
        super.config()
        self.isRequested = ATTrackingManager.trackingAuthorizationStatus != .notDetermined
    }
    
    override func configInput() {
        super.configInput()
        
        input.didTapContinue.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            if isRequested {
                if self.currentIndex == intros.count {
                    self.routing.stop.onNext(())
                } else {
                    withAnimation {
                        self.currentIndex += 1
                    }
                }
            } else {
                requestTracking()
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func requestTracking() {
        ATTrackingManager.requestTrackingAuthorization { [weak self] status in
            print(status.rawValue)
            DispatchQueue.main.async {
                withAnimation {
                    self?.isRequested = true
                }
            }
        }
    }
}
