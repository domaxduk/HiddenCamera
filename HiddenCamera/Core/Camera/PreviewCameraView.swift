//
//  CameraView.swift
//  HiddenCamera
//
//  Created by Duc apple  on 31/12/24.
//

import Foundation
import UIKit
import AVFoundation

class PreviewCameraView: UIView {
    var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    init(captureSession: AVCaptureSession!) {
        self.captureSession = captureSession
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = self.layer.bounds
    }
    
    func configCamera() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        self.layer.insertSublayer(previewLayer, at: 0)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension PreviewCameraView: AVCaptureVideoDataOutputSampleBufferDelegate {
    
}
