//
//  CameraDetectorViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 3/1/25.
//

import UIKit
import RxSwift
import AVFoundation
import SwiftUI

struct CameraDetectorViewModelInput: InputOutputViewModel {
    var back = PublishSubject<()>()
    var didTapRecord = PublishSubject<()>()
    var didTapGallery = PublishSubject<()>()
}

struct CameraDetectorViewModelOutput: InputOutputViewModel {
    var updatePreview = PublishSubject<UIImage?>()
}

struct CameraDetectorViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var previewResult = PublishSubject<URL>()
    var gallery = PublishSubject<()>()
}

final class CameraDetectorViewModel: BaseViewModel<CameraDetectorViewModelInput, CameraDetectorViewModelOutput, CameraDetectorViewModelRouting> {
    @AppStorage("theFirstUseCameraDetector") var isTheFirst: Bool = true
    @Published var isRecording: Bool = false
    @Published var seconds: Int = 0
    @Published var showIntro: Bool = true
    @Published var captureSession: AVCaptureSession
    
    private var writer: AssetWriter?
    private var timer: Timer?
    
    private var cameraOutput: AVCaptureVideoDataOutput!
    private var audioOutput: AVCaptureAudioDataOutput!
    
    private var needToStart: Bool = false
    private var startRecordingTimeOnSampleBuffer: CMTime!
    
    override init() {
        self.captureSession = AVCaptureSession()
        super.init()
        configCaptureSession()
        initAssetWriter()
        print("screen size: \(UIScreen.main.bounds.size)")
    }
    
    override func configInput() {
        super.configInput()
        input.back.subscribe(onNext: { [weak self] _ in
            self?.routing.stop.onNext(())
        }).disposed(by: self.disposeBag)
        
        input.didTapRecord.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
           
            DispatchQueue.main.async {
                self.isTheFirst = false
                self.isRecording.toggle()
                self.invalidateTimer()
                
                if self.isRecording {
                    self.startRecord()
                } else {
                    self.stopRecord()
                }
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapGallery.subscribe(onNext: { [weak self] _ in
            self?.routing.gallery.onNext(())
        }).disposed(by: self.disposeBag)
    }
    
    private func initAssetWriter() {
        let outputFileURL = FileManager.documentURL().appendingPathComponent("record.mp4")
        let outputSize = UIScreen.main.bounds.size.scale(3.0)
        self.writer = AssetWriter(outputURL: outputFileURL, fileType: .mp4, outputSize: outputSize)
    }
    
    private func configCaptureSession() {
        guard let videoDevice = AVCaptureDevice.default(for: .video), let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            return
        }
                
        captureSession.sessionPreset = .high
        
        if captureSession.canAddInput(videoDeviceInput) {
            captureSession.addInput(videoDeviceInput)
        }
        
        // Thiết lập output
        cameraOutput = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(cameraOutput) {
            captureSession.addOutput(cameraOutput)
            
            // Thiết lập queue cho output
            let queue = DispatchQueue(label: "cameraQueue")
            cameraOutput.setSampleBufferDelegate(self, queue: queue)
        }
        
        let audioOutput = AVCaptureAudioDataOutput()
        let outputSampleBufferQueue = DispatchQueue(label: "outputAudioSampleBufferQueue")
        audioOutput.setSampleBufferDelegate(self, queue: outputSampleBufferQueue)
        if self.captureSession.canAddOutput(audioOutput) {
            self.captureSession.addOutput(audioOutput)
            self.audioOutput = audioOutput
        }
    }
    
    func startCamera() {
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.seconds += 1
            }
        })
    }
    
    let context = CIContext()
    
    private func invalidateTimer() {
        timer?.invalidate()
        seconds = 0
    }
    
    // MARK: - Record
    private func startRecord() {
        self.startTimer()
        self.needToStart = true
    }
    
    private func stopRecord() {
        self.seconds = 0
        self.writer?.finishWriting(completion: { [weak self] error in
            guard let self else { return }
            if error == nil {
                if let outputFileURL = self.writer?.outputURL {
                    let resultURL = FileManager.documentURL().appendingPathComponent("\(UUID().uuidString).mp4")
                    try? FileManager.default.copyItem(at: outputFileURL, to: resultURL)
                    self.routing.previewResult.onNext(resultURL)
                }
            } else {
                print("error: \(error!)")
            }
        })
    }
}

// MARK: - GET
extension CameraDetectorViewModel {
    func durationDescription() -> String {
        let hour = seconds / 3600
        let minute = (seconds - hour * 3600) / 60
        let second = seconds - hour * 3600 - minute * 60
        return String(format: "%02d:%02d:%02d", hour, minute, second)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraDetectorViewModel: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let videoPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        var ciImage = CIImage(cvPixelBuffer: videoPixelBuffer).rotate(radians: -CGFloat.pi / 2)
        ciImage = ciImage.transformed(by: CGAffineTransform(translationX: -ciImage.extent.minX, y: -ciImage.extent.minY))
        
        if needToStart {
            self.startRecordingTimeOnSampleBuffer = time
            self.writer?.startWriting(atSourceTime: self.startRecordingTimeOnSampleBuffer ?? .zero)
            self.needToStart = false
        }
        
        let screenSize = UIScreen.main.bounds.size
        let currentSize = ciImage.image.size
        let targetSize = screenSize.scale(currentSize.height / screenSize.height)
        let rect: CGRect = .init(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        ciImage = ciImage.cropped(to: rect)
        
        let image = ciImage.image
                
        if isRecording {
            self.writer?.append(pixelBuffer: ciImage.buffer ?? videoPixelBuffer, withPresentationTime: time)
        }
                
        DispatchQueue.main.async {
            self.output.updatePreview.onNext(image)
        }
    }
}

