//
//  AppColor.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import Foundation
import SwiftUI

enum AppColor: Int {
    case main = 0x0090FF
    case light03 = 0xF0F0F0
    case light06 = 0xD9D9D9
}


extension Color {
    static func app(_ type: AppColor) -> Color {
        return Color(rgb: type.rawValue)
    }
    
    static let clearInteractive = Color.white.opacity(0.001)
}


