//
//  Device.swift
//  DemoDetect
//
//  Created by Duc apple  on 24/12/24.
//

import Foundation
import UIKit
import SwiftUI
import dnssd
import Network

private let deviceInfo = NSDictionary(contentsOf: Bundle.main.url(forResource: "macModels", withExtension: "plist")!)!



func deviceDescriptionForModel(model: String) -> String? {
    guard let info = deviceInfo[model] as? NSDictionary, let richDescription = info["Detail"] as? String else {
        return nil
    }
    return richDescription
}

class RawDevice: NSObject, ObservableObject {
    var ipAddress: String?
    
    init(ipAddress: String?) {
        self.ipAddress = ipAddress
    }
}

class Device: RawDevice {
    let id: String
    
    @Published var name: String?
    @Published var model: String?
    @Published var services: [DeviceService]

    var imageName: String {
        if let ipAddress, let number = ipAddress.components(separatedBy: ".").last, number == "1" {
            return "ic_device_router"
        }

        if let model, let imageName = getImageName(from: model) {
            return imageName
        }
        
        if let deviceName = deviceName(), let imageName = getImageName(from: deviceName) {
            return imageName
        }
        
        return "ic_device_unknown"
    }
    
    private func getImageName(from key: String) -> String? {
        let compareText = key.lowercased()
        
        if compareText.contains("airpod") {
            return "ic_device_airpod"
        }
        
        if compareText.contains("tv") {
            return "ic_device_tv"
        }
        
        if compareText.contains("macbook") || compareText.contains("macmini") || compareText.contains("pc") {
            return "ic_device_laptop"
        }
        
        if compareText.contains("phone") || compareText.contains("redmi") {
            return "ic_device_phone"
        }
        
        return nil
    }
    
    func updateDeviceName(name: String) {
        self.name = name
    }
    
    func deviceName() -> String? {
        if let name {
            return name
        }
        
        if let service = services.first(where: { service in  return ServiceType.allCases.contains(where: { $0.rawValue == service.type })}) {
            return service.name
        }
        
        if let hostname {
            return hostname.components(separatedBy: ".").first
        }
        
        return nil
    }
    
    var hostname: String? {
        return services.first(where: { $0.hostname != nil })?.hostname
    }
    
    init(ipAddress: String?, services: [DeviceService] = [], name: String?, model: String?) {
        self.id = UUID().uuidString
        self.name = name
        self.services = services
        self.model = model
        super.init(ipAddress: ipAddress)
        
        if let appleDevice = self.getAppleDevice(from: model)  {
            self.model = appleDevice.product_description
        }
    }
    
    func updateWithDeviceModel(model: String?, name: String?) {
        guard let model else { return }
        self.model = model
        
        if let name {
            self.name = name
        }
        
        if let appleDevice = getAppleDevice(from: model)  {
            self.model = appleDevice.product_description
        }
    }
    
    func addService(service: NetService) {
        let fullService = service.domain + service.type + service.name
        
        if let exitedService = services.first(where: { $0.full == fullService }) {
            exitedService.txtRecord = service.txtRecordData()
            exitedService.hostname = service.hostName
        } else {
            let object = DeviceService(domain: service.domain, type: service.type, name: service.name, txtRecord: service.txtRecordData(), hostname: service.hostName)
            services.append(object)
        }
    }
    
    func addServices(services: [DeviceService]) {
        for service in services {
            if !self.services.contains(where: { $0.full == service.full }) {
                self.services.append(service)
            }
        }
        
    }
    
    var listService: String {
        var value = ""
        for service in services {
            value += service.full + "\n"
        }
        
        return value
    }
    
    private func getAppleDevice(from model: String?) -> AppleDevice? {
        guard let data = try? Data(contentsOf: Bundle.main.url(forResource: "iphoneModels", withExtension: "json")!), 
                let listDevice = try? JSONDecoder().decode([AppleDevice].self, from: data),
                let model else {
            return nil
        }
        
        return listDevice.first(where: { $0.target?.lowercased() == model.lowercased() })
    }
    
    var keystore: [String] {
        return [self.ipAddress, self.hostname, self.deviceName()].compactMap({ $0 })
    }
}

#Preview {
    WifiScannerView(viewModel: WifiScannerViewModel())
}
