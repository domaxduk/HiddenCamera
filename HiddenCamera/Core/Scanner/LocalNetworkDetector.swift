//
//  WifiDiscovery.swift
//  DemoDetect
//
//  Created by Duc apple  on 24/12/24.
//

import Foundation
import SwiftUI
import SwiftyPing

protocol LocalNetworkDetectorDelegate: AnyObject {
    func localNetworkDetector(_ detector: LocalNetworkDetector, updateListDevice devices: [LANDevice])
}

class LocalNetworkDetector: NSObject {
    static let shared = LocalNetworkDetector()
    weak var delegate: LocalNetworkDetectorDelegate?
    
    private var devices: [LANDevice] = []

    private var services: [NetService] = []
    private var browsers: [NetServiceBrowser] = []
    private var pingers: [String: SwiftyPing] = [:]
    var isScanning: Bool = false
    
    private var servicesToMonitor: Set<String> = [
        "_device-info._tcp.",
        "_airplay._tcp.",
        "_remotepairing._tcp.",
        "_atc._tcp.",
        "_home-sharing._tcp.",
        "_mediaremotetv._tcp.",
        "_touch-able._tcp.",
        "_apple-mobdev2._tcp.",
        "_rdlink._tcp."
    ]
    
    private func addServiceToMonitor(type: String) {
        if !servicesToMonitor.contains(where: { $0 == type }) {
            self.servicesToMonitor.insert(type)
            print("append type: \(type)")
        }
    }

    func start() {
        if isScanning { return }
        self.isScanning = true
       // startSearchService()
        startPing()
    }
    
    func stopScan() {
        self.isScanning = false
        for pinger in pingers.values {
            pinger.stopPinging()
        }
        
        for browser in browsers {
            browser.stop()
        }
        
        for service in services {
            service.stop()
            service.stopMonitoring()
        }
        
        pingers.removeAll()
        services.removeAll()
        browsers.removeAll()
        devices.removeAll()
    }
    
    private func startSearchService() {
        let browser = NetServiceBrowser()
        browser.delegate = self
        browser.includesPeerToPeer = true
        browser.searchForServices(ofType: "_services._dns-sd._udp", inDomain: "")
        self.browsers.append(browser)
    }
    
    private func startPing() {
        let baseIPAddress = baseIPAddress()
        
        for i in 1...254 {
            let config = PingConfiguration(interval: 1, with: 5)
            let ip = baseIPAddress + "\(i)"

            if let pinger = try? SwiftyPing(host: ip, configuration: config, queue: DispatchQueue.global()) {
                pinger.delegate = self
                pinger.targetCount = 4
                
                do {
                    try pinger.startPinging()
                    self.pingers[ip] = pinger
                } catch {
                    
                }
            }
        }
    }
    
    private func baseIPAddress() -> String {
        let currentIPAddress = NetworkUtils.currentIPAddress()
        let components = currentIPAddress.components(separatedBy: ".")
        var baseIPAddress = ""
        
        for component in components {
            if component == components.last {
                break
            }
            
            baseIPAddress += component + "."
        }
        
        return baseIPAddress
    }
    
    private func sorted(listDevice: [LANDevice]) -> [LANDevice] {
        return listDevice.sorted { first, second in
            let a = first.ipAddress
            let b = second.ipAddress
            if let componentLastA = a?.components(separatedBy: ".").last, let componentLastB = b?.components(separatedBy: ".").last,
               let int1 = Int(componentLastA),  let int2 = Int(componentLastB) {
                return int1 < int2
            }
            
            return true
        }
    }
}

// MARK: - PingDelegate
extension LocalNetworkDetector: PingDelegate {
    func didReceive(response: PingResponse) {
        if let ipAddress = response.ipAddress, !devices.contains(where: { $0.ipAddress == ipAddress }) {
            if response.error == nil {
                let name = NetworkUtils.getHostFromIPAddress(ipAddress: ipAddress)
                let device = LANDevice(ipAddress: ipAddress, name: name, model: nil)
                self.devices.append(device)
                self.mergeDevice()
            }
        }
    }
    
    private func stopPing(_ ip: String) {
        if let key = self.pingers.keys.first(where: { $0 == ip }) {
            self.pingers[key]?.stopPinging()
        }
    }
}

// MARK: - NetServiceBrowserDelegate
extension LocalNetworkDetector: NetServiceBrowserDelegate {
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("did stop search")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("didFind \(service.name)")
        let all = service.name + service.type
        let components = all.components(separatedBy: ".")
        
        let typeComponents = components[0].components(separatedBy: "_")
        var type = ""
        
        for (_, component) in typeComponents.enumerated() {
            if !component.isEmpty {
                type += "_"
                type += component
                type += "."
            }
        }
        
        let domain = components[1]
        
        if domain == "local" {
            let browser = NetServiceBrowser()
            browser.delegate = self
            browser.searchForServices(ofType: type, inDomain: domain + ".")
            self.browsers.append(browser)
            self.services.append(service)
            self.addServiceToMonitor(type: type)
        } else {
            let otherService = NetService(domain: "local.", type: type + domain + ".", name: service.name)
            otherService.startMonitoring()
            otherService.resolve(withTimeout: 10)
            services.append(otherService)
            
            service.startMonitoring()
            service.resolve(withTimeout: 10)
            services.append(service)
          
            
            servicesToMonitor
            .map { serviceType -> NetService in
                let service = NetService(domain: "local.", type: serviceType, name: service.name)
                service.delegate = self
                return service
            }.forEach {
                $0.startMonitoring()
                $0.resolve(withTimeout: 10)
                services.append($0)
            }
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if let index = services.firstIndex(where: { $0 == service }) {
            services.remove(at: index)
        }
    }
}

