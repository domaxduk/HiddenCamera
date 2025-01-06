//
//  AppleDevice.swift
//  HiddenCamera
//
//  Created by CucPhung on 4/1/25.
//

import Foundation

struct AppleDevice: Codable {
    let target: String?
    let target_type: String?
    let target_variant: String?
    let platform: String?
    let product_type: String?
    let product_description: String?
    let compatible_device_fallback: String?
    let traits: Trait?
    
    struct Trait: Codable {
        let preferred_architecture: String?
        let artwork_device_idiom: String?
        let artwork_scale_factor: Int?
        let artwork_device_subtype: Int?
        let artwork_display_gamut: String?
        let device_performance_memory_class: Int?
        let graphics_feature_set_class: String?
        let graphics_feature_set_fallbacks: String?
    }
}
