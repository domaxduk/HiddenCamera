//
//  InfraredCameraViewModel.swift
//  HiddenCamera
//
//  Created by Duc apple  on 27/12/24.
//

import UIKit
import RxSwift
import SwiftUI
import AVFoundation
import SakuraExtension

struct InfraredCameraViewModelInput: InputOutputViewModel {
    var back = PublishSubject<()>()
    var toggleFlash = PublishSubject<()>()
    var didTapRecord = PublishSubject<()>()
    var didTapGallery = PublishSubject<()>()
    var didTapNext = PublishSubject<()>()
}

struct InfraredCameraViewModelOutput: InputOutputViewModel {
    var updatePreview = PublishSubject<UIImage?>()
}

struct InfraredCameraViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var previewResult = PublishSubject<CameraResultItem>()
    var gallery = PublishSubject<()>()
    var nextTool = PublishSubject<()>()
}

final class InfraredCameraViewModel: BaseViewModel<InfraredCameraViewModelInput, InfraredCameraViewModelOutput, InfraredCameraViewModelRouting> {
    @AppStorage("theFirstUseInfraredCamera") var isTheFirst: Bool = true
    @Published var isRecording: Bool = false
    @Published var filterColor: Color = .red
    @Published var seconds: Int = 0
    @Published var showIntro: Bool = true
    @Published var captureSession: AVCaptureSession
    @Published var isTurnFlash: Bool = false
    @Published var isShowingCameraDialog: Bool = false
    @Published var previewGalleryImage: UIImage?

    private var writer: AssetWriter?
    private var timer: Timer?
    
    private var cameraOutput: AVCaptureVideoDataOutput!
    private var audioOutput: AVCaptureAudioDataOutput!
    
    private var needToStart: Bool = false
    private var startRecordingTimeOnSampleBuffer: CMTime!
    let scanOption: ScanOptionItem?
    var lastItem: CameraResultItem?
    private let dao = CameraResultDAO()

    init(scanOption: ScanOptionItem?) {
        self.scanOption = scanOption
        self.captureSession = AVCaptureSession()
        super.init()
        configCaptureSession()
        initAssetWriter()
        
        if !Permission.grantedCamera {
            self.isShowingCameraDialog = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(getPreviewGalleryImage), name: .updateCameraHistory, object: nil)
        getPreviewGalleryImage()
    }
    
    @objc private func getPreviewGalleryImage() {
        let item = dao.getAll().filter({ $0.type == .infrared }).last
        
        if item != nil {
            self.previewGalleryImage = item?.thumbnailImage ?? UIImage()
        }
    }
    
    override func configInput() {
        super.configInput()
        input.back.subscribe(onNext: { [weak self] _ in
            self?.routing.stop.onNext(())
        }).disposed(by: self.disposeBag)
        
        input.toggleFlash.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            self.isTurnFlash.toggle()
            CameraManager.configFlash(isOn: isTurnFlash)
        }).disposed(by: self.disposeBag)
        
        input.didTapRecord.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            if scanOption != nil || isRecording || UserSetting.canUsingFeature(.aiDetector) {
                prepareToRecord()
            } else {
                SubscriptionViewController.open { }
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapGallery.subscribe(onNext: { [weak self] _ in
            self?.routing.gallery.onNext(())
        }).disposed(by: self.disposeBag)
        
        input.didTapNext.subscribe(onNext: { [weak self] _ in
            self?.routing.nextTool.onNext(())
        }).disposed(by: self.disposeBag)
    }
    
    private func prepareToRecord() {
        if !Permission.grantedCamera {
            withAnimation {
                self.isShowingCameraDialog = true
            }
            
            return
        }
        
        DispatchQueue.main.async {
            self.isTheFirst = false
            self.isRecording.toggle()
            self.invalidateTimer()
            
            if self.isRecording {
                self.startRecord()
                UserSetting.increaseUsedFeature(.ifCamera)
            } else {
                self.stopRecord()
            }
        }
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
                    
                    let item = CameraResultItem(id: UUID().uuidString, fileName: resultURL.lastPathComponent, type: .infrared)
                    self.routing.previewResult.onNext(item)
                    self.lastItem = item
                }
            } else {
                print("error: \(error!)")
            }
        })
    }
}

// MARK: - GET
extension InfraredCameraViewModel {
    func durationDescription() -> String {
        let hour = seconds / 3600
        let minute = (seconds - hour * 3600) / 60
        let second = seconds - hour * 3600 - minute * 60
        return String(format: "%02d:%02d:%02d", hour, minute, second)
    }
    
    func uiFilterColor() -> UIColor {
        switch self.filterColor {
        case .red: return UIColor(red: 238, green: 64, blue: 76, alpha: 1)
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        default: return .clear
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension InfraredCameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let videoPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        var ciImage = CIImage(cvPixelBuffer: videoPixelBuffer).rotate(radians: -CGFloat.pi / 2)
        ciImage = ciImage.transformed(by: CGAffineTransform(translationX: -ciImage.extent.minX, y: -ciImage.extent.minY))

        if filterColor != .clear {
            if let newImage = ciImage.colorized(with: uiFilterColor()) {
                ciImage = newImage
            }
        }
        
        let screenSize = UIScreen.main.bounds.size
        let currentSize = ciImage.image.size
        let targetSize = screenSize.scale(currentSize.height / screenSize.height)
        let rect: CGRect = .init(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        ciImage = ciImage.cropped(to: rect)
        
        let image = ciImage.image
        
        if needToStart {
            self.startRecordingTimeOnSampleBuffer = time
            self.writer?.startWriting(atSourceTime: self.startRecordingTimeOnSampleBuffer ?? .zero)
            self.needToStart = false
        } else if isRecording {
            self.writer?.append(pixelBuffer: ciImage.buffer ?? videoPixelBuffer, withPresentationTime: time)
        }
                
        DispatchQueue.main.async {
            self.output.updatePreview.onNext(image)
        }
    }
}
