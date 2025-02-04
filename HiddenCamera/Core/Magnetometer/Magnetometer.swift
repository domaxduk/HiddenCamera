import Foundation
import CoreMotion
import AVFoundation
import CoreLocation
import UIKit

public protocol MagnetometerLocationDelegate: AnyObject {
    func didFailWithError(error: Error)
    func getUpdatedData(magnet:Magnetometer)
}

public final class Magnetometer: NSObject, CLLocationManagerDelegate{
    public static let shared = Magnetometer()
    public weak var locationDelegate: MagnetometerLocationDelegate?
    private let motionManager = CMMotionManager()
    
    private var xValue: Double = 0
    private var yValue: Double = 0
    private var zValue: Double = 0
    private var magneticStrengthValue: Double = 0
    private let queue = OperationQueue()
    
    var isAvailable: Bool {
        return motionManager.isMagnetometerAvailable
    }
    
    func start() {
        if motionManager.isMagnetometerAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1 // Set your desired update interval
            motionManager.showsDeviceMovementDisplay = true
            
            motionManager.startDeviceMotionUpdates(using: .xTrueNorthZVertical, to: queue) { data, error in
                if let magneticField = data?.magneticField.field {
                    self.MagneticStrength(field: magneticField)
                }
            }
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    //Internal function x,y,z and magnetic strength value
    internal func MagneticStrength(field: CMMagneticField) {
        let magnitude = field.magnitude
        
        DispatchQueue.main.async {
            self.setValueX(field.x)
            self.setValueY(field.y)
            self.setValueZ(field.z)
            self.setmagneticStrengthValue(magnitude)
        }
        
        locationDelegate?.getUpdatedData(magnet: self)
    }
}

//MARK: - Extend the class
extension Magnetometer {
    public var x: Double {
        return xValue
    }
    
    public var y: Double {
        return yValue
    }
    
    
    public var z: Double {
        return zValue
    }
    
    public var magneticStrength: Double {
        return magneticStrengthValue
    }
    
    fileprivate func setValueX(_ newValue: Double) {
        xValue = newValue
    }
    
    fileprivate func setValueY(_ newValue: Double) {
        yValue = newValue
    }
    
    fileprivate func setValueZ(_ newValue: Double) {
        zValue = newValue
    }
    
    fileprivate func setmagneticStrengthValue(_ newValue: Double) {
        magneticStrengthValue = newValue
    }
}

extension CMMagneticField {
    var magnitude: Double {
        return sqrt(x * x + y * y + z * z)
    }
}
