//
//  User.swift
//  Yard Sale
//
//  Created by Octavio Cedeno on 3/23/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import Foundation
import FirebaseAuth

struct User
{
    let uid: String
    let email: String
    
    init(authData: FIRUser)
    {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
}
