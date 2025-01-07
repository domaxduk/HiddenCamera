//
//  NetworkManager.swift
//  HiddenCamera
//
//  Created by Duc apple  on 7/1/25.
//

import Foundation
import Network

class NetworkManager {
    static let shared = NetworkManager()
    private var isConnecting = false
    
    var path: NWPath?
    
    func isConnectedNetwork() -> Bool {
        return isConnecting
    }
    
    func config() {
        let pathMonitor = NWPathMonitor()
        pathMonitor.pathUpdateHandler = { path in
            self.path = path
            self.isConnecting = path.status == .satisfied
            NotificationCenter.default.post(name: .didChangeNetworkStatus, object: nil)
        }
        
        pathMonitor.start(queue: .main)
    }
}

extension Notification.Name {
    static let didChangeNetworkStatus = Notification.Name("didChangeNetworkStatus")
}
