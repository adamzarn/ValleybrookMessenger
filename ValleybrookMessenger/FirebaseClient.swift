//
//  FirebaseClient.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/9/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class FirebaseClient: NSObject {
    
    let ref = FIRDatabase.database().reference()
    
    func getGroupData(completion: (groups: NSDictionary?, error: String?) -> ()) {
        self.ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let groupData = snapshot.value!["Groups"] {
                completion(groups: groupData as? NSDictionary, error: nil)
            } else {
                completion(groups: nil, error: "Could not retrieve data")
            }
        })
    }
    
    func getUserData(completion: (users: NSDictionary?, error: String?) -> ()) {
        self.ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let userData = snapshot.value!["Users"] {
                completion(users: userData as? NSDictionary, error: nil)
            } else {
                completion(users: nil, error: "Could not retrieve data")
            }
        })
    }
    
    func addGroup(group: String) {
        let groupsRef = self.ref.child("Groups")
        let newGroupRef = groupsRef.child(group)
        newGroupRef.setValue("")
    }
    
    func removeGroup(group: String) {
        let groupRef = self.ref.child("Groups").child(group)
        groupRef.removeValue()
    }
    
    func addNewUser(uid: String, name: String, email: String, phone: String) {
        
        let newUser = User(uid: uid, name: name, email: email, phone: phone, admin: false)
        let userRef = self.ref.child("Users/\(uid)")
        userRef.setValue(newUser.toAnyObject())
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.uid = uid
        appDelegate.email = email
        appDelegate.phone = phone
        appDelegate.name = name

    }
    
    func updateUserInfo(name: String, email: String, phone: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let userRef = self.ref.child("Users").child(appDelegate.uid!)
        
        userRef.updateChildValues(["name":name,
            "email":email,
            "phone":phone])
        
        appDelegate.name = name
        appDelegate.email = email
        appDelegate.phone = phone
        
    }
    
    func addUserDataToGroup(group: String) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let groupRef = self.ref.child("Groups").child(group)
        
        let newEmailRef = groupRef.child("Emails").childByAutoId()
        newEmailRef.setValue(appDelegate.email)
        let newPhoneRef = groupRef.child("Phones").childByAutoId()
        newPhoneRef.setValue(appDelegate.phone)
        let newNameRef = groupRef.child("Names").childByAutoId()
        newNameRef.setValue(appDelegate.name)
    }
    
    func removeUserDataFromGroup(group: String, emailKey: String, phoneKey: String, nameKey: String) {
        
        let groupRef = self.ref.child("Groups").child(group)

        let emailToDeleteRef = groupRef.child("Emails").child(emailKey)
        emailToDeleteRef.removeValue()
        let phoneToDeleteRef = groupRef.child("Phones").child(phoneKey)
        phoneToDeleteRef.removeValue()
        let nameToDeleteRef = groupRef.child("Names").child(nameKey)
        nameToDeleteRef.removeValue()

    }

    static let sharedInstance = FirebaseClient()
    private override init() {
        super.init()
    }
}