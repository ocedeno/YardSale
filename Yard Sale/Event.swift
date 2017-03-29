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
    static let startTime = "startTime"
    static let stopTime = "stopTime"
    static let description = "description"
    static let active = "active"
    static let userID = "userID"
    static let address = "address"
    
    let title: String?
    let date: String?
    let startTime: String?
    let stopTime: String?
    let description: String?
    let userID: String?
    let active: Bool?
    let address: String?
    let ref : FIRDatabaseReference?
    
    init(withTitle title: String, onDate date: String, startTime:String, stopTime: String, withDescription description: String, userID uid: String, activeEvent active: Bool, withAddress address: String)
    {
        self.title = title
        self.date = date
        self.startTime = startTime
        self.stopTime = stopTime
        self.description = description
        self.active = active
        self.userID = uid
        self.ref = nil
        self.address = address
    }
    
    init(snapshot: FIRDataSnapshot)
    {
        let snapshotValue = snapshot.value as! [String: Any]
        self.title = snapshotValue[Event.titleKey] as? String
        self.date = snapshotValue[Event.date] as? String
        self.startTime = snapshotValue[Event.startTime] as? String
        self.stopTime = snapshotValue[Event.stopTime] as? String
        self.userID = snapshotValue[Event.userID] as? String
        self.description = snapshotValue[Event.description] as? String
        self.active = snapshotValue[Event.active] as? Bool
        self.ref = snapshot.ref
        self.address = snapshotValue[Event.address] as? String
    }
    
    func toDictionary() -> Any {
        return [
            Event.userID : self.userID!,
            Event.titleKey : self.title!,
            Event.date : self.date!,
            Event.startTime : self.startTime!,
            Event.stopTime : self.stopTime!,
            Event.description : self.description!,
            Event.active : self.active!,
            Event.address : self.address!
        ]
    }
}
