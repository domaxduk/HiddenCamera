//
//  Copyright 2023 Google LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import GoogleMobileAds
import UserMessagingPlatform

class AdsConsentManager: NSObject {
    static let shared = AdsConsentManager()
    
    var canRequestAds: Bool {
        return UMPConsentInformation.sharedInstance.canRequestAds
    }
    
    var isPrivacyOptionsRequired: Bool {
        return UMPConsentInformation.sharedInstance.privacyOptionsRequirementStatus == .required
    }

    func gatherConsent(from consentFormPresentationviewController: UIViewController, consentGatheringComplete: @escaping (Error?) -> Void) {
        let parameters = UMPRequestParameters()
        let debugSettings = UMPDebugSettings()
        debugSettings.testDeviceIdentifiers = ["861AB8C1-C94E-45CF-8445-C0C930216F82"]
        parameters.debugSettings = debugSettings
        
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) {
            requestConsentError in
            guard requestConsentError == nil else {
                return consentGatheringComplete(requestConsentError)
            }
                        
            UMPConsentForm.loadAndPresentIfRequired(from: consentFormPresentationviewController) {
                loadAndPresentError in
                
                // Consent has been gathered.
                consentGatheringComplete(loadAndPresentError)
            }
        }
    }
    
    /// Helper method to call the UMP SDK method to present the privacy options form.
    func presentPrivacyOptionsForm(from viewController: UIViewController, completionHandler: @escaping (Error?) -> Void) {
        UMPConsentForm.presentPrivacyOptionsForm(
            from: viewController, completionHandler: completionHandler)
    }
    
    func needToShow() -> Bool {
        return UMPConsentInformation.sharedInstance.consentStatus == .required
    }
}
