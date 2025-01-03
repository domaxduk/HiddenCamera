//
//  DataProcesser.swift
//
//
//  Created by Developer on 4/16/24.
//

import Foundation
import UIKit
import Accelerate.vImage
import AVFoundation
import onnxruntime_objc

enum OrtModelError: Error {
    case error(_ message: String)
}

protocol DataProcessDelegate: AnyObject {
    func dataProcess(_ object: DataProcesser, time: CMTime, ciImage: CIImage, boxes: [BoundingBox])
}

final class DataProcesser {
    weak var delegate: DataProcessDelegate?
    static let batchSize: Int = 1
    static let inputSize: Int = 640
    static let pixelSize: Int = 3
    static let fileName = "best"
    static let confidentThreshold: Float = 0.1
    static let iouThreshould: Float = 0.1
    var isLoading: Bool = false
    
    // ORT inference session and environment object for performing inference on the given ssd model
    private var session: ORTSession? = nil
    private var env: ORTEnv? = nil
    
    func loadModel() {
        guard let modelPath = Bundle.main.path(forResource: DataProcesser.fileName, ofType: "onnx") else {
            print("Failed to get model file path with name: \(DataProcesser.fileName).")
            return
        }
        
        // creating ORT session
        do {
            // Start the ORT inference environment and specify the options for session
            self.env = try ORTEnv(loggingLevel: ORTLoggingLevel.verbose)
            
            // Create the ORTSession
            session = try ORTSession(env: env!, modelPath: modelPath, sessionOptions: nil)
        } catch let error as NSError{
            print("Failed to create ORTSession")
            print(error)
            return
        }
    }
    
    // MARK: - Public
    public func outputsToNPMSPredictions(shape: [Int], outputs: [Float]) -> [BoundingBox] {
        let data = ShapeData(shape: shape, data: outputs)
        var results = [BoundingBox]()
        
        if let columns = data.getColCount() {
            for colIndex in 0..<columns {
                let xCenter = data[0, 0, colIndex]!
                let yCenter = data[0, 1, colIndex]!
                let width = data[0, 2, colIndex]!
                let height = data[0, 3, colIndex]!
                let score = data[0, 4, colIndex]!
                
                if score > DataProcesser.confidentThreshold {
                    let box = BoundingBox(
                        x1: max(0, xCenter - width / 2),
                        y1: max(0, yCenter - height / 2),
                        x2: min(Float(DataProcesser.inputSize - 1), xCenter + width / 2),
                        y2: min(Float(DataProcesser.inputSize - 1), yCenter + height / 2),
                        cx: xCenter, cy: yCenter, w: width, h: height, cnf: score)
                    
                    results.append(box)
                }
            }
        }
        
        if results.isEmpty { return [] }
        return processNMS(listBox: results) ?? []
    }
    
    // MARK: - Convert
    public func resizeImage(_ image: UIImage?) -> UIImage? {
        let size: CGSize = .init(width: 640, height: 640)
        return image?.resize(to: size)
    }
    
    func bitmapToFloatBuffer(image: CGImage?) -> [Float]? {
        guard let image,
              let provider = image.dataProvider,
              let providerData = provider.data,
              let data = CFDataGetBytePtr(providerData) else {
            return nil
        }
        
        let capacity = DataProcesser.pixelSize * DataProcesser.inputSize * DataProcesser.inputSize
        let buffer = UnsafeMutableBufferPointer<Float>.allocate(capacity: capacity * Float.exponentBitCount)
        let area = DataProcesser.inputSize * DataProcesser.inputSize
        let numberOfComponents = 4
        
        for i in 0..<DataProcesser.inputSize {
            for j in 0..<DataProcesser.inputSize {
                let idx = ((Int(image.width) * i) + j) * numberOfComponents
                
                let r = CGFloat(data[idx]) / 255.0
                let g = CGFloat(data[idx + 1]) / 255.0
                let b = CGFloat(data[idx + 2]) / 255.0
                
                buffer[DataProcesser.inputSize * i + j] = Float(r)
                buffer[DataProcesser.inputSize * i + j + area] = Float(g)
                buffer[DataProcesser.inputSize * i + j + area * 2] = Float(b)
            }
        }
        
        return Array(buffer)
    }
    
