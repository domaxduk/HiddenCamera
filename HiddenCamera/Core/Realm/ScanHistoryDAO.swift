//
//  ScanHistoryDAO.swift
//  HiddenCamera
//
//  Created by Duc apple  on 8/1/25.
//

import Foundation

final class ScanHistoryDAO: RealmDAO {
    func addObject(item: ScanOptionItem) {
        let object = item.rlmObject()
        try? self.addAndUpdateObject([object])
        NotificationCenter.default.post(name: .updateListHistory, object: nil)
    }
    
    func getAll() -> [ScanOptionItem] {
        guard let rlmObjs = try? self.objects(type: RlmScanHistory.self) else {
            return []
        }
        
        return rlmObjs.map({ ScanOptionItem(rlm: $0) }).sorted(by: { $0.date! > $1.date! })
    }
}

extension ScanOptionItem {
    func rlmObject() -> RlmScanHistory {
        let rlm = RlmScanHistory()
        rlm.id = self.id
        rlm.date = Date().timeIntervalSince1970
        rlm.isScanOption = self.isScanOption
        rlm.tools = self.tools.map({ $0.rawValue + ","}).joined()
        rlm.results = self.suspiciousResult.map({ "\($0.key.rawValue):\($0.value),"}).joined()
        
        return rlm
    }
}

extension Notification.Name {
    static let updateListHistory = Notification.Name("updateListHistory")
}

