//
//  AssetWriter.swift
//  HiddenCamera
//
//  Created by Duc apple  on 2/1/25.
//

import Foundation
import AVFoundation

public final class AssetWriter {
    public private(set) var outputURL: URL
    public private(set) var fileType: AVFileType
    public private(set) var outputSize: CGSize
    public private(set) var isRecording: Bool

    private var assetWriter: AVAssetWriter?
    private var videoWriterInput: AVAssetWriterInput!
    private var videoAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    private var requestMediaDataQueue: DispatchQueue!

    public init(outputURL: URL, fileType: AVFileType, outputSize: CGSize) {
        self.outputURL = outputURL
        self.fileType = fileType
        self.outputSize = outputSize
        self.isRecording = false
        self.requestMediaDataQueue = DispatchQueue(label: "Request media data queue")
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
    public func prepare() {
        self.removeOutputFile()
        self.initWriter()
        self.configAudioSession()
    }

    public func startWriting(atSourceTime sourceTime: CMTime) {
        prepare()
        assert(self.assetWriter != nil, "Must call prepare before starting writing")
        self.removeOutputFile()
        self.isRecording = true
        self.assetWriter?.startWriting()
        self.assetWriter?.startSession(atSourceTime: sourceTime)
        print("Start writing")
    }

    public func finishWriting(completion: ((Error?) -> Void)? = nil) {
        self.isRecording = false
        self.assetWriter?.finishWriting {
            self.videoWriterInput.markAsFinished()
            DispatchQueue.main.async {
                completion?(self.assetWriter?.error)
                self.assetWriter = nil
            }
        }
    }

    public func cancelWriting() {
        self.isRecording = true
        self.assetWriter?.finishWriting {
            self.videoWriterInput.markAsFinished()
            self.removeOutputFile()
            self.assetWriter = nil
        }
    }

    public func append(pixelBuffer: CVPixelBuffer, withPresentationTime presentationTime: CMTime) {
        guard self.assetWriter?.status == .writing else {
            return
        }

        self.videoAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
    }

    public func makePixelBuffer() -> CVPixelBuffer? {
        guard let pool = self.videoAdaptor.pixelBufferPool else {
            return nil
        }

        var pixelBuffer: CVPixelBuffer! = nil
        CVPixelBufferPoolCreatePixelBuffer(nil, pool, &pixelBuffer)
        return pixelBuffer
    }

    public func removeOutputFile() {
        try? FileManager.default.removeItem(at: self.outputURL)
    }
}
