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

    @IBOutlet weak var subscriptionsTableView: UITableView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var myTableView: UITableView!
    
    let ref = FIRDatabase.database().reference()
    
    var groups: [String] = []
    
    func updateGroups() {
        self.ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.groups = []
            if let groupsChild = snapshot.value!["Groups"] {
                if groupsChild != nil {
                    let groups = groupsChild as! NSDictionary
                    for item in groups {
                        let key = item.key
                        self.groups.append(key as! String)
                    }
                }
            }
            
            self.myTableView.reloadData()
        })
    }
    
    var userEmail: String?
    
    func tableView(tableView: UITableView, numberO section: Int) -> Int {
        return groups.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        barButton.title = "Logged in as \(appDelegate.email!)"
        barButton.enabled = false
        barButton.tintColor = appDelegate.darkValleybrookBlue
        
        updateGroups()
        
    }
    
    @IBAction func editProfileButtonPressed(sender: AnyObject) {
        let createProfileVC = self.storyboard?.instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
        createProfileVC.comingFromLogin = false
        self.presentViewController(createProfileVC, animated: false, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! CustomCell
    
        cell.setCell(groups[indexPath.row], subscribed: cell.switchFlippedOn)
        
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
    
    
    @IBAction func editButtonProfileButtonPressed(sender: AnyObject) {
        let createProfileVC = storyboard?.instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
        self.presentViewController(createProfileVC, animated: false, completion: nil)
    }
    
}
