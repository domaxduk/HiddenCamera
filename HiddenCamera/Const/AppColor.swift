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
    case light01 = 0xFCFCFC
    case light03 = 0xF0F0F0
    case light04 = 0xE8E8E8
    case light06 = 0xD9D9D9
    case light09 = 0x8D8D8D
    case light10 = 0x838383
    case light11 = 0x646464
    case light12 = 0x202020
    case warning = 0xEE404C
    case safe = 0x00BA00
    
    static let warningColor = Color(rgb: 0xEE404C)
    static let safeColor = Color(rgb: 0x00BA00)
}


extension Color {
    static func app(_ type: AppColor) -> Color {
        return Color(rgb: type.rawValue)
    }
    
    static let clearInteractive = Color.white.opacity(0.001)
}


