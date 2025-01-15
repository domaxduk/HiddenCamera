//
//  AssetWriter.swift
//  HiddenCamera
//
//  Created by Duc apple  on 2/1/25.
//

import Foundation
import AVFoundation

protocol AssetWriterDelegate: AnyObject {
    func assetWrite(_ writer: AssetWriter, didFinishRecording url: URL, error: Error?)
}

public final class AssetWriter: NSObject {
    public private(set) var outputURL: URL
    public private(set) var fileType: AVFileType
    public private(set) var outputSize: CGSize
    weak var delegate: AssetWriterDelegate?

    private var assetWriter: AVAssetWriter?
    private var videoWriterInput: AVAssetWriterInput!
    private var videoAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    private var requestMediaDataQueue: DispatchQueue!
    private var isRecording: Bool = false

    public init(outputURL: URL, fileType: AVFileType, outputSize: CGSize) {
        self.outputURL = outputURL
        self.fileType = fileType
        self.outputSize = outputSize
        self.requestMediaDataQueue = DispatchQueue(label: "Request media data queue")
        super.init()
    }

    private func initWriter() {
        do {
            self.assetWriter = try AVAssetWriter(outputURL: self.outputURL, fileType: self.fileType)

            let videoSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: self.outputSize.width,
                AVVideoHeightKey: self.outputSize.height
            ]
            self.videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
            self.videoWriterInput.expectsMediaDataInRealTime = true
            self.assetWriter?.add(self.videoWriterInput)

            let pixelBufferAttributes: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                kCVPixelBufferWidthKey as String: self.outputSize.width,
                kCVPixelBufferHeightKey as String: self.outputSize.height,
                kCVPixelBufferCGImageCompatibilityKey as String: true,
                kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
            ]

            self.videoAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.videoWriterInput, sourcePixelBufferAttributes: pixelBufferAttributes)
        } catch {
            print("Init writer error: \(error)")
        }
    }

    private func configAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothA2DP, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Config audio session in \(#file) error: \(error)")
        }
    }

    // MARK: - Public action
    private func prepare() {
        self.removeOutputFile()
        self.initWriter()
        self.configAudioSession()
    }
    
    public func startWriting() {
        self.isRecording = true
    }

    public func finishWriting() {
        print("stop record")
        self.isRecording = false
       
        if let assetWriter, assetWriter.status == .writing {
            assetWriter.finishWriting { [weak self] in
                guard let self else { return }
                self.videoWriterInput.markAsFinished()
                self.delegate?.assetWrite(self, didFinishRecording: outputURL, error: self.assetWriter?.error)
                self.assetWriter = nil
            }
        }
    }

    public func append(pixelBuffer: CVPixelBuffer, withPresentationTime presentationTime: CMTime) {
        guard isRecording else {
            return
        }
        
        if assetWriter == nil {
            prepare()
        }
        
        if let assetWriter {
            switch assetWriter.status {
            case .unknown:
                if assetWriter.startWriting() {
                    assetWriter.startSession(atSourceTime: presentationTime)
                    
                    if videoWriterInput.isReadyForMoreMediaData  {
                        self.videoAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                    }
                }
            case .writing:
                if videoWriterInput.isReadyForMoreMediaData  {
                    self.videoAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                }
            case .completed:
                print("[AssetWriter] completed")
            case .failed:
                print("[AssetWriter] failed")

            case .cancelled:
                print("[AssetWriter] cancelled")

            @unknown default:
                break
            }
        }
    }
    
    public func removeOutputFile() {
        try? FileManager.default.removeItem(at: self.outputURL)
    }
}
