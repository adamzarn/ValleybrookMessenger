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
    
    var delegate: UIViewController?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //Methods*******************************************************************
    
    func setCell(group: NSMutableAttributedString, subscribed: Bool) {
        self.group.attributedText = group
        self.subscribed.on = subscribed
    }
    
    //Actions*******************************************************************

    @IBAction func switchFlipped(sender: AnyObject) {
        
        if Methods.sharedInstance.hasConnectivity() {

            let group = self.group.text!
            
            if group == "All Users" {
                FirebaseClient.sharedInstance.getUserData { (users, error) -> () in
                    if let users = users {
                        
                        if self.subscribed.on {
                            
                            let allUserKeys = users.allKeys as! [String]
                            
                            for key in allUserKeys {
                                let user = users[key] as! NSDictionary
                                self.appDelegate.emailRecipients.append(user["email"] as! String)
                                self.appDelegate.emailRecipients.append(user["phone"] as! String)
                            }
                            
                        } else {
                            
                            let allUserKeys = users.allKeys as! [String]
                            
                            for key in allUserKeys {
                                let user = users[key] as! NSDictionary
                                let email = user["email"] as! String
                                let phone = user["phone"] as! String
                                self.appDelegate.emailRecipients = self.appDelegate.emailRecipients.filter{ $0 != email }
                                self.appDelegate.textRecipients = self.appDelegate.textRecipients.filter{ $0 != phone }
                            }
                        }
                        
                        self.appDelegate.emailRecipients = Array(Set(self.appDelegate.emailRecipients))
                        self.appDelegate.textRecipients = Array(Set(self.appDelegate.textRecipients))

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
                        
                            for email in newEmails! {
                                self.appDelegate.emailRecipients.append(email)
                            }
                        
                            for phone in newPhones! {
                                self.appDelegate.textRecipients.append(phone)
                            }
                            
                        } else {
                            
                            for email in newEmails! {
                                self.appDelegate.emailRecipients = self.appDelegate.emailRecipients.filter{ $0 != email }
                            }
                                
                            for phone in newPhones! {
                                self.appDelegate.textRecipients = self.appDelegate.textRecipients.filter{ $0 != phone }
                            }
                        }
                        
                        self.appDelegate.emailRecipients = Array(Set(self.appDelegate.emailRecipients))
                        self.appDelegate.textRecipients = Array(Set(self.appDelegate.textRecipients))
                    }
                }
            }
        } else {
            self.subscribed.on = !subscribed.on

            let networkConnectivityError = UIAlertController(title: "No Internet Connection", message: "Please check your connection.", preferredStyle: UIAlertControllerStyle.Alert)
            networkConnectivityError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            let configureVC = self.delegate as! ConfigureMessageViewController
            configureVC.presentViewController(networkConnectivityError, animated: false,completion: nil)
            
        }
    }
    
            
}

