//
//  ServiceType.swift
//  HiddenCamera
//
//  Created by CucPhung on 4/1/25.
//

import Foundation

enum ServiceType: String, CaseIterable {
    case deviceInfo = "_device-info._tcp."
    case airplay = "_airplay._tcp."
    case rdlink = "_rdlink._tcp."
}
