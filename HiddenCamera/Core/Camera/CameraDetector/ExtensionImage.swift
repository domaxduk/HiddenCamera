//
//  ExtensionImage.swift
//  Runner
//
//  Created by Hien Nguyen on 19/4/24.
//

import Foundation
import UIKit

// MARK: - Extension UIImage
extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
            let rotatedSize = CGRect(origin: .zero, size: size)
                .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
                .integral.size
            UIGraphicsBeginImageContext(rotatedSize)
            if let context = UIGraphicsGetCurrentContext() {
                let origin = CGPoint(x: rotatedSize.width / 2.0,
                                     y: rotatedSize.height / 2.0)
                context.translateBy(x: origin.x, y: origin.y)
                context.rotate(by: radians)
                draw(in: CGRect(x: -origin.y, y: -origin.x,
                                width: size.width, height: size.height))
                let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                return rotatedImage ?? self
            }

            return self
        }
    
    func resize(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
    
    subscript (x: Int, y: Int) -> UIColor? {
        if x < 0 || x > Int(size.width) || y < 0 || y > Int(size.height) {
            return nil
        }

        let provider = self.cgImage!.dataProvider
        let providerData = provider!.data
        let data = CFDataGetBytePtr(providerData)

        let numberOfComponents = 4
        let pixelData = ((Int(size.width) * y) + x) * numberOfComponents

        let r = CGFloat(data![pixelData]) / 255.0
        let g = CGFloat(data![pixelData + 1]) / 255.0
        let b = CGFloat(data![pixelData + 2]) / 255.0
        let a = CGFloat(data![pixelData + 3]) / 255.0

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
