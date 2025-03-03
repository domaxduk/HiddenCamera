//
//  BluetoothDevice.swift
//  HiddenCamera
//
//  Created by Duc apple  on 6/1/25.
//

import Foundation
import CoreBluetooth

class BluetoothDevice: Device {
    @Published var rssiValue: NSNumber
    @Published var per: CBPeripheral?
    private var lastUpdate: Date?
    
    init(id: String, rssiValue: NSNumber, per: CBPeripheral?) {
        self.rssiValue = rssiValue
        self.per = per
        super.init(id: id)
    }
    
    override func deviceName() -> String? {
        return per?.name
    }
    
    override func note() -> String {
        return String(format: "%.2f Meters", meter())
    }
    
    override var imageName: String {
        if let name = deviceName(), let imageName = getImageName(from: name) {
            return imageName
        }
        
        return "ic_device_unknown"
    }
    
    func meter() -> Double {
        let raw = rssiValue.doubleValue
        let power = -59.0
        let ratio = raw * 1.0 / power
        var value = 0.0

        if raw == 0 {
            value = -1.0
        }
        
        if ratio < 1 {
            value = pow(ratio, 10)
        } else {
            let distance = 0.89976 * pow(ratio, 7.7095) + 0.111
            value = distance
        }
        
        return value
    }
    
    func updateRSSI(RSSI: NSNumber) {
        if let lastUpdate, abs(lastUpdate.timeIntervalSinceNow) < 0.5 {
            return
        }
        
        self.rssiValue = RSSI
        self.lastUpdate = Date()
    }
}
