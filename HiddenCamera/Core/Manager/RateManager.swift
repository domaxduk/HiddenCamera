//
//  RateManager.swift
//  HiddenCamera
//
//  Created by Duc apple  on 9/1/25.
//

import Foundation
import UIKit
import StoreKit

class RateManager {
    static func rate() {
        if #available(iOS 14.0, *) {
           if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
               SKStoreReviewController.requestReview(in: scene)
           }
        } else {
           SKStoreReviewController.requestReview()
        }
    }
}
