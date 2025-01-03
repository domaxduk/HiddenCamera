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
}

struct HomeViewModelOutput: InputOutputViewModel {

}

struct HomeViewModelRouting: RoutingOutput {
    var routeToInfraredCamera = PublishSubject<()>()
    var routeToCameraDetector = PublishSubject<()>()
    var routeToWifiScanner = PublishSubject<()>()
}

final class HomeViewModel: BaseViewModel<HomeViewModelInput, HomeViewModelOutput, HomeViewModelRouting> {
    @Published var currentTab: HomeTab = .tools
    
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
            default: break
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func routeToInfraredCamera() {
        Permission.requestCamera { [weak self] granted in
            DispatchQueue.main.async {
                self?.routing.routeToInfraredCamera.onNext(())
            }
        }
    }
    
    private func routeToCameraDetector() {
        Permission.requestCamera { [weak self] granted in
            DispatchQueue.main.async {
                self?.routing.routeToCameraDetector.onNext(())
            }
        }
    }
    
    private func routeToWifiScanner() {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            self.routing.routeToWifiScanner.onNext(())
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension HomeViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus != .notDetermined {
            self.routing.routeToWifiScanner.onNext(())
        }
    }
}
