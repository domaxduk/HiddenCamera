//
//  ScanOptionItem.swift
//  HiddenCamera
//
//  Created by Duc apple  on 7/1/25.
//

import Foundation

class ScanOptionItem {
    var id: String
    var date: Date?
    var suspiciousResult: [ToolItem: Int] = [:]
    var tools: [ToolItem]
    var step: Int = -1
    
    var isSave: Bool = false
    var isEnd: Bool = false
    var isScanOption: Bool = false
    
    init() {
        self.id = UUID().uuidString
        self.tools = [.bluetoothScanner, .wifiScanner, .cameraDetector]
    }
    
    init(tools: [ToolItem]) {
        self.id = UUID().uuidString
        self.tools = tools
        self.isScanOption = true
    }
    
    init(rlm: RlmScanHistory) {
        self.id = rlm.id
        self.isSave = true
        self.isEnd = true
        self.isScanOption = rlm.isScanOption
        self.date = Date(timeIntervalSince1970: rlm.date)
        
        self.suspiciousResult = Dictionary(uniqueKeysWithValues: rlm.results.components(separatedBy: ",").compactMap({ item in
            let components = item.components(separatedBy: ":")
            if let firstComponent = components.first,
               let secondComponent = components.last,
               let tool = ToolItem(rawValue: firstComponent), let value = Int(secondComponent) {
                return (tool, value)
            }
            
            return nil
        }))
        
        self.tools = rlm.tools.components(separatedBy: ",").compactMap({ ToolItem(rawValue: $0) })
    }
    
    var nextTool: ToolItem? {
        if step + 1 >= tools.count {
            return nil
        }
        
        return tools[step + 1]
    }
    
    func increase() {
        self.step += 1
    }
    
    func decrease() {
        if isEnd { return }
        
        if step < tools.count {
            let tool = tools[step]
            self.suspiciousResult.removeValue(forKey: tool)
        }
        
        self.step -= 1
    }
}