    // MARK: - Private
    //hàm tính độ trùng khớp
    private func calculateIoU(box1: BoundingBox, box2: BoundingBox) -> Float {
        let x1 = max(box1.x1, box2.x1)
        let y1 = max(box1.y1, box2.y1)
        let x2 = min(box1.x2, box2.x2)
        let y2 = min(box1.y2, box2.y2)
        
        let intersectionArea = max(0.0, x2 - x1) * max(0.0, y2 - y1)
        let box1Area = box1.w * box1.h
        let box2Area = box2.w * box2.h
        return intersectionArea / (box1Area + box2Area - intersectionArea)
    }
    
    // tính toán độ trùng khớp box
    private func processNMS(listBox: [BoundingBox]) -> [BoundingBox]? {
        var sortedBoxes = listBox.sorted(by: { $0.cnf > $1.cnf })
        var selectedBoxes = [BoundingBox]()
        
        while !sortedBoxes.isEmpty {
            let first = sortedBoxes.removeFirst()
            selectedBoxes.append(first)
            
            var index: Int = 0
            while index < sortedBoxes.count {
                let nextBox = sortedBoxes[index]
                let iou = calculateIoU(box1: first, box2: nextBox)
                
                if iou >= DataProcesser.iouThreshould {
                    sortedBoxes.remove(at: index)
                } else {
                    index += 1
                }
            }
        }
        
        if selectedBoxes.isEmpty {
            return nil
        }
        
        for item in selectedBoxes {
            print(item)
        }
        
        return selectedBoxes
    }
    
    func imageData(image: UIImage) -> NSMutableData? {
        // Get the raw data from the image
        guard let cgImage = image.cgImage,
              let provider = cgImage.dataProvider,
              let providerData = provider.data,
              let data = CFDataGetBytePtr(providerData) else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let area = width * height
        let numberOfComponents = 4 // RGBA format
        
        // Create a buffer for the processed pixel data (R, G, B channels)
        let capacity = area * 3
        var buffer = [Float](repeating: 0.0, count: capacity)
        
        // Process pixels and convert to floats in RGBA channels
        for i in 0..<height {
            for j in 0..<width {
                let idx = (i * width + j) * numberOfComponents
                
                let r = CGFloat(data[idx]) / 255.0
                let g = CGFloat(data[idx + 1]) / 255.0
                let b = CGFloat(data[idx + 2]) / 255.0
                
                let bufferIndex = (i * width + j)
                buffer[bufferIndex] = Float(r)
                buffer[bufferIndex + area] = Float(g)
                buffer[bufferIndex + area * 2] = Float(b)
            }
        }
        
        // Return a mutable data object containing the processed pixel data
        let rowBytes = width * 3 * MemoryLayout<Float>.size
        return NSMutableData(bytes: buffer, length: rowBytes * height)
    }
    
    // MARK: - Handle
    func imageProcess(ciImage: CIImage, time: CMTime) {
        self.isLoading = true
        var boxes = [BoundingBox]()
        do {
            guard let session,
                  let image = resizeImage(ciImage.image),
                  let imageData = imageData(image: image) else {
                return
            }
            
            let inputTensor = try ORTValue(tensorData: imageData, elementType: .float, shape: [1, 3, 640, 640])
            let inputName = try session.inputNames().first!
            
            let resultTensor = try session.run(withInputs: [inputName: inputTensor], outputNames: ["output0"], runOptions: nil)
            
            guard let outputs = resultTensor["output0"] else {
                return
            }
            
            // get shape of the tensor data
            let shape = try outputs.tensorTypeAndShapeInfo().shape.map({ Int(truncating: $0) })
            let rawOutputData = try outputs.tensorData() as Data
            
            // convert bytedata to float array
            let floatValues = rawOutputData.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) -> [Float] in
                let floatBuffer = buffer.bindMemory(to: Float.self)
                return Array(floatBuffer)
            }
            
            boxes = outputsToNPMSPredictions(shape: shape, outputs: floatValues)
            
            print("[PROCESS] boxes \(String(describing: boxes))")
            
            DispatchQueue.main.async {
                self.delegate?.dataProcess(self, time: time, ciImage: ciImage, boxes:  boxes)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        self.isLoading = false
    }
}
