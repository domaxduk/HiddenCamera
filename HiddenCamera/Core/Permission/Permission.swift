//
//  Permission.swift
//  DemoDetect
//
//  Created by Duc apple  on 27/12/24.
//

import Foundation
import CoreLocation
import AVFoundation

class Permission {
    static var grantedLocation: Bool {
        let locationManager = CLLocationManager()
        let status = locationManager.authorizationStatus
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }
    
    static var grantedCamera: Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    static func requestCamera(completionHandler:  @escaping ((Bool) -> Void)) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: completionHandler)
    }
}
