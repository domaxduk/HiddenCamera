//
//  UserSetting.swift
//  HiddenCamera
//
//  Created by Duc apple  on 10/1/25.
//

import Foundation

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
}

extension Notification.Name {
    static let updatePremiumVersion = Notification.Name("updatePremiumVersion")
}
