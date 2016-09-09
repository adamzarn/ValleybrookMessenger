//
//  CustomCell.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/6/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class CustomCell: UITableViewCell {
    
    let ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var group: UILabel!
    @IBOutlet weak var subscribed: UISwitch!
    var switchFlippedOn = false
    
    func setCell(group: String, subscribed: Bool) {
        self.group.text = group
        self.subscribed.on = subscribed
    }
    
    @IBAction func switchFlipped(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let object = self.group.text!
        let groupsRef = self.ref.child("Groups")
        
        if subscribed.on {
            
            self.switchFlippedOn = true
            
            let newEmailRef = self.ref.child("Groups").child(object).child("Emails").childByAutoId()
            newEmailRef.setValue(appDelegate.email)
            let newPhoneRef = self.ref.child("Groups").child(object).child("Phones").childByAutoId()
            newPhoneRef.setValue(appDelegate.phone)

        } else {
            
            self.switchFlippedOn = false
            
            self.ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if snapshot.value!["Groups"]!![object] != nil {
                let groups = snapshot.value!["Groups"]!![object] as! NSDictionary
                let emails = groups["Emails"] as! NSDictionary
                let phones = groups["Phones"] as! NSDictionary
                
                let emailKeys = emails.allKeysForObject(appDelegate.email!) as! [String]
                let phoneKeys = phones.allKeysForObject(appDelegate.phone!) as! [String]
                
                if emailKeys.count > 0 {
                    let emailKey = emailKeys[0]
                    let emailToDeleteRef = groupsRef.child(object).child("Emails").child(emailKey)
                    emailToDeleteRef.removeValue()
                }
                
                if phoneKeys.count > 0 {
                    let phoneKey = phoneKeys[0]
                    let phoneToDeleteRef = groupsRef.child(object).child("Phones").child(phoneKey)
                    phoneToDeleteRef.removeValue()
                }
                
                }
                
                }, withCancelBlock: { error in
                    print(error.description)
            })
        }
    }

    
    
}
