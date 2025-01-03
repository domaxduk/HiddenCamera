//
//  NetworkUtils.swift
//  DemoDetect
//
//  Created by Duc apple  on 24/12/24.
//

import Foundation
import SystemConfiguration.CaptiveNetwork
import CoreLocation

class NetworkUtils {
    // MARK: - Get Netmask
    static func getNetmask() -> String? {
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&interfaces) == 0 {
            var temp_addr = interfaces
            
            // Iterate through all interfaces
            while temp_addr != nil {
                let sa_type = temp_addr?.pointee.ifa_addr?.pointee.sa_family
                if sa_type == UInt8(AF_INET) || sa_type == UInt8(AF_INET6) {
                    let name = String(cString: (temp_addr?.pointee.ifa_name)!)
                    
                    // For IPv4 (AF_INET)
                    if sa_type == UInt8(AF_INET) {
                        let sockaddfr_in = temp_addr?.pointee.ifa_netmask?.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0 }
                        if let sockaddr_in = sockaddfr_in {
                            let addr = String(cString: inet_ntoa(sockaddr_in.pointee.sin_addr))
                            if name == "en0" {
                                return addr
                            }
                        }
                    }
                }
                
                temp_addr = temp_addr?.pointee.ifa_next
            }
            
            // Giải phóng bộ nhớ
            freeifaddrs(interfaces)
        }
        
        return nil
    }
    
    // MARK: - Get current IP
    static func currentIPAddress() -> String {
        var wifiAddress: String? = nil
        var cellAddress: String? = nil
        
        // Retrieve the current interfaces
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&interfaces) == 0 {
            var temp_addr = interfaces
            
            // Iterate through all interfaces
            while temp_addr != nil {
                let sa_type = temp_addr?.pointee.ifa_addr?.pointee.sa_family
                if sa_type == UInt8(AF_INET) || sa_type == UInt8(AF_INET6) {
                    let name = String(cString: (temp_addr?.pointee.ifa_name)!)
                    
                    // For IPv4 (AF_INET)
                    if sa_type == UInt8(AF_INET) {
                        // Cast to sockaddr_in for IPv4
                        let sockaddr_in = temp_addr?.pointee.ifa_addr?.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0 }
                        if let sockaddr_in = sockaddr_in {
                            let addr = String(cString: inet_ntoa(sockaddr_in.pointee.sin_addr))
                            
                            if name == "en0" { // WiFi interface
                                wifiAddress = addr
                            } else if name == "pdp_ip0" { // Cellular interface
                                cellAddress = addr
                            }
                        }
                    }
                    
                    // For IPv6 (AF_INET6)
                    if sa_type == UInt8(AF_INET6) {
                        // Cast to sockaddr_in6 for IPv6
                        let sockaddr_in6 = temp_addr?.pointee.ifa_addr?.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { $0 }
                        if let sockaddr_in6 = sockaddr_in6 {
                            var addr = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
                            if let ip = inet_ntop(AF_INET6, &sockaddr_in6.pointee.sin6_addr, &addr, socklen_t(INET6_ADDRSTRLEN)) {
                                let ipString = String(cString: ip)
                                if name == "en0" { // WiFi interface
                                    wifiAddress = ipString
                                } else if name == "pdp_ip0" { // Cellular interface
                                    cellAddress = ipString
                                }
                            }
                        }
                    }
                }
                
                temp_addr = temp_addr?.pointee.ifa_next
            }
            
            // Giải phóng bộ nhớ
            freeifaddrs(interfaces)
        }
        
        // Return the first available IP address (wifiAddress > cellAddress)
        return wifiAddress ?? cellAddress ?? "0.0.0.0"
    }
    
    // MARK: - Get Wifi Name
    // phải cho quyền location thì mới lấy được tên của wifi
    static func getWifiName() -> String? {
        guard let interfaces = CNCopySupportedInterfaces() as NSArray? else {
            return nil
        }
        
        for interface in interfaces {
            guard let interfaceName = interface as? String,
                  let networkInfo = CNCopyCurrentNetworkInfo(interfaceName as CFString) as? [String: Any] else {
                continue
            }
            
            if let ssid = networkInfo[kCNNetworkInfoKeySSID as String] as? String {
                return ssid
            }
        }
        
        return nil
    }
    
    // MARK: - Get Hostname from IP
    static func getHostFromIPAddress(ipAddress: String) -> String? {
        var hostName: String? = nil
        var hints = addrinfo()
        hints.ai_flags = 0
        hints.ai_family = AF_UNSPEC // It will resolve both IPv4 and IPv6
        hints.ai_socktype = SOCK_STREAM // Prefer stream sockets (e.g., TCP)
        
        var results: UnsafeMutablePointer<addrinfo>?
        
        let error = getaddrinfo(ipAddress, nil, &hints, &results)
        if error != 0 {
            print("Could not get any info for the address: \(String(cString: gai_strerror(error)))")
            return nil
        }
        
        var ptr = results
        
        while let addressInfo = ptr {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            
            let error = getnameinfo(addressInfo.pointee.ai_addr, addressInfo.pointee.ai_addrlen, &hostname, socklen_t(hostname.count), nil, 0, 0)
            
            if error != 0 {
                // If we fail to resolve the hostname, continue to the next address in the list
                ptr = addressInfo.pointee.ai_next
                continue
            } else {
                // Successfully found a hostname
                hostName = String(cString: hostname)
                break
            }
        }
        
        // Free the memory allocated by getaddrinfo
        freeaddrinfo(results)
        
        if hostName == ipAddress {
            return nil
        }
        
        return hostName
    }
    
    static func isIpAddressValid(ipAddress: String) -> Bool {
        var pin = in_addr()
        let success = inet_aton(ipAddress, &pin)
        return success == 1
    }
}

