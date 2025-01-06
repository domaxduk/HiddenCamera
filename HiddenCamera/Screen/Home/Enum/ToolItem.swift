//
//  ToolItem.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import Foundation
import SwiftUI

enum ToolItem: CaseIterable {
    case bluetoothScanner
    case wifiScanner
    case cameraDetector
    case magnetic
    case infraredCamera
    case metalSensorDetector
    
    var icon: String {
        switch self {
        case .bluetoothScanner:
            "ic_tool_bluetooth"
        case .cameraDetector:
            "ic_tool_camera_detector"
        case .infraredCamera:
            "ic_tool_infrared_camera"
        case .magnetic:
            "ic_tool_magnetic"
        case .metalSensorDetector:
            "ic_tool_metal_sensor_detector"
        case .wifiScanner:
            "ic_tool_wifi"
        }
    }
    
    var name: String {
        switch self {
        case .bluetoothScanner:
            "Bluetooth Locator"
        case .cameraDetector:
            "AI Camera Scanner"
        case .infraredCamera:
            "IR Vision Camera"
        case .magnetic:
            "Magnetic sensor"
        case .metalSensorDetector:
            "Metal sensor detector"
        case .wifiScanner:
            "Wifi Devices Finder"
        }
    }
    
    var color: Color {
        switch self {
        case .bluetoothScanner:
            Color.app(.main)
        case .cameraDetector:
            Color(rgb: 0x9747FF)
        case .infraredCamera:
            Color(rgb: 0x0CDC08)
        case .magnetic:
            Color(rgb: 0xFF4242)
        case .metalSensorDetector:
            Color(rgb: 0xE418E8)
        case .wifiScanner:
            Color(rgb: 0xFFA63D)
        }
    }
}
