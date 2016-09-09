//
//  GroupsTableViewController.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/8/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class GroupsTableViewController: UIViewController {
    
    var alert = UIAlertController(title: "Add New Group", message: "", preferredStyle: UIAlertControllerStyle.Alert)
    
    let ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var myTableView: UITableView!
    
    var groups: [String:Int] = [:]
    
    func tableView(tableView: UITableView, numberO section: Int) -> Int {
        return groups.count
    }
    
    func updateGroups() {
        self.ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.groups = [:]
            if let groupsChild = snapshot.value!["Groups"] {
                if groupsChild != nil {
                    let allGroups = groupsChild as! NSDictionary
                    for item in allGroups {
                        let key = item.key as! String
                        if item.value is String {
                            self.groups[key] = 0
                        } else {
                            let emails = item.value["Emails"]
                            self.groups[key] = emails!!.count
                        }
                    }
                }
            }

            self.myTableView.reloadData()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateGroups()

        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        
        self.alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction)in
            
            let groupsRef = self.ref.child("Groups")
            let newGroupRef = groupsRef.child(self.alert.textFields![0].text!)
            
            newGroupRef.setValue("")
            
            self.alert.textFields![0].text = ""
            
            self.updateGroups()
            
        }))
        
    }
    
    func configurationTextField(textField: UITextField!) {
        if let textField = textField {
            textField.placeholder = "Enter New Group Here"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel!.textColor = UIColor.blackColor()
        cell.detailTextLabel!.textColor = UIColor.blackColor()
        
        var groupKeys: [String] = []
        var groupCounts: [Int] = []
        
        for (key,value) in groups {
            groupKeys.append(key)
            groupCounts.append(value)
        }
        
        print(groupKeys)
        print(groupCounts)
        
        cell.textLabel!.text = groupKeys[indexPath.row]
        cell.imageView!.image = UIImage(named: "Group.png")
        if groupCounts[indexPath.row] == 1 {
            cell.detailTextLabel?.text = "1 Member"
        } else {
            cell.detailTextLabel?.text = "\(groupCounts[indexPath.row]) Members"
        }
        
        if groupCounts[indexPath.row] == 0 {
            cell.textLabel!.textColor = UIColor.lightGrayColor()
            cell.detailTextLabel!.textColor = UIColor.lightGrayColor()
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {

            //let object = groups[indexPath.row]
            
            //self.ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
                //let groupsChild = snapshot.value!["Groups"] as! NSDictionary
                //if let keys = groupsChild.allKeysForObject(object) as? [String] {
                    //if keys.count > 0 {
                        //let key = keys[0]
                        //let groupRef = self.ref.child("Groups").child(key)
                        //groupRef.removeValue()
                    //}
                //}
            //})
        }
    }

    @IBAction func createMessageButtonPressed(sender: AnyObject) {
        let configureMessageVC = storyboard?.instantiateViewControllerWithIdentifier("ConfigureMessageViewController") as! ConfigureMessageViewController
        self.navigationController?.pushViewController(configureMessageVC, animated: true)
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
        print(AppState.sharedInstance.signedIn)
        
    }

    @IBAction func addGroupButtonPressed(sender: AnyObject) {
        self.presentViewController(alert, animated: true, completion: nil)
    }

}