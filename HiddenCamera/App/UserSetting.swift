//
//  UserSetting.swift
//  HiddenCamera
//
//  Created by Duc apple  on 10/1/25.
//

import Foundation

enum AppFeature: String {
    case bluetooth
    case wifi
    case aiDetector
    case ifCamera
    case magnetometer
    case quickScan
    case scanOption
    case scanFull
}

class UserSetting {
    static var didOpenApp: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "didOpenApp")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "didOpenApp")
        }
    }
    
    static var didShowHome: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "didShowHome")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "didShowHome")
        }
    }
    
    static var isPremiumUser: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isPremiumUser")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isPremiumUser")
            NotificationCenter.default.post(name: .updatePremiumVersion, object: nil)
        }
    }
    
    static var safeDeviceKeys: [String] {
        get {
            return (UserDefaults.standard.array(forKey: "safeDeviceKeys") as? [String]) ?? []
        }
        set {
            return UserDefaults.standard.setValue(newValue, forKey: "safeDeviceKeys")
        }
    }
    
    static func numberUsedFeature(_ feature: AppFeature) -> Int {
        return UserDefaults.standard.integer(forKey: "used_\(feature.rawValue)_number")
    }
    
    static func increaseUsedFeature(_ feature: AppFeature) {
        let number = numberUsedFeature(feature)
        UserDefaults.standard.setValue(number + 1, forKey: "used_\(feature.rawValue)_number")
        print("[USER SETTING] \(feature.rawValue) \(numberUsedFeature(feature))")
    }
    
    static func canUsingFeature(_ feature: AppFeature) -> Bool {
        return numberUsedFeature(feature) < AppConfig.limitFeatureNumber || UserSetting.isPremiumUser
    }
}

extension Notification.Name {
    static let updatePremiumVersion = Notification.Name("updatePremiumVersion")
}
