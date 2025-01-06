//
//  BluetoothScanner.swift
//  HiddenCamera
//
//  Created by Duc apple  on 6/1/25.
//

import UIKit
import CoreBluetooth
import RxSwift

fileprivate struct Const {
    static let bluetoothTimeout: TimeInterval = 5
}

@objc protocol BluetoothScannerDelegate: AnyObject {
    func bluetoothScanner(_ scanner: BluetoothScanner, updateListDevice devices: [BluetoothDevice])
    @objc optional func bluetoothScanner(_ scanner: BluetoothScanner, didUpdateState state: CBManagerState)
}

class BluetoothScanner: NSObject, ObservableObject {
    static var shared = BluetoothScanner()
    private var manager: CBCentralManager?
    private var currentState: CBManagerState = .unknown
    
    private var devices = [BluetoothDevice]()
    
    weak var delegate: BluetoothScannerDelegate?
    private var isScanning: Bool = false
        
    // MARK: - Action
    private func configManager() {
        manager = CBCentralManager(delegate: self, queue: nil,
                                   options: options())
    }
    
    private func options() -> [String : Any] {
        var options = [String:Any]()
        
        let deviceInfoServiceUUID = ["1801", "180A", "1810", "1820", "180F", "180D"].map({ CBUUID(string: $0) })

        options[CBCentralManagerOptionShowPowerAlertKey] = false
        options[CBCentralManagerScanOptionAllowDuplicatesKey] = true
        options[CBCentralManagerScanOptionSolicitedServiceUUIDsKey] = deviceInfoServiceUUID

        if #available(iOS 16.0, *) {
            options[CBCentralManagerOptionDeviceAccessForMedia] = true
        }
        
        return options
    }
    
    func startScanning() {
        if manager == nil {
            configManager()
        }
        
        stopScanning()
        isScanning = true
        
        if self.currentState == .poweredOn  {
            manager?.scanForPeripherals(withServices: nil,
                                        options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    func stopScanning() {
        manager?.stopScan()
        self.devices.removeAll()
        self.isScanning = false
    }
}

// MARK: - Handle bluetooth updates
extension BluetoothScanner: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let previousState = self.currentState
        self.currentState = central.state
        
        if previousState == .unknown && self.isScanning {
            self.startScanning()
        }
        
        self.delegate?.bluetoothScanner?(self, didUpdateState: central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let device = devices.first(where: { $0.id == peripheral.identifier.uuidString }) {
            device.peripheral = peripheral
            device.rssi = RSSI
        } else {
            let device = BluetoothDevice(id: peripheral.identifier.uuidString, rssi: RSSI, peripheral: peripheral)
            
            if device.deviceName() != nil {
                self.devices.insert(device, at: 0)
            } else {
                self.devices.append(device)
            }
            
            if let deviceName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
                print("Tên thiết bị: \(deviceName)")
            }
            
           
        }
        
//        print("ADRESSSSSsss")
//        for data in advertisementData {
//            print("\(data.key) \(data.value)")
//        }
        var tooltip = ""
        if let mfgData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            tooltip += "Mfg Data:\t\t0x\(mfgData.base64EncodedString())\n"
                    if mfgData[0] == 0xd9 && mfgData[1] == 0x01 {
                        let uidData = mfgData[6..<14]
                        tooltip += "UID:\t\t\t\(uidData.base64EncodedString())\n"
                    }
                }
        
        if !tooltip.isEmpty {
            print(tooltip)
        }
        
        self.delegate?.bluetoothScanner(self, updateListDevice: devices)
    }
    
    func extractSerialNumber(advertisementData: [String : Any]) -> String? {
        guard let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data else {
            return nil
        }
        
        let value = data[2...5]
        var stringValue = ""
        for byte in value {
            stringValue = stringValue + String(byte, radix: 16)
        }
        return stringValue
    }
}


