//
//  RlmScanHistory.swift
//  HiddenCamera
//
//  Created by Duc apple  on 8/1/25.
//

import Foundation
import RealmSwift

final class RlmScanHistory: Object {
    @objc dynamic var id: String!
    @objc dynamic var date: Double = 0
    @objc dynamic var type: Int = 0
    @objc dynamic var results: String!
    @objc dynamic var tools: String!
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
