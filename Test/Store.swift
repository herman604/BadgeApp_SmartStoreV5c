//
//  Store.swift
//  BadgeApp_SmartStoreV5
//
//  Created by Herman Ng on 1/27/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import SmartStore

protocol StoreProtocol {
    init()
    init(data: [Any])
    static var objectName: String {get}
    static var indexes: [[String:String]] {get}
    static var orderPath: String? {get}
    static func from<T:StoreProtocol>(_ records: [Any]) -> T
    static func from<T:StoreProtocol>(_ records: [Any]) -> [T]
    static func from<T:StoreProtocol>(_ records: Dictionary<String, Any>) -> T
}

class Store<objectType: StoreProtocol> {
    
    private final let pageSize: UInt = 100
    
    init() {
        createSoup()
    }
    
    //Create a User Store
    lazy final var store: SFSmartStore = SFSmartStore.sharedStore(withName: kDefaultSmartStoreName) as! SFSmartStore
    //Create a Global Store
    //lazy final var store: SFSmartStore = SFSmartStore.sharedGlobalStore(withName: kDefaultSmartStoreName) as! SFSmartStore
    //SFSmartStore.removeSharedGlobalStore(withName: kDefaultSmartStoreName)
    
    var count: Int {
        let query: SFQuerySpec = SFQuerySpec.newSmartQuerySpec("select count(*) from {\(objectType.objectName)}", withPageSize: 1)
        do {
            let results: [Any] = try store.query(with: query, pageIndex: 0)
            return (results as! [[Int]]).first?.first ?? 0
        } catch let error as NSError {
            NSLog(error.localizedDescription)
        }
        return 0
    }
    
    func upsertEntries(jsonResponse: Any) {
        let dataRows = (jsonResponse as! NSDictionary)["records"] as! [NSDictionary]
        SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.debug, message:"request:didLoadResponse: #records: \(dataRows.count)")
        do {
            try store.upsertEntries(dataRows, toSoup: objectType.objectName, withExternalIdPath: Record.Field.id.rawValue)
        } catch let error as NSError {
            NSLog("UPSERT ERROR \(error.localizedDescription)")
        }
    }
    
    // Delete Data
    func deleteEntry(entryId: Int?) {
        if let entryId = entryId {
            var error: NSError?
            store.removeEntries([entryId], fromSoup: objectType.objectName, error: &error)
            if let error = error {
                NSLog("DELETE ERROR \(error.localizedDescription)")
            }
        }
    }
    
    // Registering a Soup
    func createSoup() {
        if (!store.soupExists(objectType.objectName)) {
            let indexSpecs: [AnyObject] = SFSoupIndex.asArraySoupIndexes(objectType.indexes) as [AnyObject]
            do {
                try store.registerSoup(objectType.objectName, withIndexSpecs: indexSpecs, error: ())
            } catch let error as NSError {
                NSLog("failed to register \(objectType.objectName) soup: \(error.localizedDescription)")
            }
        } else {
            //store.clearSoup(soupName)
        }
    }
    
    
    // Querying Data
    func getRecord(index: Int) -> objectType {
        let query:SFQuerySpec = SFQuerySpec.newAllQuerySpec(objectType.objectName, withOrderPath: objectType.orderPath, with: .ascending, withPageSize: 1)
        do {
            let results: [Any] = try store.query(with: query, pageIndex: UInt(index))
            return objectType.from(results)
        } catch let error as NSError {
            NSLog(error.localizedDescription)
            return objectType()
        }
    }
    
    func getRecords() -> [objectType] {
        let query:SFQuerySpec = SFQuerySpec.newAllQuerySpec(objectType.objectName, withOrderPath: objectType.orderPath, with: .ascending, withPageSize: pageSize)
        do {
            let results: [Any] = try store.query(with: query, pageIndex: 0)
            return objectType.from(results)
        } catch let error as NSError {
            NSLog(error.localizedDescription)
            return []
        }
    }
}
