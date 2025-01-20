//
//  Device.swift
//  DemoDetect
//
//  Created by Duc apple  on 24/12/24.
//

import Foundation
import UIKit
import SwiftUI
import dnssd
import Network

class Device: NSObject, ObservableObject {
    var id: String
    
    init(id: String) {
        self.id = id
    }
    
    var imageName: String {
        return "ic_device_unknown"
    }
    
    func deviceName() -> String? {
        return nil
    }
    
    func note() -> String {
        return ""
    }
    
    var keystore: [String] {
        return [id]
    }
    
    internal func getImageName(from key: String) -> String? {
        let compareText = key.lowercased().replacingOccurrences(of: " ", with: "")
        
        if compareText.contains("airpod") {
            return "ic_device_airpod"
        }
        
        if compareText.contains("tv") {
            return "ic_device_tv"
        }
        
        if compareText.contains("watch") {
            return "ic_device_watch"
        }
        
        if compareText.contains("macbook") || compareText.contains("macmini") || compareText.contains("pc") {
            return "ic_device_laptop"
        }
        
        if compareText.contains("phone") || compareText.contains("redmi") {
            return "ic_device_phone"
        }
        
        if compareText.contains("ipad") || compareText.contains("tablet") {
            return "ic_device_tablet"
        }
        
        return nil
    }
    
    func isSafe() -> Bool {
        return UserSetting.safeDeviceKeys.contains(where: { key in
            return keystore.contains(where: { $0 == key })
        })
    }
}

