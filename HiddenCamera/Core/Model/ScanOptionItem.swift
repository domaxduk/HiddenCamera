//
//  ScanOptionItem.swift
//  HiddenCamera
//
//  Created by Duc apple  on 7/1/25.
//

import Foundation

class ScanOptionItem {
    var suspiciousResult: [ToolItem: Int] = [:]
    var tools: [ToolItem]
    private var index: Int = -1
    var isEnd: Bool = false
    
    init() {
        self.tools = [.bluetoothScanner, .wifiScanner, .cameraDetector]
        self.isEnd = false
    }
    
    init(suspiciousResult: [ToolItem : Int], tools: [ToolItem], index: Int, isEnd: Bool) {
        self.suspiciousResult = suspiciousResult
        self.tools = tools
        self.index = index
        self.isEnd = isEnd
    }
    
    var nextTool: ToolItem? {
        if index + 1 >= tools.count {
            return nil
        }
        
        return tools[index + 1]
    }
    
    func increase() {
        self.index += 1
    }
}
