//
//  WifiDiscovery.swift
//  DemoDetect
//
//  Created by Duc apple  on 24/12/24.
//

import Foundation
import SwiftUI
import SwiftyPing

class LocalNetworkDetector: NSObject, ObservableObject {
    static let shared = LocalNetworkDetector()
    
    @Published @objc dynamic var devices: [Device] = []
    @objc dynamic var sortDescriptors: [NSSortDescriptor] = [.init(key: "desc", ascending: true)]

    private var services: [NetService] = []
    private var browsers: [NetServiceBrowser] = []
    private var pingers: [String: SwiftyPing] = [:]
    
    private var servicesToMonitor = [
        "_device-info._tcp.",
        "_airplay._tcp.",
        "_remotepairing._tcp.",
        "_atc._tcp.",
        "_home-sharing._tcp.",
        "_mediaremotetv._tcp.",
        "_touch-able._tcp.",
        "_apple-mobdev2._tcp."
    ]

    func start() {
        let browser = NetServiceBrowser()
        browser.delegate = self
        browser.includesPeerToPeer = true
        browser.searchForServices(ofType: "_services._dns-sd._udp", inDomain: "")
        browsers.append(browser)
        
        for i in 1...254 {
            let config = PingConfiguration(interval: 1, with: 5)
            let ip = "192.168.1.\(i)"
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
    
    private func sortList() {
        self.devices.sort { first, second in
            let a = first.ipAddress
            let b = second.ipAddress
            if let componentLastA = a.components(separatedBy: ".").last, let componentLastB = b.components(separatedBy: ".").last,
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
            if let error = response.error {
//                if error == .requestError && !self.pingers.isEmpty {
//                    if let key = self.pingers.keys.first(where: { $0 == ipAddress }) {
//                        self.pingers[key]?.stopPinging()
//                    }
//                }
            } else {
                let name = NetworkUtils.getHostFromIPAddress(ipAddress: ipAddress)
                let device = Device(ipAddress: ipAddress, title: name ?? "", model: "")
                self.devices.append(device)
                sortList()
            }
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
        let all = service.name + service.type
        let components = all.components(separatedBy: ".")
        
        let typeComponents = components[0].components(separatedBy: "_")
        var type = ""
        
        for (index, component) in typeComponents.enumerated() {
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
            print("search: \(type)")
            self.servicesToMonitor.append(type)
            self.services.append(service)
        } else {
            let otherService = NetService(domain: "local.", type: type + domain + ".", name: service.name)
            otherService.resolve(withTimeout: 10)
            otherService.startMonitoring()
            services.append(otherService)
            
            service.resolve(withTimeout: 10)
            services.append(service)
          
            
            servicesToMonitor
            .map { serviceType -> NetService in
                print("check " + domain + " " + type + " " + service.name + " " + (service.hostName ?? ""))
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
        addDevice(sender: sender)
    }
    
    private func addDevice(sender: NetService) {
        
      //  print("============RESOLVE ADDRESS: \(sender.domain)\(sender.type)\(sender.name)=========================")

        var deviceAddresses: [String] = []
        
        if let addresses = sender.addresses {
           print("ADDRESS: \(sender.domain)\(sender.type)\(sender.name)=========================")
            for index in 0..<addresses.count {
                if let address = sender.address(index: index) {
                    deviceAddresses.append(address)
                    print(address)
                }
            }
        }
        
        let deviceModel = self.extractModelFromTXTRecord(recordData: sender.txtRecordData(), sender: sender)
        
        print("service name: \(sender.domain)\(sender.type)\(sender.name) \(String(describing: sender.hostName))")
        var ipAddress: String?
        
        if let ipv4 = deviceAddresses.first(where: { $0.contains("192.168.1.")}) {
            ipAddress = ipv4
        }
        
        if let exitstingDevice = devices.first(where: { $0.ipAddress == ipAddress || ($0.hostName != nil && $0.hostName == sender.hostName) }) {
            exitstingDevice.updateWithDeviceModel(model: deviceModel)
            exitstingDevice.title = sender.name
            
            if exitstingDevice.hostName == nil {
                exitstingDevice.hostName = sender.hostName
            }
            
            exitstingDevice.addService(service: sender)
        } else if let ipAddress {
            let device = Device(ipAddress: ipAddress, title: sender.name, model: deviceModel)
            device.hostName = sender.hostName
            device.addService(service: sender)
            devices.append(device)
        } else {
            let device = Device(ipAddress: "", title: sender.name, model: deviceModel)
            device.hostName = sender.hostName
            device.addService(service: sender)
            devices.append(device)
        }
    }
    
    private func extractModelFromTXTRecord(recordData: Data?, sender: NetService) -> String? {
        guard let recordData else { return nil }
        let txtDictionary = NetService.dictionary(fromTXTRecord: recordData)
//        print("TXT Record: \(sender.domain)\(sender.type)\(sender.name)=========================")
//        for (key, value) in txtDictionary {
//            if let string = String(data: value, encoding: .utf8) {
//                print("key-\(key): \(string)")
//            }
//        }
        
        guard let modelData = txtDictionary["model"], let model = String(data: modelData, encoding: .utf8) else {
            return nil
        }
        
        return model
    }
}
