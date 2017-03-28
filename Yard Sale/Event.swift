//
//  Event.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/28/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import Foundation
import Firebase

struct Event
{
    static let titleKey = "title"
    static let date = "date"
    static let time = "time"
    static let description = "description"
    static let active = "active"
    
    let title: String?
    let date: String?
    let time: String?
    let description: String?
    let active: Bool?
    let ref : FIRDatabaseReference?
    
    init(withTitle title: String, onDate date: String, atTime time:String, withDescription description: String, activeEvent active: Bool)
    {
        self.title = title
        self.date = date
        self.time = time
        self.description = description
        self.active = active
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot)
    {
        let snapshotValue = snapshot.value as! [String: Any]
        self.title = snapshotValue[Event.titleKey] as? String
        self.date = snapshotValue[Event.date] as? String
        self.time = snapshotValue[Event.time] as? String
        self.description = snapshotValue[Event.description] as? String
        self.active = snapshotValue[Event.active] as? Bool
        self.ref = snapshot.ref
    }
    
    func toDictionary() -> Any {
        return [
            Event.titleKey : self.title!,
            Event.date : self.date!,
            Event.time : self.time!,
            Event.description : self.description!,
            Event.active : self.active!
        ]
    }
}