// MARK: - NetServiceDelegate
extension LocalNetworkDetector: NetServiceDelegate {
    func netServiceDidResolveAddress(_ sender: NetService) {
        addDevice(sender: sender, data: sender.txtRecordData())
    }
    
    func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        addDevice(sender: sender, data: data)
    }
    
    private func addDevice(sender: NetService, data: Data?) {
        var deviceAddresses: [String] = []
        
        if let addresses = sender.addresses {
            for index in 0..<addresses.count {
                if let address = sender.address(index: index)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    deviceAddresses.append(address)
                }
            }
        }
        
        let deviceModel = self.extractModelFromTXTRecord(recordData: data, sender: sender)
        
        if let deviceModel {
            print("model: \(deviceModel)")
        }
        
        var ipAddress: String?
        
        let currentIPAddress = NetworkUtils.currentIPAddress()
        let components = currentIPAddress.components(separatedBy: ".")
        let baseIPAddress = components[0] + "." + components[1]
        
        print("sender \(sender.description) \(sender.hostName) \(baseIPAddress)")

        if let ipv4 = deviceAddresses.first(where: { $0.hasPrefix(baseIPAddress) }) {
            print("sender did find \(ipv4)")
            ipAddress = ipv4
        }
        
        if let device = findExitstingDevice(ip: ipAddress, service: sender) {
            device.updateWithDeviceModel(model: deviceModel, name: sender.name)
            device.addService(service: sender)
            
            if let ipAddress {
                device.ipAddress = ipAddress
            }
        } else {
            let device = LANDevice(ipAddress: ipAddress, name: nil, model: deviceModel)
            device.addService(service: sender)
            devices.append(device)
        }
        
        mergeDevice()
    }
    
    private func mergeDevice() {
        self.deleteDuplicateDevice()
        var listDevice = [String: LANDevice]()
        var listIPDevice = [String: LANDevice]()
        
        for device in devices {
            if let key = device.hostname {
                if listDevice.keys.contains(where: { $0 == key }) {
                    listDevice[key]?.addServices(services: device.services)
                    
                    if let ipAddress = device.ipAddress {
                        listDevice[key]?.ipAddress = ipAddress
                    }
                    
                    if let model = device.model {
                        listDevice[key]?.model = model
                    }
                } else {
                    listDevice[key] = device
                }
            }
        }
        
        for device in self.devices {
            if let key = listDevice.first(where: { $0.value.deviceName() == device.deviceName() })?.key {
                if let model = device.model {
                    listDevice[key]?.model = model
                }
            }
            
            if let key = device.ipAddress {
                if listDevice.values.contains(where: { $0.ipAddress == key}) {
                    continue
                }
                
                if listIPDevice.keys.contains(where: { $0 == key }) {
                    listIPDevice[key]?.addServices(services: device.services)
                    
                    if let model = device.model {
                        listIPDevice[key]?.model = model
                    }
                } else {
                    listIPDevice[key] = device
                }
            }
        }
        
        let totalDevice = Array(listDevice.values) + Array(listIPDevice.values)

        DispatchQueue.main.async {
            self.delegate?.localNetworkDetector(self,
                                                updateListDevice: self.sorted(listDevice: totalDevice).filter({ $0.ipAddress != nil }))
        }
    }
    
    private func deleteDuplicateDevice() {
        // Xoá trùng service
        var listService = [String: Int]()
        for device in self.devices {
            for service in device.services {
                if listService.contains(where: { $0.key == service.full }) {
                    listService[service.full]! += 1
                } else {
                    listService[service.full] = 1
                }
            }
        }
                
        for service in listService {
            if service.value > 1 {
                if let index = devices.firstIndex(where: { device in
                    return device.services.contains(where: { $0.full == service.key }) && device.services.count <= 1
                }) {
                    devices.remove(at: index)
                    print("delete: \(service.key)")
                }
            }
        }
        
        // Xoá trùng ip
        var listIP = [String: Int]()
        for device in self.devices {
            if let ipAddress = device.ipAddress {
                if listIP.contains(where: { $0.key == ipAddress }) {
                    listIP[ipAddress]! += 1
                } else {
                    listIP[ipAddress] = 1
                }
            }
        }
        
        for ip in listIP {
            if ip.value > 1 {
                if let index = devices.firstIndex(where: { $0.ipAddress == ip.key && $0.services.count < 1 }) {
                    devices.remove(at: index)
                }
            }
        }
    }
        
    private func findExitstingDevice(ip: String?, service: NetService) -> LANDevice? {
        return devices.first(where: { device in
            if let ipAdress = device.ipAddress, let ip {
                return ip == ipAdress
            }
            
            
            for deviceService in device.services {
                if deviceService.name == service.name {
                    return true
                }
                
                if let hostname = service.hostName, let deviceHostname = deviceService.hostname, hostname == deviceHostname {
                    return true
                }
            }
            
            return false
        })
    }
    
    private func extractModelFromTXTRecord(recordData: Data?, sender: NetService) -> String? {
        guard let recordData else { return nil }
        let txtDictionary = NetService.dictionary(fromTXTRecord: recordData)
        
        guard let modelData = txtDictionary["model"], let model = String(data: modelData, encoding: .utf8) else {
            return nil
        }
        
        return model.isEmpty ? nil : model
    }
}
