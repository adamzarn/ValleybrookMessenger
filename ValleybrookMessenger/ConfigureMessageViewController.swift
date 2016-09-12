//
//  ConfigureMessageViewController.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/6/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import MessageUI
import Firebase

class ConfigureMessageViewController: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    let ref = FIRDatabase.database().reference()
    
    var emailRecipients: [String] = []
    var textRecipients: [String] = []
    
    @IBOutlet weak var sendEmailButton: UIBarButtonItem!
    @IBOutlet weak var sendTextButton: UIBarButtonItem!
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var subjectTextField: MyTextField!
    @IBOutlet weak var groupsTableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var recipientsLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    let sendMailErrorAlert = UIAlertController(title: "Cannot Send Email", message: "Your device cannot send e-mail. Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.Alert)
    let sendTextErrorAlert = UIAlertController(title: "Cannot Send Text", message: "Your device cannot send texts. Please check text configuration and try again.", preferredStyle: UIAlertControllerStyle.Alert)
    
    var groups: [String:Int] = [:]
    var groupKeys: [String] = []
    var groupCounts: [Int] = []

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
        activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
        updateGroups()
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    func getLabelRect(label: UILabel) -> CGRect {
        return CGRectMake(label.frame.origin.x,label.frame.origin.y + 9.0, label.frame.width,label.frame.height)
    }
    
    func didTapView() {
        self.view.endEditing(true)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! CustomRecipientsCell
        
        cell.group.textColor = UIColor.blackColor()
        cell.members.textColor = UIColor.blackColor()
        cell.subscribed.enabled = true
        
        groupKeys = []
        groupCounts = []
        
        for (key,value) in groups {
            groupKeys.append(key)
            groupCounts.append(value)
        }

        cell.setCell(groupKeys[indexPath.row], subscribed: false)
        
        if groupCounts[indexPath.row] == 1 {
            cell.members.text = "1 member"
        } else {
            cell.members.text = "\(groupCounts[indexPath.row]) members"
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
    
    @IBAction func sendEmailButtonTapped(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: false, completion: nil)
        } else {
            self.presentViewController(sendMailErrorAlert, animated: false, completion: nil)
        }
    }
    
    @IBAction func sendTextButtonTapped(sender: AnyObject) {
        let textMessageViewController = configuredMessageComposeViewController()
        if MFMessageComposeViewController.canSendText() {
            self.presentViewController(textMessageViewController, animated: false, completion: nil)
        } else {
            self.presentViewController(sendTextErrorAlert, animated: false, completion: nil)
        }
    }
    
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
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
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

    @IBAction func resetButtonPressed(sender: AnyObject) {
        subjectTextField.text = "Subject"
        subjectTextField.textColor = UIColor.lightGrayColor()
        messageTextView.text = "Type message here..."
        messageTextView.textColor = UIColor.lightGrayColor()
        myTableView.reloadData()
    }
    
}