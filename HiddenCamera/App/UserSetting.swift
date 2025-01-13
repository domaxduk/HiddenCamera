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
    static var isPremiumUser: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isPremiumUser")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isPremiumUser")
        }
    }
    
    static var didShowIntro: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "didShowIntro")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "didShowIntro")
        }
    }
    
    static func numberUsedFeature(_ feature: AppFeature) -> Int {
        return UserDefaults.standard.integer(forKey: "used_\(feature.rawValue)_number")
    }
    
    static func increaseUsedFeature(_ feature: AppFeature) {
        let number = numberUsedFeature(feature)
        UserDefaults.standard.setValue(number + 1, forKey: "used_\(feature.rawValue)_number")
    }
    
    static func canUsingFeature(_ feature: AppFeature) -> Bool {
        return numberUsedFeature(feature) < AppConfig.limitFeatureNumber || UserSetting.isPremiumUser
    }
}

extension Notification.Name {
    static let updatePremiumVersion = Notification.Name("updatePremiumVersion")
}
