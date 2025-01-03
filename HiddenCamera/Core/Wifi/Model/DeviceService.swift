//
//  DeviceService.swift
//  DemoDetect
//
//  Created by Duc apple  on 27/12/24.
//

import Foundation

class DeviceService {
    var domain: String
    var type: String
    var name: String
    var txtRecord: Data?
    
    init(domain: String, type: String, name: String, txtRecord: Data?) {
        self.domain = domain
        self.type = type
        self.name = name
        self.txtRecord = txtRecord
    }
    
    var full: String {
        return domain + type + name
    }
}
