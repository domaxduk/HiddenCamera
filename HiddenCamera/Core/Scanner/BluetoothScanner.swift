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
    
    
    private var devices = [BluetoothDevice]()
    
    weak var delegate: BluetoothScannerDelegate?
    private var isScanning: Bool = false
    
    var authorization: CBManagerAuthorization {
        return CBManager.authorization
    }
    
    var currentState: CBManagerState = .unknown

    
    private override init() {
        super.init()
        self.manager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
    }

    // MARK: - Action
    func startScanning() {
        if let manager, manager.isScanning {
            return
        }
        
        isScanning = true
        if self.currentState == .poweredOn  {
            manager?.scanForPeripherals(withServices: nil,
                                        options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    func stopScanning() {
        if let manager, manager.isScanning {
            manager.stopScan()
            devices.removeAll()
            isScanning = false
        }
    }
}

// MARK: - Handle bluetooth updates
extension BluetoothScanner: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("Bluetooth is unknown.")
        case .resetting:
            print("Bluetooth is resetting.")
        case .unsupported:
            print("Bluetooth is unsupported.")
        case .unauthorized:
            print("Bluetooth is unauthorized.")
        case .poweredOff:
            print("Bluetooth is poweredOff.")
        case .poweredOn:
            if self.isScanning {
                self.startScanning()
            }
            
            print("Bluetooth is poweredOn.")
        @unknown default:
            break
        }
        
        self.currentState = central.state
        self.delegate?.bluetoothScanner?(self, didUpdateState: central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let index = devices.firstIndex(where: { $0.id == peripheral.identifier.uuidString }) {
            let device = devices[index]
            
            if peripheral.name != nil && device.deviceName() == nil {
                devices.remove(at: index)
                devices.insert(device, at: 0)
            }
            
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


