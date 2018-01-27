//
//  Record.swift
//  BadgeApp_SmartStoreV5
//
//  Created by Herman Ng on 1/27/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation

class Record {
    required init(data: [Any]) {
        self.data = (data as! [Dictionary]).first!
    }
    
    required init() { }
    
    var data: Dictionary = Dictionary<String,Any>()
    
    enum Field: String {
        case entryId = "_soupEntryId"
        case id = "Id"
    }
    
    private(set) lazy var entryId: Int? = self.data[Field.entryId.rawValue] as? Int
    private(set) lazy var id: String? = self.data[Field.id.rawValue] as? String
    
    static func from<T:StoreProtocol>(_ records: [Any]) -> T {
        return T(data: records)
    }
    
    static func from<T:StoreProtocol>(_ records: Dictionary<String, Any>) -> T {
        return T(data: [records])
    }
    
    static func from<T:StoreProtocol>(_ records: [Any]) -> [T] {
        return records.map { return T.from($0 as! Dictionary<String, Any>) }
    }
}
