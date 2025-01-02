//
//  CameraManager.swift
//  HiddenCamera
//
//  Created by Duc apple  on 31/12/24.
//

import Foundation
import AVFoundation

class CameraManager {
    static func configFlash(isOn: Bool) {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video), device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = isOn ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    }
    
    static func isFlashAvailable() -> Bool {
        return AVCaptureDevice.default(for: AVMediaType.video)?.isFlashAvailable ?? false
    }
}
