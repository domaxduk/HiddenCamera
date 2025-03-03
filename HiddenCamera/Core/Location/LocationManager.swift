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
    
    func getCurrentLocation() -> Observable<String> {
        let location = manager.location

        return Observable<String>.create { observer in
            location?.fetchCityAndCountry { address, error in
                if let error {
                    observer.onError(error)
                }
                
                if let address {
                    observer.onNext(address)
                }
                
                observer.onCompleted()
            }
            
            return Disposables.create {
                
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            self.status = manager.authorizationStatus
            
            if status == .authorizedWhenInUse || status == .authorizedWhenInUse {
                manager.startUpdatingLocation()
            }
        }
    }
}

fileprivate extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ address: String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { placemark, error in
            completion(placemark?.first?.fullAddress, error)
        }
    }
}

fileprivate extension CLPlacemark {
    var fullAddress: String {
        var addressParts: [String] = []
        
        if let name = self.name {
            addressParts.append(name)
        }
        if let thoroughfare = self.thoroughfare {
            addressParts.append(thoroughfare)
        }
        if let subThoroughfare = self.subThoroughfare {
            addressParts.append(subThoroughfare)
        }
        if let locality = self.locality {
            addressParts.append(locality)
        }
        if let administrativeArea = self.administrativeArea {
            addressParts.append(administrativeArea)
        }
        if let postalCode = self.postalCode {
            addressParts.append(postalCode)
        }
        if let country = self.country {
            addressParts.append(country)
        }
        
        return addressParts.joined(separator: ", ")
    }
}
