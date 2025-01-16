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
import FirebaseAnalytics

struct InfraredCameraViewModelInput: InputOutputViewModel {
    var back = PublishSubject<()>()
    var toggleFlash = PublishSubject<()>()
    var didTapRecord = PublishSubject<()>()
    var didTapGallery = PublishSubject<()>()
    var didTapNext = PublishSubject<()>()
    
    var didTapRemoveAd = PublishSubject<()>()
    var didTapContinueAds = PublishSubject<()>()
}

struct InfraredCameraViewModelOutput: InputOutputViewModel {
    var updatePreview = PublishSubject<UIImage?>()
}

struct InfraredCameraViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var previewResult = PublishSubject<CameraResultItem>()
    var gallery = PublishSubject<()>()
    var nextTool = PublishSubject<()>()
    var showError = PublishSubject<String>()
}

final class InfraredCameraViewModel: BaseViewModel<InfraredCameraViewModelInput, InfraredCameraViewModelOutput, InfraredCameraViewModelRouting> {
    @AppStorage("theFirstUseInfraredCamera") var isTheFirst: Bool = true
    @Published var isRecording: Bool = false
    @Published var filterColor: Color = .red
    @Published var seconds: Int = 0
    @Published var showIntro: Bool = true
    @Published var captureSession: AVCaptureSession
    @Published var isTurnFlash: Bool = false
    @Published var previewGalleryImage: UIImage?
    
    @Published var isShowingCameraDialog: Bool = false
    @Published var isShowingTimeLimitDialog: Bool = false

    private var writer: AssetWriter
    private var timer: Timer?
    
    private var cameraOutput: AVCaptureVideoDataOutput!
    private var audioOutput: AVCaptureAudioDataOutput!
    
    private var needToStart: Bool = false
    private var needToStop: Bool = false
    private var isLimitTime: Bool = false
    private var needToPreviewResult: Bool = false

    let scanOption: ScanOptionItem?
    var lastItem: CameraResultItem?
    private let dao = CameraResultDAO()

    init(scanOption: ScanOptionItem?) {
        self.scanOption = scanOption
        self.captureSession = AVCaptureSession()
        
        let outputFileURL = FileManager.documentURL().appendingPathComponent("record.mp4")
        let outputSize = UIScreen.main.bounds.size.scale(3.0)
        self.writer = AssetWriter(outputURL: outputFileURL, fileType: .mp4, outputSize: outputSize)
        
        super.init()
        configCaptureSession()

        if !Permission.grantedCamera {
            self.isShowingCameraDialog = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(getPreviewGalleryImage), name: .updateCameraHistory, object: nil)
        getPreviewGalleryImage()
        
        if let scanOption {
            switch scanOption.type {
            case .option:
                Analytics.logEvent("feature_option_ir", parameters: nil)
            case .full:
                if scanOption.isThreadAfterIntro {
                    Analytics.logEvent("first_ir", parameters: nil)
                }
            default: break
            }
        }
        
        self.writer.delegate = self
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
            if isRecording {
                self.needToStop = true
                return
            }
            
            // Nếu đạt đến giới hạn 30s và không phải user premium
            if isLimitTime && !UserSetting.isPremiumUser {
                self.needToPreviewResult = false
                self.isShowingTimeLimitDialog = true
                return
            }
            
            // Nếu scan option
            if let scanOption {
                if scanOption.suspiciousResult.contains(where: { $0.key == .infraredCamera }) && !UserSetting.isPremiumUser {
                    SubscriptionViewController.open { }
                } else {
                    prepareToRecord()
                }
                
                return
            }
            
            // Nếu là tool thường
            if UserSetting.canUsingFeature(.ifCamera) {
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
        
        input.didTapRemoveAd.subscribe(onNext: { [unowned self] in
            SubscriptionViewController.open { [weak self] in
                if UserSetting.isPremiumUser {
                    self?.isShowingTimeLimitDialog = false
                    self?.routeToResultAfterRecord()
                }
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapContinueAds.subscribe(onNext: { [unowned self] in
            self.routeToResultAfterRecord()
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
            self.needToStart = true
        }
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
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.seconds += 1
                
                if !UserSetting.isPremiumUser && self.seconds >= 30 {
                    self.needToStop = true
                    self.isLimitTime = true
                }
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
}

// MARK: - AssetWriterDelegate
extension InfraredCameraViewModel: AssetWriterDelegate {
    func assetWrite(_ writer: AssetWriter, didFinishRecording url: URL, error: (any Error)?) {
        if let error {
            DispatchQueue.main.async {
                self.routing.showError.onNext(error.localizedDescription)
                self.invalidateTimer()
            }
            
            return
        }
        
        let resultURL = FileManager.documentURL().appendingPathComponent("\(UUID().uuidString).mp4")
        try? FileManager.default.copyItem(at: url, to: resultURL)
        
        let item = CameraResultItem(id: UUID().uuidString, fileName: resultURL.lastPathComponent, type: .infrared)
        self.lastItem = item
        
        DispatchQueue.main.async {
            self.needToPreviewResult = true
            CameraManager.configFlash(isOn: false)
            self.isTurnFlash = false
            
            if self.isLimitTime {
                self.isShowingTimeLimitDialog = true
            } else {
                self.routeToResultAfterRecord()
            }
            
            self.invalidateTimer()
        }
    }
    
    private func routeToResultAfterRecord() {
        if let lastItem, needToPreviewResult {
            DispatchQueue.main.async {
                self.routing.previewResult.onNext(lastItem)
            }
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
            print("need to start")
            DispatchQueue.main.async {
                self.startTimer()
                self.writer.startWriting()
                self.isRecording = true
                self.needToStart = false
                
                if self.scanOption == nil {
                    UserSetting.increaseUsedFeature(.ifCamera)
                }
            }
        }
        
        if isRecording {
            if needToStop {
                DispatchQueue.main.async {
                    self.needToStop = false
                    self.timer?.invalidate()
                    self.writer.finishWriting()
                    self.isRecording = false
                }
                return
            }
            
            self.writer.append(pixelBuffer: ciImage.buffer ?? videoPixelBuffer, withPresentationTime: time)
        }
                
        DispatchQueue.main.async {
            self.output.updatePreview.onNext(image)
        }
    }
}

// MARK: - GET
extension InfraredCameraViewModel {
    func showBackButton() -> Bool {
        if let scanOption, scanOption.isThreadAfterIntro {
            return scanOption.isEnd && !isRecording
        }
        
        return !isRecording
    }
    
    func durationDescription() -> String {
        let hour = seconds / 3600
        let minute = (seconds - hour * 3600) / 60
        let second = seconds - hour * 3600 - minute * 60
        return String(format: "%02d:%02d:%02d", hour, minute, second)
    }
    
    func uiFilterColor() -> UIColor {
        switch self.filterColor {
        case .red: return UIColor(red: 238, green: 64, blue: 76, alpha: 1)
        case .blue: return UIColor(red: 51, green: 157, blue: 255, alpha: 1)
        case .green: return UIColor(red: 0, green: 186, blue: 0, alpha: 1)
        case .yellow: return UIColor(red: 255, green: 186, blue: 23, alpha: 1)
        default: return .clear
        }
    }
    
    private func canHandleRecord() -> Bool {
        if UserSetting.isPremiumUser || scanOption != nil {
            return true
        }
        
        return UserSetting.canUsingFeature(.ifCamera)
    }
}
