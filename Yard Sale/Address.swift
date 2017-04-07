//
//  Address.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 4/7/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import Foundation
import Firebase

class Address
{
    static let street = "street"
    static let city = "city"
    static let state = "state"
    static let zipCode = "zipCode"
    
    let street: String?
    let city: String?
    let state: String?
    let zipCode: String?
    let ref : FIRDatabaseReference?
    
    init(withStreet: String, city: String, state: String, zip: String)
    {
        self.street = withStreet
        self.city = city
        self.state = state
        self.zipCode = zip
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot)
    {
        let snapshotValue = snapshot.value as! [String:Any]
        self.street = snapshotValue[Address.street] as? String
        self.city = snapshotValue[Address.city] as? String
        self.state = snapshotValue[Address.state] as? String
        self.zipCode = snapshotValue[Address.zipCode] as? String
        self.ref = snapshot.ref
    }
    
    func toDictionary() -> Any {
        return [
            Address.street : self.street,
            Address.city : self.city,
            Address.state : self.state,
            Address.zipCode : self.zipCode
        ]
    }
}
