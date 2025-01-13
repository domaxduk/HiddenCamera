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
import SakuraExtension

struct CameraDetectorViewModelInput: InputOutputViewModel {
    var back = PublishSubject<()>()
    var didTapRecord = PublishSubject<()>()
    var didTapGallery = PublishSubject<()>()
    var didTapNext = PublishSubject<()>()
}

struct CameraDetectorViewModelOutput: InputOutputViewModel {
    
}

struct CameraDetectorViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var previewResult = PublishSubject<CameraResultItem>()
    var gallery = PublishSubject<()>()
    var nextTool = PublishSubject<()>()
}

struct Model {
    var time: CMTime
    var ciImage: CIImage
}

final class CameraDetectorViewModel: BaseViewModel<CameraDetectorViewModelInput, CameraDetectorViewModelOutput, CameraDetectorViewModelRouting> {
    @AppStorage("theFirstUseCameraDetector") var isTheFirst: Bool = true
    @Published var isRecording: Bool = false
    @Published var seconds: Int = 0
    @Published var showIntro: Bool = true
    @Published var captureSession: AVCaptureSession
    @Published var boxes = [BoundingBox]()
    @Published var isShowingCameraDialog: Bool = false
    @Published var previewGalleryImage: UIImage?

    private let dataProcess = DataProcesser()
    var lastItem: CameraResultItem?
    
    private var writer: AssetWriter?
    private var timer: Timer?
    
    private var isReady: Bool = false
    private var detectObject: Model? {
        didSet {
            if let detectObject {
                DispatchQueue.global(qos: .userInitiated).async {
                    self.dataProcess.imageProcess(ciImage: detectObject.ciImage, time: detectObject.time)
                }
            }
        }
    }
    
    private var cameraOutput: AVCaptureVideoDataOutput!
    private var needToStart: Bool = false
    private var startRecordingTimeOnSampleBuffer: CMTime!
    private var currentCIImage: CIImage?
    
    let scanOption: ScanOptionItem?
    
    init(scanOption: ScanOptionItem?) {
        self.isTheFirst = true
        self.captureSession = AVCaptureSession()
        self.scanOption = scanOption
        super.init()
        configCaptureSession()
        initAssetWriter()
        print("screen size: \(UIScreen.main.bounds.size)")
        configDataProcesser()
         
        if !Permission.grantedCamera {
            self.isShowingCameraDialog = true
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(getPreviewGalleryImage), name: .updateCameraHistory, object: nil)
        getPreviewGalleryImage()
    }
    
    @objc private func getPreviewGalleryImage() {
        let item = CameraResultDAO().getAll().filter({ $0.type == .aiDetector }).last
        
        if item != nil {
            self.previewGalleryImage = item?.thumbnailImage ?? UIImage()
        }
    }
    
    private func configDataProcesser() {
        self.dataProcess.loadModel()
        self.dataProcess.delegate = self
    }
    
    override func configInput() {
        super.configInput()
        input.back.subscribe(onNext: { [weak self] _ in
            self?.routing.stop.onNext(())
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
            self.cleanData()
            
            if self.isRecording {
                self.startRecord()
                UserSetting.increaseUsedFeature(.aiDetector)
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
    
    // MARK: - Record
    private func startRecord() {
        self.startTimer()
        self.needToStart = true
    }
    
    private func stopRecord() {        
        self.writer?.finishWriting(completion: { [weak self] error in
            guard let self else { return }
            if error == nil {
                if let outputFileURL = self.writer?.outputURL {
                    let resultURL = FileManager.documentURL().appendingPathComponent("\(UUID().uuidString).mp4")
                    try? FileManager.default.copyItem(at: outputFileURL, to: resultURL)
                    
                    let item = CameraResultItem(id: UUID().uuidString, fileName: resultURL.lastPathComponent, type: .aiDetector)
                    self.routing.previewResult.onNext(item)
                    self.lastItem = item
                }
            } else {
                print("error: \(error!)")
            }
            
            self.cleanData()
        })
    }
    
    private func cleanData() {
        self.timer?.invalidate()
        self.seconds = 0
        self.boxes = []
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
extension CameraDetectorViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
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
        }
        
        if isRecording {
            let screenSize = UIScreen.main.bounds.size
            let currentSize = ciImage.image.size
            let targetSize = screenSize.scale(currentSize.height / screenSize.height)
            ciImage = ciImage.cropToCenter(size: targetSize)
            ciImage = ciImage.transformed(by: CGAffineTransform(translationX: -ciImage.extent.minX, y: -ciImage.extent.minY))
            self.currentCIImage = ciImage
            
            if isReady {
                print("detect camera")
                self.isReady = false
                self.detectObject = Model(time: time, ciImage: ciImage)
            } else {
                print("append camera")
                let result = drawOnCIImage(backgroundCIImage: ciImage, boxes: boxes)
                
                if let buffer = result?.buffer {
                    self.writer?.append(pixelBuffer: buffer, withPresentationTime: time)
                }
            }
            
            if needToStart {
                self.needToStart = false
                self.isReady = true
            } 
        }
    }
}

// MARK: - DataProcessDelegate
extension CameraDetectorViewModel: DataProcessDelegate {
    func dataProcess(_ object: DataProcesser, time: CMTime, ciImage: CIImage, boxes: [BoundingBox]) {
        self.isReady = true
        
        DispatchQueue.main.async {
            self.boxes = boxes
            self.objectWillChange.send()
        }
    }
    
    func drawOnCIImage(backgroundCIImage: CIImage, boxes: [BoundingBox]) -> CIImage? {
        // 1. Convert CIImage to CGImage
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(backgroundCIImage, from: backgroundCIImage.extent) else {
            return nil
        }
        
        // 2. Create a new drawing context with the correct scale factor
        UIGraphicsBeginImageContextWithOptions(backgroundCIImage.extent.size, false, 1.0)
        
        // 3. Get the current CGContext
        let drawingContext = UIGraphicsGetCurrentContext()
        
        // 4. Flip the context vertically to match UIImage's top-left origin system
        drawingContext?.translateBy(x: 0, y: backgroundCIImage.extent.height)
        drawingContext?.scaleBy(x: 1.0, y: -1.0)
        
        // 5. Draw the CGImage onto the context (this will respect the coordinate system)
        drawingContext?.draw(cgImage, in: CGRect(origin: .zero, size: backgroundCIImage.extent.size))
        
        // 6. Adjust the positions of the bounding boxes and overlay image
        let width = backgroundCIImage.extent.width
        let height = backgroundCIImage.extent.height
        
        let overlayImage = UIImage(named: "ic_frame_camera")
        
        for box in boxes {
            // Convert bounding box dimensions to pixels
            let w = CGFloat(box.w) * width
            let h = CGFloat(box.h) * height
            let centerX = CGFloat(box.cx) * width - w / 2
            let centerY = CGFloat(box.cy) * height - h / 2
            
            let flippedCenterY = backgroundCIImage.extent.height - centerY - h  // Correct for flipped Y
            let rect = CGRect(origin: CGPoint(x: centerX, y: flippedCenterY), size: CGSize(width: w, height: h))
            overlayImage?.draw(in: rect)
        }
        
        // 7. Get the new image from the context
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        // 8. End the context and return the new CIImage
        UIGraphicsEndImageContext()
        
        return CIImage(image: newImage)
    }
}
