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
    static let locLat = "locationLatitude"
    static let locLon = "locationLongitude"
    static let addressDictionary = "addressDictionary"
    
    let title: String?
    let date: String?
    let startTime: String?
    let stopTime: String?
    let description: String?
    let userID: String?
    let active: Bool?
    let locLat: Double?
    let locLon: Double?
    let addressDictionary: [String:AnyObject]?
    let ref : FIRDatabaseReference?
    
    init(withTitle title: String, onDate date: String, startTime:String, stopTime: String, withDescription description: String, userID uid: String, activeEvent active: Bool, locationLatitude: Double, locationLongitude: Double, addDict: [String:AnyObject])
    {
        self.title = title
        self.date = date
        self.startTime = startTime
        self.stopTime = stopTime
        self.description = description
        self.active = active
        self.userID = uid
        self.ref = nil
        self.locLat = locationLatitude
        self.locLon = locationLongitude
        self.addressDictionary = addDict
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
        self.locLat = snapshotValue[Event.locLat] as? Double
        self.locLon = snapshotValue[Event.locLon] as? Double
        self.addressDictionary = snapshotValue[Event.addressDictionary] as? [String:AnyObject]
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
            Event.locLat : self.locLat!,
            Event.locLon : self.locLon!,
            Event.addressDictionary : self.addressDictionary!
        ]
    }
}
