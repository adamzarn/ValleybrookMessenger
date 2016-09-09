//
//  User.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/7/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation

struct User {
    let uid: String
    let name: String
    let email: String
    let phone: String
    let admin: Bool
    
    // Initialize from Firebase
    //init(authData: FAuthData) {
    //    uid = authData.uid
    //    email = authData.providerData["email"] as! String
    //}
    
    // Initialize from arbitrary data
    init(uid: String, name: String, email: String, phone: String, admin: Bool) {
        self.uid = uid
        self.name = name
        self.email = email
        self.phone = phone
        self.admin = admin
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "name": name,
            "email": email,
            "phone": phone,
            "admin": admin
        ]
    }

}
