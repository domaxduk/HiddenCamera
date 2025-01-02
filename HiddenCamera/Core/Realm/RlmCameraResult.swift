//
//  RlmCameraResult.swift
//  HiddenCamera
//
//  Created by Duc apple  on 2/1/25.
//

import Foundation
import RealmSwift

final class RlmCameraResult: Object {
    @objc dynamic var id: String!
    @objc dynamic var fileName: String!
    @objc dynamic var tag: String!
    @objc dynamic var type: String!
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

extension CameraResultItem {
    func rlmObject() -> RlmCameraResult {
        let rlm = RlmCameraResult()
        rlm.id = self.id
        rlm.fileName = self.fileName
        rlm.tag = self.tag?.rawValue ?? ""
        rlm.type = self.type.rawValue
        return rlm
    }
}
