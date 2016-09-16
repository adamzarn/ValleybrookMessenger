//
//  GroupsTableViewController.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/8/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class GroupsTableViewController: UIViewController, UITableViewDelegate {
    
    //Outlets*******************************************************************
    
    @IBOutlet weak var createMessageButton: UIBarButtonItem!
    @IBOutlet weak var addGroupButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var myTableView: UITableView!
    
    //Alerts********************************************************************
    
    let alert = UIAlertController(title: "Add New Group", message: "", preferredStyle: UIAlertControllerStyle.Alert)
    let dataErrorAlert:UIAlertController = UIAlertController(title: "Error", message: "Data could not be retrieved from the server. Try again later.",preferredStyle: UIAlertControllerStyle.Alert)
    
    //Local Variables***********************************************************
    
    var groupsDict: [String:Int] = [:]
    var groupKeys: [String] = []
    var groupCounts: [Int] = []
    
    //Life Cycle Functions*******************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataErrorAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.navigationController!.navigationBar.translucent = false
        
        myTableView.hidden = true
        Methods.sharedInstance.toggleActivityIndicator(self.activityIndicatorView)
        
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        
        self.alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) in
            
            FirebaseClient.sharedInstance.addGroup(self.alert.textFields![0].text!)
            
            self.alert.textFields![0].text = ""
            
            self.getUserCount()
            self.updateGroups()
            
        }))
        
        self.alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        addGroupButton.tintColor = appDelegate.darkValleybrookBlue
        self.navigationController?.navigationBar.tintColor = appDelegate.darkValleybrookBlue
        createMessageButton.tintColor = appDelegate.darkValleybrookBlue
        
    }
    
    override func viewWillAppear(animated: Bool) {
        myTableView.hidden = true
        Methods.sharedInstance.toggleActivityIndicator(self.activityIndicatorView)
        getUserCount()
        updateGroups()
    }
    
    //Methods*******************************************************************
    
    func getUserCount() {
        FirebaseClient.sharedInstance.getUserData { (users, error) -> () in
            if let users = users {
                self.groupsDict["All Users"] = users.count
            } else {
                self.presentViewController(self.dataErrorAlert, animated: true, completion: nil)
            }
        }
    }

    func updateGroups() {
        FirebaseClient.sharedInstance.getGroupData { (groups, error) -> () in
            if let groups = groups {
                for group in groups {
                    let key = group.key as! String
                    if group.value is String {
                        self.groupsDict[key] = 0
                    } else {
                        let emails = group.value["Emails"]
                        self.groupsDict[key] = emails!!.count
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
    
    //Text Field Functions*******************************************************
    
    func configurationTextField(textField: UITextField!) {
        if let textField = textField {
            textField.placeholder = "Enter New Group Here"
        }
    }
    
    //Table View Functions*******************************************************
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel!.textColor = UIColor.blackColor()
        cell.detailTextLabel!.textColor = UIColor.blackColor()
        
        groupKeys = []
        groupCounts = []
        
        let sortedGroupKeys = Array(groupsDict.keys).sort(<)
        
        for key in sortedGroupKeys {
            groupKeys.append(key)
            groupCounts.append(groupsDict[key]!)
        }
        
        cell.imageView!.image = UIImage(named: "Group.png")
        
        if groupCounts[indexPath.row] == 1 {
            cell.detailTextLabel!.text = "1 Member"
        } else {
            cell.detailTextLabel!.text = "\(groupCounts[indexPath.row]) Members"
        }
        
        if groupKeys[indexPath.row] == "All Users" {
            let attributedTitleText = NSMutableAttributedString(string: "All Users", attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(16)])
            let attributedSubtitleText = NSMutableAttributedString(string: cell.detailTextLabel!.text!, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(11)])
            cell.textLabel!.attributedText = attributedTitleText
            cell.detailTextLabel!.attributedText = attributedSubtitleText
        } else {
            cell.textLabel!.text = groupKeys[indexPath.row]
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
        return groupsDict.count
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if groupKeys[indexPath.row] == "All Users" {
            return .None
        } else {
            return .Delete
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        let groupToRemove = groupKeys[indexPath.row]
    
        groupsDict.removeValueForKey(groupToRemove)
        FirebaseClient.sharedInstance.removeGroup(groupToRemove)
    
        myTableView.reloadData()
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if groupCounts[indexPath.row] > 0 {
        let membersVC = storyboard?.instantiateViewControllerWithIdentifier("MembersTableViewController") as! MembersTableViewController
        membersVC.group = groupKeys[indexPath.row]
        self.navigationController?.pushViewController(membersVC, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

    }

    //Actions*******************************************************************
    
    @IBAction func createMessageButtonPressed(sender: AnyObject) {
        let configureMessageVC = storyboard?.instantiateViewControllerWithIdentifier("ConfigureMessageViewController") as! ConfigureMessageViewController
        self.navigationController?.pushViewController(configureMessageVC, animated: true)
    }
    
    @IBAction func addGroupButtonPressed(sender: AnyObject) {
        self.presentViewController(alert, animated: true, completion: nil)
    }

}