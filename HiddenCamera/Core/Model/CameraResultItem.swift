//
//  CameraResultItem.swift
//  HiddenCamera
//
//  Created by Duc apple  on 2/1/25.
//

import Foundation

class CameraResultItem {
    var id: String
    var fileName: String
    var tag: CameraResultTag?
    var type: CameraType
    
    init(id: String, fileName: String, tag: CameraResultTag? = nil, type: CameraType) {
        self.id = id
        self.fileName = fileName
        self.tag = tag
        self.type = type
    }
    
    init(rlm: RlmCameraResult) {
        self.id = rlm.id
        self.fileName = rlm.fileName
        self.tag = CameraResultTag(rawValue: rlm.tag)
        self.type = CameraType(rawValue: rlm.type) ?? .infrared
    }
}

enum CameraResultTag: String {
    case risk
    case trusted
}

enum CameraType: String {
    case aiDetector
    case infrared
}
