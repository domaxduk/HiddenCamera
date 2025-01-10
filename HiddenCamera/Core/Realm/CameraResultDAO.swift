//
//  CameraResultDAO.swift
//  HiddenCamera
//
//  Created by Duc apple  on 2/1/25.
//

import Foundation

final class CameraResultDAO: RealmDAO {
    func addObject(item: CameraResultItem) {
        let object = item.rlmObject()
        
        do {
            try self.addAndUpdateObject([object])
            NotificationCenter.default.post(name: .updateCameraHistory, object: nil)
        } catch {
            print(error)
        }
    }
    
    func getAll() -> [CameraResultItem] {
        guard let rlmObjs = try? self.objects(type: RlmCameraResult.self) else {
            return []
        }
        
        return rlmObjs.map({ CameraResultItem(rlm: $0) })
    }
    
    func deleteItems(items: [CameraResultItem]) {
        let objects = items.compactMap({ try? super.objectWithPrimaryKey(type: RlmCameraResult.self, key: $0.id) })
        if !objects.isEmpty {
            try? super.deleteObject(objects)
        }
        NotificationCenter.default.post(name: .updateCameraHistory, object: nil)
    }
}

extension Notification.Name {
    static let updateCameraHistory = Notification.Name("updateCameraHistory")
}
