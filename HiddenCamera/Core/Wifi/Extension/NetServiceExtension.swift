//
//  NetServiceExtension.swift
//  DemoDetect
//
//  Created by Duc apple  on 26/12/24.
//

import Foundation

// MARK: - NetService Extension
extension NetService {
    func address(index: Int) -> String? {
        guard let addresses else { return nil }
        let data = addresses[index]
        
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))

        // Use withUnsafeBytes to safely access the raw buffer
        data.withUnsafeBytes { rawBuffer in
            // Ensure the rawBuffer is a pointer to a sockaddr
            guard let pointer = rawBuffer.baseAddress?.assumingMemoryBound(to: sockaddr.self) else {
                return
            }
            
            // Use getnameinfo to resolve the address
            guard getnameinfo(pointer, socklen_t(data.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                return
            }
        }
        
        return String(cString: hostname)
    }
}
