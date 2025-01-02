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
        try? self.addAndUpdateObject([object])
    }
    
    func getAll() -> [CameraResultItem] {
        guard let rlmObjs = try? self.objects(type: RlmCameraResult.self) else {
            return []
        }
        
        return rlmObjs.map({ CameraResultItem(rlm: $0) })
    }
    
    func deleteObject(id: String) {
        if let object = getAll().first(where: { $0.id == id }) {
            self.deleteObject(item: object)
        }
    }
    
    private func deleteObject(item: CameraResultItem) {
        guard let rlmObject = try? super.objectWithPrimaryKey(type: RlmCameraResult.self, key: item.id) else {
            print("No object \(item.id) in realm")
            return
        }
        
        try? super.deleteObject([rlmObject])
    }
    
    func deleteItems(items: [CameraResultItem]) {
        let objects = items.compactMap({ try? super.objectWithPrimaryKey(type: RlmCameraResult.self, key: $0.id) })
        if !objects.isEmpty {
            try? super.deleteObject(objects)
        }
    }
}
