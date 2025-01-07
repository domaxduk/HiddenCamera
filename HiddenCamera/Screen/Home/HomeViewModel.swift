//
//  HomeViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import UIKit
import RxSwift
import CoreLocation

struct HomeViewModelInput: InputOutputViewModel {
    var didSelectTool = PublishSubject<ToolItem>()
    var didTapQuickScan = PublishSubject<()>()
}

struct HomeViewModelOutput: InputOutputViewModel {

}

struct HomeViewModelRouting: RoutingOutput {
    var routeToInfraredCamera = PublishSubject<()>()
    var routeToCameraDetector = PublishSubject<()>()
    var routeToWifiScanner = PublishSubject<()>()
    var routeToBluetoothScanner = PublishSubject<()>()
    var routeToMagnetic = PublishSubject<()>()
    
    var routeToScanOption = PublishSubject<ScanOptionItem>()
}

final class HomeViewModel: BaseViewModel<HomeViewModelInput, HomeViewModelOutput, HomeViewModelRouting> {
    @Published var currentTab: HomeTab = .scan
    
    override func configInput() {
        super.configInput()
        
        input.didSelectTool.subscribe(onNext: { [weak self] tool in
            switch tool {
            case .infraredCamera:
                self?.routeToInfraredCamera()
            case .cameraDetector:
                self?.routeToCameraDetector()
            case .wifiScanner:
                self?.routeToWifiScanner()
            case .bluetoothScanner:
                self?.routing.routeToBluetoothScanner.onNext(())
            case .magnetic:
                self?.routeToMetalDetector()
            default: break
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapQuickScan.subscribe(onNext: { [weak self] _ in 
            self?.routing.routeToScanOption.onNext(.init())
        }).disposed(by: self.disposeBag)
    }
    
    private func routeToInfraredCamera() {
        self.routing.routeToInfraredCamera.onNext(())
    }
    
    private func routeToCameraDetector() {
        self.routing.routeToCameraDetector.onNext(())
    }
    
    private func routeToWifiScanner() {
        self.routing.routeToWifiScanner.onNext(())
    }
    
    private func routeToMetalDetector() {
        self.routing.routeToMagnetic.onNext(())
    }
}
