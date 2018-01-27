//
//  User.swift
//  BadgeApp_SmartStoreV5
//
//  Created by Herman Ng on 1/27/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import SmartStore

class User: Record, StoreProtocol {
    //Soup Name
    static let objectName: String = "User"
    
    enum Field: String {
        case ownerId = "OwnerId"
        case name = "Name"
    }
    
    fileprivate(set) lazy var ownerId: String? = self.data[Field.ownerId.rawValue] as? String
    fileprivate(set) lazy var name: String? = self.data[Field.name.rawValue] as? String
    
    // Define what are the index of this Soup
    static let indexes: [[String:String]] = [["path" : Field.id.rawValue, "type" : kSoupIndexTypeString],
                                             ["path" : Field.ownerId.rawValue, "type" : kSoupIndexTypeString],
                                             ["path" : Field.name.rawValue, "type" : kSoupIndexTypeString],
                                             ["path" : Field.entryId.rawValue, "type" : kSoupIndexTypeString]]
    
    static let orderPath: String? = Field.name.rawValue
}

