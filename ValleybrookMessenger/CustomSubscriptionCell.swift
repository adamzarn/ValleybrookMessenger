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
    
    var delegate: UIViewController?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //Methods*******************************************************************
    
    func setCell(group: String, subscribed: Bool) {
        self.groupLabel.text = group
        self.subscribed.on = subscribed
    }
    
    //Actions*******************************************************************
    
    @IBAction func switchFlipped(sender: AnyObject) {
        
        if Methods.sharedInstance.hasConnectivity() {
    
            let group = self.groupLabel.text!

            if subscribed.on {
                
                FirebaseClient.sharedInstance.addUserDataToGroup(group)
                
            } else {

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
                    
                        let emailKeys = emails.allKeysForObject(self.appDelegate.email!) as! [String]
                        let phoneKeys = phones.allKeysForObject(self.appDelegate.phone!) as! [String]
                        let nameKeys = names.allKeysForObject(self.appDelegate.name!) as! [String]
                    
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
            
        } else {
            
            self.subscribed.on = !self.subscribed.on
    
            let networkConnectivityError = UIAlertController(title: "No Internet Connection", message: "Please check your connection.", preferredStyle: UIAlertControllerStyle.Alert)
            networkConnectivityError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))

            let subscriptionsVC = self.delegate as! SubscriptionsTableViewController
            subscriptionsVC.presentViewController(networkConnectivityError, animated: false,completion: nil)
            subscriptionsVC.view.sendSubviewToBack(subscriptionsVC.view)
            
        }
    }
}
