//
//  User.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/23/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import Foundation
import Firebase

class User
{
    static let firstNameKey = "firstName"
    static let lastNameKey = "lastName"
    static let emailKey = "email"
    static let emailConfirmationKey = "emailConfirmation"

    let firstName: String?
    let lastName: String?
    let email: String?
    let emailConfirmation: Bool?
    let ref : FIRDatabaseReference?
    
    init(authData: FIRUser, firstName: String, lastName: String)
    {
        self.firstName = firstName
        self.lastName = lastName
        email = authData.email!
        emailConfirmation = authData.isEmailVerified
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot)
    {
        let snapshotValue = snapshot.value as! [String:Any]
        self.firstName = snapshotValue[User.firstNameKey] as? String
        self.lastName = snapshotValue[User.lastNameKey] as? String
        self.email = snapshotValue[User.emailKey] as? String
        self.emailConfirmation = snapshotValue[User.emailConfirmationKey] as? Bool
        self.ref = snapshot.ref
    }
    
    func toDictionary() -> Any {
        return [
            User.firstNameKey : self.firstName!,
            User.lastNameKey : self.lastName!,
            User.emailKey : self.email!,
            User.emailConfirmationKey : self.emailConfirmation!
        ]
    }
}
