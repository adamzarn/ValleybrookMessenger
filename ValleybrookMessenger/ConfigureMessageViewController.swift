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
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var subjectTextField: MyTextField!
    @IBOutlet weak var groupsTableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var recipientsLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    let sendMailErrorAlert = UIAlertController(title: "Cannot Send Email", message: "Your device cannot send e-mail. Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.Alert)
    let sendTextErrorAlert = UIAlertController(title: "Cannot Send Text", message: "Your device cannot send texts. Please check text configuration and try again.", preferredStyle: UIAlertControllerStyle.Alert)
    
    let groups = ["Food Pantry"
        ,"Facilities Teardown"
        ,"Tech Teardown"
        ,"Prayer"
        ,"Worship Team"
        ,"Small Groups"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendMailErrorAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil))
        sendTextErrorAlert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Default, handler: nil))
        
        subjectTextField.delegate = self
        messageTextView.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(ConfigureMessageViewController.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        
        let recipientsView = UIView(frame: getLabelRect(recipientsLabel))
        self.view.addSubview(recipientsView)
        recipientsView.backgroundColor = UIColor.grayColor()
        let subjectView = UIView(frame: getLabelRect(subjectLabel))
        self.view.addSubview(subjectView)
        subjectView.backgroundColor = UIColor.grayColor()
        let messageView = UIView(frame: getLabelRect(messageLabel))
        self.view.addSubview(messageView)
        messageView.backgroundColor = UIColor.grayColor()
        print(recipientsView.frame.origin.y, subjectView.frame.origin.y, messageView.frame.origin.y)

        recipientsLabel.layer.zPosition = 1
        subjectLabel.layer.zPosition = 1
        messageLabel.layer.zPosition = 1
        
        subjectTextField.autocorrectionType = .No
        messageTextView.autocorrectionType = .No
        
        subjectTextField.textColor = UIColor.lightGrayColor()
        messageTextView.textColor = UIColor.lightGrayColor()
        
        messageTextView.textContainerInset = UIEdgeInsetsMake(5.0, 5.0, 0.0, 5.0)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func getLabelRect(label: UILabel) -> CGRect {
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        let yShift = statusBarHeight + navBarHeight!
        return CGRectMake(label.frame.origin.x,label.frame.origin.y + yShift + 9.0, label.frame.width,label.frame.height)
    }
    
    func didTapView() {
        self.view.endEditing(true)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    @IBAction func logoutButtonPressed(sender: AnyObject) {
        let loginVC = storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.presentViewController(loginVC, animated: false, completion: nil)
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
        let textMessageVC = MFMessageComposeViewController()
        textMessageVC.messageComposeDelegate = self
        
        textMessageVC.recipients = ["6306778298"]
        textMessageVC.body = messageTextView.text!
        
        return textMessageVC
        
    }
    
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["adam.zarn@my.wheaton.edu"])
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
        view.frame.origin.y = -1*getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }

    @IBAction func resetButtonPressed(sender: AnyObject) {
        subjectTextField.text = "Subject"
        subjectTextField.textColor = UIColor.lightGrayColor()
        messageTextView.text = "Type message here..."
        messageTextView.textColor = UIColor.lightGrayColor()
        myTableView.reloadData()
    }

    
}