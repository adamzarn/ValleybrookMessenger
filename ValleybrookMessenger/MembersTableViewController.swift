//
//  MembersTableViewController.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/9/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class MembersTableViewController: UIViewController {
    
    //Outlets*******************************************************************
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    //Alerts********************************************************************
    
    let dataErrorAlert:UIAlertController = UIAlertController(title: "Error", message: "Data could not be retrieved from the server. Try again later.",preferredStyle: UIAlertControllerStyle.Alert)
    
    //Local Variables***********************************************************
    
    var group: String = ""
    var groupEmails: [String] = []
    var groupPhones: [String] = []
    var groupNames: [String] = []
    
    //Life Cycle Functions*******************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataErrorAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        myTableView.hidden = true
        Methods.sharedInstance.toggleActivityIndicator(self.activityIndicatorView)
        navItem.title = group
        
    }
    
    override func viewWillAppear(animated: Bool) {
        myTableView.hidden = true
        Methods.sharedInstance.toggleActivityIndicator(self.activityIndicatorView)
        
        if group == "All Users" {
            getAllUsers()
        } else {
            getMembersForGroup()
        }
        
    }
    
    //Methods*******************************************************************
    
    func getAllUsers() {
        FirebaseClient.sharedInstance.getUserData { (users, error) -> () in
            if let users = users {
                
                self.groupEmails = []
                self.groupPhones = []
                self.groupNames = []
                
                let allUserKeys = users.allKeys as! [String]
                for key in allUserKeys {
                    self.groupEmails.append(users[key]!["email"] as! String)
                    self.groupPhones.append(users[key]!["phone"] as! String)
                    self.groupNames.append(users[key]!["name"] as! String)
                }
            } else {
                self.presentViewController(self.dataErrorAlert, animated: true, completion: nil)
            }
            Methods.sharedInstance.toggleActivityIndicator(self.activityIndicatorView)
            self.myTableView.hidden = false
            self.myTableView.reloadData()
        }
    }
    
    func getMembersForGroup() {
        FirebaseClient.sharedInstance.getGroupData { (groups, error) -> () in
            if let groups = groups {
                
                self.groupEmails = []
                self.groupPhones = []
                self.groupNames = []
            
                if let groupInfo = groups[self.group] {

                    let emailDict = groupInfo["Emails"] as! [String:String]
                    let phoneDict = groupInfo["Phones"] as! [String:String]
                    let nameDict = groupInfo["Names"] as! [String:String]
                
                    let sortedEmailKeys = Array(emailDict.keys).sort(<)
                    let sortedPhoneKeys = Array(phoneDict.keys).sort(<)
                    let sortedNameKeys = Array(nameDict.keys).sort(<)
                
                    for key in sortedEmailKeys {
                        self.groupEmails.append(emailDict[key]!)
                    }
                    for key in sortedPhoneKeys {
                        self.groupPhones.append(phoneDict[key]!)
                    }
                    for key in sortedNameKeys {
                        self.groupNames.append(nameDict[key]!)
                    }
                }
            } else {
                self.presentViewController(self.dataErrorAlert, animated: true, completion: nil)
            }
            Methods.sharedInstance.toggleActivityIndicator(self.activityIndicatorView)
            self.myTableView.hidden = false
            self.myTableView.reloadData()
        }
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL)
            }
        }
    }
    
    //Table View Functions*******************************************************
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CustomMemberCell

        cell.setCell("Member.png", name: groupNames[indexPath.row], email: groupEmails[indexPath.row], phone: groupPhones[indexPath.row])
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupEmails.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        callNumber(groupPhones[indexPath.row])
    }
    
}
