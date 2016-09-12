//
//  MembersTableViewController.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/9/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class MembersTableViewController: UIViewController {
    
    let ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var group: String = ""
    var groupEmails: [String] = []
    var groupPhones: [String] = []
    var groupNames: [String] = []
    
    func updateGroups() {
        self.ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.groupEmails = []
            self.groupPhones = []
            self.groupNames = []
            if let groupInfo = snapshot.value!["Groups"]!![self.group] {

                let emailDict = groupInfo!["Emails"] as! [String:String]
                let phoneDict = groupInfo!["Phones"] as! [String:String]
                let nameDict = groupInfo!["Names"] as! [String:String]
                
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
            
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.hidden = true
            self.myTableView.hidden = false
            self.myTableView.reloadData()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.hidden = true
        activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
        navItem.title = group
        
    }
    
    override func viewWillAppear(animated: Bool) {
        myTableView.hidden = true
        activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
        updateGroups()
    }
    
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
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
}
