//
//  CustomRecipientsCell.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/9/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class CustomRecipientsCell: UITableViewCell {
    
    //Outlets*******************************************************************
    
    @IBOutlet weak var group: UILabel!
    @IBOutlet weak var members: UILabel!
    @IBOutlet weak var subscribed: UISwitch!
    
    //Local Variables***********************************************************
    
    var switchFlippedOn = false
    
    //Methods*******************************************************************
    
    func setCell(group: NSMutableAttributedString, subscribed: Bool) {
        self.group.attributedText = group
        self.subscribed.on = subscribed
    }
    
    //Actions*******************************************************************

    @IBAction func switchFlipped(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let group = self.group.text!
        
        if group == "All Users" {
            FirebaseClient.sharedInstance.getUserData { (users, error) -> () in
                if let users = users {
                    
                    if self.subscribed.on {
                        
                        self.switchFlippedOn = true
                        
                        let allUserKeys = users.allKeys as! [String]
                        
                        for key in allUserKeys {
                            let user = users[key] as! NSDictionary
                            appDelegate.emailRecipients.append(user["email"] as! String)
                            appDelegate.emailRecipients.append(user["phone"] as! String)
                        }
                        
                    } else {
                        
                        self.switchFlippedOn = false
                        
                        let allUserKeys = users.allKeys as! [String]
                        
                        for key in allUserKeys {
                            let user = users[key] as! NSDictionary
                            let email = user["email"] as! String
                            let phone = user["phone"] as! String
                            appDelegate.emailRecipients = appDelegate.emailRecipients.filter{ $0 != email }
                            appDelegate.textRecipients = appDelegate.textRecipients.filter{ $0 != phone }
                        }
                    }
                    
                    appDelegate.emailRecipients = Array(Set(appDelegate.emailRecipients))
                    appDelegate.textRecipients = Array(Set(appDelegate.textRecipients))

                }
            }
            
        } else {
        
            FirebaseClient.sharedInstance.getGroupData { (groups, error) -> () in
                if let groups = groups {
                    
                    let group = groups[group] as! NSDictionary
                    let emails = group["Emails"] as! NSDictionary
                    let phones = group["Phones"] as! NSDictionary
                    
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
            }
        }
    }
    
            
}

