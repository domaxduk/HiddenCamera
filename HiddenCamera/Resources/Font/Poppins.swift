//
//  Poppins.swift
//
//

import Foundation
import UIKit
import SwiftUI

enum Poppins {
    case bold
    case medium
    case regular
    case semibold
    case italic
    case boldItalic
    
    func font(size: CGFloat) -> UIFont {
        switch self {
        case .bold:
            return UIFont(name: "Poppins-Bold", size: size)!
        case .medium:
            return UIFont(name: "Poppins-Medium", size: size)!
        case .regular:
            return UIFont(name: "Poppins-Regular", size: size)!
        case .semibold:
            return UIFont(name: "Poppins-SemiBold", size: size)!
        case .italic:
            return UIFont(name: "Poppins-Italic", size: size)!
        case .boldItalic:
            return UIFont(name: "Poppins-BoldItalic", size: size)!
        }
    }
    
    func font(size: CGFloat) -> Font {
        switch self {
        case .bold:
            return Font.custom("Poppins-Bold", size: size)
        case .medium:
            return Font.custom("Poppins-Medium", size: size)
        case .regular:
            return Font.custom("Poppins-Regular", size: size)
        case .semibold:
            return Font.custom("Poppins-SemiBold", size: size)
        case .italic:
            return Font.custom("Poppins-Italic", size: size)
        case .boldItalic:
            return Font.custom("Poppins-BoldItalic", size: size)
        }
    }
    
    static func font(weight: CGFloat, size: CGFloat) -> UIFont {
        switch weight {
        case 500: return Poppins.medium.font(size: size)
        case 600: return Poppins.semibold.font(size: size)
        case 700: return Poppins.bold.font(size: size)
        default:
            return Poppins.regular.font(size: size)
        }
    }
}
