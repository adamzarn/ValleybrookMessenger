//
//  CustomSubscriptionCell.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/6/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class CustomSubscriptionCell: UITableViewCell {
    
    //Outlets*******************************************************************
    
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var subscribed: UISwitch!
    
    //Local Variables***********************************************************
    
    var switchFlippedOn = false
    
    //Methods*******************************************************************
    
    func setCell(group: String, subscribed: Bool) {
        self.groupLabel.text = group
        self.subscribed.on = subscribed
    }
    
    //Actions*******************************************************************
    
    @IBAction func switchFlipped(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let group = self.groupLabel.text!

        if subscribed.on {
            
            self.switchFlippedOn = true
            
            FirebaseClient.sharedInstance.addUserDataToGroup(group)
            
        } else {
            
            self.switchFlippedOn = false
            var addGroupBack = false
            
            FirebaseClient.sharedInstance.getGroupData { (groups, error) -> () in
                if let groups = groups {
                    
                    let groupLeft = groups[group] as! NSDictionary
                    
                    let emails = groupLeft["Emails"] as! NSDictionary
                    let phones = groupLeft["Phones"] as! NSDictionary
                    let names = groupLeft["Names"] as! NSDictionary
                    
                    if emails.count == 1 {
                        addGroupBack = true
                    }
                
                    let emailKeys = emails.allKeysForObject(appDelegate.email!) as! [String]
                    let phoneKeys = phones.allKeysForObject(appDelegate.phone!) as! [String]
                    let nameKeys = names.allKeysForObject(appDelegate.name!) as! [String]
                
                    if emailKeys.count > 0 {
                        let emailKey = emailKeys[0]
                        let phoneKey = phoneKeys[0]
                        let nameKey = nameKeys[0]
                        FirebaseClient.sharedInstance.removeUserDataFromGroup(group, emailKey: emailKey, phoneKey: phoneKey, nameKey: nameKey)
                    }
                    
                    if addGroupBack {
                        FirebaseClient.sharedInstance.addGroup(group)
                    }

                }
            }
        }
    }
    
}
