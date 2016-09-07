//
//  SubscriptionsTableViewController.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/6/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class SubscriptionsTableViewController: UIViewController {

    @IBOutlet weak var subscriptionsTableView: UITableView!
    
    let groups = ["Food Pantry"
                  ,"Facilities Teardown"
                  ,"Tech Teardown"
                  ,"Prayer"
                  ,"Worship Team"
                  ,"Small Groups"]
    
    
    func tableView(tableView: UITableView, numberO section: Int) -> Int {
        return groups.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! CustomCell
        
        cell.setCell(groups[indexPath.row], subscribed: false)
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        let loginVC = storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.presentViewController(loginVC, animated: false, completion: nil)
    }
    
    
    @IBAction func editButtonProfileButtonPressed(sender: AnyObject) {
        let createProfileVC = storyboard?.instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
        self.presentViewController(createProfileVC, animated: false, completion: nil)
    }
    
}
