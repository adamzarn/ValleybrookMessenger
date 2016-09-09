//
//  CustomRecipientsCell.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/9/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class CustomRecipientsCell: UITableViewCell {
    
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
        
        self.ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value!["Groups"]!![object] != nil {
                let groups = snapshot.value!["Groups"]!![object] as! NSDictionary
                let emails = groups["Emails"] as! NSDictionary
                let phones = groups["Phones"] as! NSDictionary
                
                let newEmails = emails.allValues as? [String]
                let newPhones = phones.allValues as? [String]
                
                if self.subscribed.on {
                    
                    self.switchFlippedOn = true
                
                    for email in newEmails! {
                        appDelegate.emailRecipients.append(email)
                    }
                
                    for phone in newPhones! {
                        appDelegate.textRecipients.append(phone)
                    }
                    
                } else {
                    
                    self.switchFlippedOn = false
                    
                    for email in newEmails! {
                        appDelegate.emailRecipients = appDelegate.emailRecipients.filter{ $0 != email }
                    }
                        
                    for phone in newPhones! {
                        appDelegate.textRecipients = appDelegate.textRecipients.filter{ $0 != phone }
                    }
                }
                
                appDelegate.emailRecipients = Array(Set(appDelegate.emailRecipients))
                appDelegate.textRecipients = Array(Set(appDelegate.textRecipients))
                
            }
        })
    }
    
            
}

