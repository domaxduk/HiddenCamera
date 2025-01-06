//
//  LocationManager.swift
//  HiddenCamera
//
//  Created by Duc apple  on 6/1/25.
//

import Foundation
import CoreLocation
import RxSwift

class LocationManager: NSObject {
    static let shared = LocationManager()
    private var manager: CLLocationManager
    
    var statusObserver = ReplaySubject<CLAuthorizationStatus>.create(bufferSize: 1)
    
    var status: CLAuthorizationStatus? {
        didSet {
            if let status {
                self.statusObserver.onNext(status)
            }
        }
    }
    
    private override init() {
        self.manager = CLLocationManager()
        super.init()
        self.manager.delegate = self
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            self.status = manager.authorizationStatus
        }
    }
}
