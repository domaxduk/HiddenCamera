//
//  BluetoothDevice.swift
//  HiddenCamera
//
//  Created by Duc apple  on 6/1/25.
//

import Foundation
import CoreBluetooth

class BluetoothDevice: Device {
    @Published var rssi: NSNumber
    @Published var peripheral: CBPeripheral?
    private var lastUpdate: Date?
    
    init(id: String, rssi: NSNumber, peripheral: CBPeripheral?) {
        self.rssi = rssi
        self.peripheral = peripheral
        super.init(id: id)
    }
    
    override func deviceName() -> String? {
        return peripheral?.name
    }
    
    override func note() -> String {
        return String(format: "%.2f Meters", meterDistance())
    }
    
    override var imageName: String {
        if let name = deviceName(), let imageName = getImageName(from: name) {
            return imageName
        }
        
        return "ic_device_unknown"
    }
    
    func meterDistance() -> Double {
        let rawRSSI = rssi.doubleValue
        let txPower = -59.0
        var distanceValue = 0.0
        if (rawRSSI == 0) {
            distanceValue = -1.0
        }
        
        let ratio = rawRSSI * 1.0 / txPower
        if (ratio < 1.0) {
            distanceValue = pow(ratio,10)
        } else {
            let distance =  (0.89976) * pow(ratio,7.7095) + 0.111;
            distanceValue = distance
        }
        
        return distanceValue
    }
    
    func updateRSSI(RSSI: NSNumber) {
        if let lastUpdate, abs(lastUpdate.timeIntervalSinceNow) < 0.5 {
            return
        }
        
        self.rssi = RSSI
        self.lastUpdate = Date()
    }
}
