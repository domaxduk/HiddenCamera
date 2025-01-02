//
//  RealmDAO.swift
//  HiddenCamera
//
//  Created by Duc apple  on 2/1/25.
//

import Foundation
import RealmSwift

extension Realm {
    func safeTransaction(_ closure: () throws -> Void) throws {
        if self.isInWriteTransaction {
            try closure()
        } else {
            try self.write(closure)
        }
    }
}

class RealmDAO {
    func objects<T: Object>(type: T.Type) throws -> Results<T> {
        let realm = try getRealm()
        return realm.objects(type)
    }
    
    func objectWithPrimaryKey<T: Object>(type: T.Type, key: Any) throws -> T? {
        let realm = try getRealm()
        return realm.object(ofType: type, forPrimaryKey: key)
    }
    
    func deleteAll<T: Object>(type: T.Type) throws {
        let realm = try getRealm()
        let results = realm.objects(type)
        
        try realm.safeTransaction {
            realm.delete(results)
        }
    }
    
    func addObject(_ objects: [Object]) throws {
        let realm = try getRealm()
        try realm.safeTransaction {
            realm.add(objects)
        }
    }
    
    func addAndUpdateObject(_ objects: [Object]) throws {
        let realm = try getRealm()
        try realm.safeTransaction {
            realm.add(objects, update: .all)
        }
    }
    
    func deleteObject(_ objects: [Object]) throws {
        let realm = try getRealm()
        try realm.safeTransaction {
            realm.delete(objects)
        }
    }
    
    func getRealm() throws -> Realm {
        let config = Realm.Configuration()
        let realm = try Realm(configuration: config)
        return realm
    }
}
