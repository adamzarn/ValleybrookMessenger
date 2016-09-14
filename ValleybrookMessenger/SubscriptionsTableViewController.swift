//
//  SubscriptionsTableViewController.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/6/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class SubscriptionsTableViewController: UIViewController {

    @IBOutlet weak var editProfileButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    let ref = FIRDatabase.database().reference()
    
    var groups: [String:Bool] = [:]
    var groupKeys: [String] = []
    var subscribedToGroup: [Bool] = []
    
    func updateGroups() {
        
        FirebaseClient.sharedInstance.getGroupData { (result, error) -> () in
            if let result = result {
                for item in result {
                    let key = item.key as! String
                    if item.value is String {
                        self.groups[key] = false
                    } else {
                        let emails = item.value["Emails"]!!.allValues as! [String]
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        if emails.contains(appDelegate.email!) {
                            self.groups[key] = true
                        } else {
                            self.groups[key] = false
                        }
                    }
                }
            }
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.hidden = true
            self.myTableView.hidden = false
            self.myTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.hidden = true
        activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()

        myTableView.allowsSelection = false
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        barButton.title = "Logged in as \(appDelegate.email!)"
        barButton.enabled = false
        barButton.tintColor = appDelegate.darkValleybrookBlue

        if appDelegate.admin {
            barButton.title = "Manage Groups as Administrator"
            barButton.enabled = true
        }
        
        logoutButton.tintColor = appDelegate.darkValleybrookBlue
        editProfileButton.tintColor = appDelegate.darkValleybrookBlue

    }
    
    override func viewWillAppear(animated: Bool) {
        myTableView.hidden = true
        activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
        updateGroups()
    }
    
    @IBAction func editProfileButtonPressed(sender: AnyObject) {
        let createProfileVC = self.storyboard?.instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
        createProfileVC.comingFromLogin = false
        self.presentViewController(createProfileVC, animated: false, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! CustomCell
        
        groupKeys = []
        subscribedToGroup = []
        
        for (key,value) in groups {
            groupKeys.append(key)
            subscribedToGroup.append(value)
        }

        cell.setCell(groupKeys[indexPath.row], subscribed: subscribedToGroup[indexPath.row])
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            AppState.sharedInstance.signedIn = false
            let loginVC = storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            self.presentViewController(loginVC, animated: false, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        }

    }
    
    @IBAction func manageGroupsButtonPressed(sender: AnyObject) {
        let groupsVC = storyboard?.instantiateViewControllerWithIdentifier("GroupsTableViewController") as! GroupsTableViewController
        self.navigationController?.pushViewController(groupsVC, animated: false)
        
    }
    
    
    
}
