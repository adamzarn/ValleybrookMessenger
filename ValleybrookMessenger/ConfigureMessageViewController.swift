//
//  ConfigureMessageViewController.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/6/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import MessageUI

class ConfigureMessageViewController: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    //Outlets*******************************************************************
    
    @IBOutlet weak var sendEmailButton: UIBarButtonItem!
    @IBOutlet weak var sendTextButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var subjectTextField: MyTextField!
    @IBOutlet weak var groupsTableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var recipientsLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    //Alerts********************************************************************
    
    let dataErrorAlert:UIAlertController = UIAlertController(title: "Error", message: "Data could not be retrieved from the server. Try again later.",preferredStyle: UIAlertControllerStyle.Alert)
    let sendMailErrorAlert = UIAlertController(title: "Cannot Send Email", message: "Your device cannot send e-mail. Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.Alert)
    let sendTextErrorAlert = UIAlertController(title: "Cannot Send Text", message: "Your device cannot send texts. Please check text configuration and try again.", preferredStyle: UIAlertControllerStyle.Alert)
    
    //Local Variables***********************************************************
    
    var emailRecipients: [String] = []
    var textRecipients: [String] = []
    var groupsDict: [String:Int] = [:]
    var groupKeys: [String] = []
    var groupCounts: [Int] = []
    
    //Life Cycle Functions*******************************************************

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataErrorAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        myTableView.hidden = true
        Methods.sharedInstance.toggleActivityIndicator(self.activityIndicatorView)
        
        toolBar.translucent = false
        
        myTableView.allowsSelection = false
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        sendMailErrorAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil))
        sendTextErrorAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil))
        
        subjectTextField.delegate = self
        messageTextView.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(ConfigureMessageViewController.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        
        let recipientsView = UIView(frame: getLabelRect(recipientsLabel))
        self.view.addSubview(recipientsView)
        recipientsView.backgroundColor = appDelegate.darkValleybrookBlue
        let subjectView = UIView(frame: getLabelRect(subjectLabel))
        self.view.addSubview(subjectView)
        subjectView.backgroundColor = appDelegate.darkValleybrookBlue
        let messageView = UIView(frame: getLabelRect(messageLabel))
        self.view.addSubview(messageView)
        messageView.backgroundColor = appDelegate.darkValleybrookBlue
        print(recipientsView.frame.origin.y, subjectView.frame.origin.y, messageView.frame.origin.y)
        
        recipientsLabel.layer.zPosition = 1
        subjectLabel.layer.zPosition = 1
        messageLabel.layer.zPosition = 1
        
        subjectTextField.autocorrectionType = .No
        messageTextView.autocorrectionType = .No
        
        subjectTextField.textColor = UIColor.lightGrayColor()
        messageTextView.textColor = UIColor.lightGrayColor()
        
        messageTextView.textContainerInset = UIEdgeInsetsMake(5.0, 5.0, 0.0, 5.0)
        
        sendEmailButton.tintColor = appDelegate.darkValleybrookBlue
        sendTextButton.tintColor = appDelegate.darkValleybrookBlue
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        myTableView.hidden = true
        Methods.sharedInstance.toggleActivityIndicator(self.activityIndicatorView)
        getUserCount()
        updateGroups()
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
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

    func getLabelRect(label: UILabel) -> CGRect {
        return CGRectMake(label.frame.origin.x,label.frame.origin.y + 9.0, label.frame.width,label.frame.height)
    }
    
    func didTapView() {
        self.view.endEditing(true)
    }
    
    //Message Functions**********************************************************
    
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let textMessageVC = MFMessageComposeViewController()
        textMessageVC.messageComposeDelegate = self
        
        textMessageVC.recipients = appDelegate.textRecipients
        textMessageVC.body = messageTextView.text!
        
        return textMessageVC
        
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(appDelegate.emailRecipients)
        mailComposerVC.setSubject(subjectTextField.text!)
        mailComposerVC.setMessageBody(messageTextView.text!, isHTML: false)
        
        return mailComposerVC
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Keyboard Notifications**************************************************
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConfigureMessageViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification,object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ConfigureMessageViewController.keyboardWillHide(_:)),name: UIKeyboardWillHideNotification,object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self,name: UIKeyboardWillShowNotification,object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        view.frame.origin.y = -1*(getKeyboardHeight(notification))
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        let navBarHeight = self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.size.height
        
        view.frame.origin.y = navBarHeight
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        
        let navBarHeight = self.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.size.height
        
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height - navBarHeight
    }
    
    //Text Field Functions*******************************************************
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.becomeFirstResponder()
        if textField.text == "Subject" {
            textField.text = ""
            textField.textColor = UIColor.blackColor()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text == "" {
            textField.text = "Subject"
            textField.textColor = UIColor.lightGrayColor()
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text == "" {
            textField.text = "Subject"
            textField.textColor = UIColor.lightGrayColor()
        }
    }
    
    //Text View Functions*******************************************************
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.becomeFirstResponder()
        if textView.text == "Type message here..." {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        if textView.text == "" {
            textView.text = "Type message here..."
            textView.textColor = UIColor.lightGrayColor()
        }
        return true
    }
    
    //Table View Functions*******************************************************
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsDict.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! CustomRecipientsCell
        
        cell.group.textColor = UIColor.blackColor()
        cell.members.textColor = UIColor.blackColor()
        cell.subscribed.enabled = true
        
        groupKeys = []
        groupCounts = []
        
        let sortedGroupKeys = Array(groupsDict.keys).sort(<)
        
        for key in sortedGroupKeys {
            groupKeys.append(key)
            groupCounts.append(groupsDict[key]!)
        }
        
        if groupCounts[indexPath.row] == 1 {
            cell.members.text = "1 member"
        } else {
            cell.members.text = "\(groupCounts[indexPath.row]) members"
        }
        
        var attributedTitleText: NSMutableAttributedString?
        var attributedSubtitleText: NSMutableAttributedString?
        
        if groupKeys[indexPath.row] == "All Users" {
            attributedTitleText = NSMutableAttributedString(string: "All Users", attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(16)])
            attributedSubtitleText = NSMutableAttributedString(string: cell.members.text!, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(11)])
            cell.setCell(attributedTitleText!, subscribed: false)
            cell.members.attributedText = attributedSubtitleText
        } else {
            cell.group.text = groupKeys[indexPath.row]
            cell.subscribed.on = false
        }
        
        if groupCounts[indexPath.row] == 0 {
            cell.subscribed.enabled = false
            cell.group.textColor = UIColor.lightGrayColor()
            cell.members.textColor = UIColor.lightGrayColor()
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 45.0
    }

    //Actions*******************************************************************
    
    @IBAction func resetButtonPressed(sender: AnyObject) {
        subjectTextField.text = "Subject"
        subjectTextField.textColor = UIColor.lightGrayColor()
        messageTextView.text = "Type message here..."
        messageTextView.textColor = UIColor.lightGrayColor()
        myTableView.reloadData()
    }
    
    @IBAction func sendEmailButtonTapped(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: false, completion: nil)
        } else {
            self.presentViewController(sendMailErrorAlert, animated: false, completion: nil)
        }
    }
    
    @IBAction func sendTextButtonTapped(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDelegate.textRecipients.count > 10 {
            sendTextErrorAlert.message = "You cannot send texts to more than 10 people at once."
            self.presentViewController(sendTextErrorAlert,animated:true,completion: nil)
        } else {
            let textMessageViewController = configuredMessageComposeViewController()
            if MFMessageComposeViewController.canSendText() {
                self.presentViewController(textMessageViewController, animated: false, completion: nil)
            } else {
                self.presentViewController(sendTextErrorAlert, animated: false, completion: nil)
            }
        }
    }

}