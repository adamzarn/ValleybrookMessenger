//
//  LoginViewController.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/6/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginAsChurchMemberButton: UIButton!
    @IBOutlet weak var loginAsAdministratorButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var createProfileButton: UIButton!
    
    let loginAsAdminError = UIAlertController(title: "Unauthorized", message: "You are not an administrator.", preferredStyle: UIAlertControllerStyle.Alert)
    
    let ref = FIRDatabase.database().reference()
    var loggingInAsAdmin = false
    
    override func viewDidLoad() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        emailTextField.text = "adam.zarn@my.wheaton.edu"
        passwordTextField.text = "Dukiebaby1"
        
        loginAsChurchMemberButton.setTitleColor(appDelegate.darkValleybrookBlue, forState: .Normal)
        loginAsAdministratorButton.setTitleColor(appDelegate.darkValleybrookBlue, forState: .Normal)
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        emailTextField.autocorrectionType = .No
        passwordTextField.autocorrectionType = .No
        
        setUp(emailTextField)
        setUp(passwordTextField)
        setUp(loginAsChurchMemberButton)
        setUp(loginAsAdministratorButton)
        
        activityIndicatorView.hidden = true
        
        createProfileButton.setTitleColor(appDelegate.darkValleybrookBlue, forState: .Normal)
        
        loginAsAdminError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
    }
    
    func setUp(object: AnyObject?) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        object!.layer.cornerRadius = 5
        object!.layer.borderColor = appDelegate.lightValleybrookBlue.CGColor
        object!.layer.borderWidth = 1
    }
    
    func login() {
        activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
        let email = emailTextField.text
        let password = passwordTextField.text
        FIRAuth.auth()?.signInWithEmail(email!, password: password!) { (user, error) in
            if let user = user {
                self.signedIn(user)
            } else {
                print(error!.localizedDescription)
                return
            }
        }
        
    }
    
    @IBAction func loginAsChurchMemberButtonPressed(sender: AnyObject) {
        login()
    }
    
    @IBAction func loginAsAdministratorButtonPressed(sender: AnyObject) {
        loggingInAsAdmin = true
        login()
    }
    
    func signedIn(user: FIRUser?) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.uid = user!.uid
        appDelegate.email = user!.email
        
        let userRef = self.ref.child("Users").child(appDelegate.uid!)
        
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let user = snapshot.value!
            appDelegate.phone = user["phone"] as? String
            })
        
        var admin = false

        if loggingInAsAdmin {
            
            self.ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
                let usersTable = snapshot.value!["Users"]! as! NSDictionary
                if let userInfo = usersTable[user!.uid] {
                    admin = userInfo["admin"] as! Bool
                    
                    if admin {
                        
                        MeasurementHelper.sendLoginEvent()
                        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
                        AppState.sharedInstance.photoUrl = user?.photoURL
                        AppState.sharedInstance.signedIn = true
                        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
                        
                        let GroupsTableVC = self.storyboard?.instantiateViewControllerWithIdentifier("NavigationController") as! UINavigationController
                        self.presentViewController(GroupsTableVC, animated: false, completion: nil)
                    } else {
                        
                        self.presentViewController(self.loginAsAdminError, animated: true, completion: nil)
                    
                    }
                    
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    
            }
                }, withCancelBlock: { error in
                    print(error.description)
            })
            
        } else {
            
            MeasurementHelper.sendLoginEvent()
            AppState.sharedInstance.displayName = user?.displayName ?? user?.email
            AppState.sharedInstance.photoUrl = user?.photoURL
            AppState.sharedInstance.signedIn = true
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
            
            let subscriptionsVC = storyboard?.instantiateViewControllerWithIdentifier("SubscriptionsTableViewController") as! SubscriptionsTableViewController
            subscriptionsVC.userEmail = user!.email!
            self.presentViewController(subscriptionsVC, animated: false, completion: nil)
            
            activityIndicatorView.stopAnimating()
            activityIndicatorView.hidden = true
            
        }
        
    }

    @IBAction func createProfileButtonPressed(sender: AnyObject) {
        let createProfileVC = self.storyboard?.instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
        self.presentViewController(createProfileVC, animated: false, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.becomeFirstResponder()
        if passwordTextField.editing {
            textField.secureTextEntry = true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if passwordTextField == textField {
            if textField.text == "" {
                textField.secureTextEntry = false
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if passwordTextField.editing {
            if textField.text == "" {
                textField.secureTextEntry = false
            }
        }
        textField.resignFirstResponder()
        return true
    }

    
    
    
}
