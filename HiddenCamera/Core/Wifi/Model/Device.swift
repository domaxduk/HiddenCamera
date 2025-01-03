//
//  Device.swift
//  DemoDetect
//
//  Created by Duc apple  on 24/12/24.
//

import Foundation
import UIKit

private let deviceInfo = NSDictionary(contentsOf: Bundle.main.url(forResource: "macModels", withExtension: "plist")!)!
private let mobileDevices: [MobileDevice] = {
    let data = try! Data(contentsOf: Bundle.main.url(forResource: "iphoneModels", withExtension: "json")!)
    let decoder = JSONDecoder()
    return try! decoder.decode([MobileDevice].self, from: data)
}()

func deviceDescriptionForModel(model: String) -> String? {
    guard let info = deviceInfo[model] as? NSDictionary, let richDescription = info["Detail"] as? String else {
        return nil
    }
    return richDescription
}

class RawDevice: NSObject, ObservableObject {
    let ipAddress: String
    
    init(ipAddress: String) {
        self.ipAddress = ipAddress
    }
}

class Device: RawDevice {
    let id: String
    
    @Published var services: [DeviceService]
    @Published var hostName: String? = nil
    @Published var localHost: String? = nil
    @Published var title: String
    @Published var desc: String
    @Published var image: UIImage?
    @Published var richDescription: String?
    
    func updateDeviceName(name: String) {
        self.title = name
    }
    
    func name() -> String {
        title.replacingOccurrences(of: "realName_", with: "")
            .replacingOccurrences(of: ".local.", with: "")
            .replacingOccurrences(of: "-", with: " ")
    }
    
    func isRealName() -> Bool {
        return title.contains("realName_")
    }
    
    init(ipAddress: String, services: [DeviceService] = [], title: String, model: String?) {
        self.id = UUID().uuidString
        self.services = services
        self.title = title
        self.desc = ""
        self.image = nil
        
        
        if let model {
            let mobileDeviceReference = mobileDevices.first(where: { $0.target?.lowercased() == model.lowercased() })
            if let richDescription = deviceDescriptionForModel(model: model) {
                self.richDescription = richDescription
            } else if let mobileDeviceModel = mobileDeviceReference?.product_type, let richDescription = deviceDescriptionForModel(model: mobileDeviceModel) {
                self.richDescription = richDescription
            } else {
                self.richDescription = "Model: \(model)"
            }
        }
        
        super.init(ipAddress: ipAddress)
    }
    
    func updateWithDeviceModel(model: String?) {
        guard let model else { return }
        self.desc = ""
        self.image = nil
        
        let mobileDeviceReference = mobileDevices.first(where: { $0.target?.lowercased() == model.lowercased() })
        if let richDescription = deviceDescriptionForModel(model: model) {
            self.richDescription = richDescription
        } else if let mobileDeviceModel = mobileDeviceReference?.product_type, let richDescription = deviceDescriptionForModel(model: mobileDeviceModel) {
            self.richDescription = richDescription
        } else {
            self.richDescription = nil
        }
    }
    
    func addService(service: NetService) {
        let fullService = service.domain + service.type + service.name
        
        if let exitedService = services.first(where: { $0.full == fullService }) {
            exitedService.txtRecord = service.txtRecordData()
        } else {
            let object = DeviceService(domain: service.domain, type: service.type, name: service.name, txtRecord: service.txtRecordData())
            services.append(object)
        }
    }
}

struct MobileDevice: Codable {
    let target: String?
    let target_type: String?
    let target_variant: String?
    let platform: String?
    let product_type: String?
    let product_description: String?
    let compatible_device_fallback: String?
}
