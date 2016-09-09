//
//  CreateProfileViewController.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/6/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class CreateProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var navItem: UINavigationItem!
    
    let createProfileErrorAlert = UIAlertController(title: "Error", message: "Error", preferredStyle: UIAlertControllerStyle.Alert)
    
    let ref = FIRDatabase.database().reference()
    
    var comingFromLogin = true

    override func viewDidLoad() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        createProfileErrorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        emailTextField.delegate = self
        phoneTextField.delegate = self
        passwordTextField.delegate = self
        verifyPasswordTextField.delegate = self
        
        setUp(nameTextField)
        setUp(emailTextField)
        setUp(phoneTextField)
        setUp(passwordTextField)
        setUp(verifyPasswordTextField)
        
        submitButton.setTitleColor(appDelegate.darkValleybrookBlue, forState: .Normal)
        
        verifyPasswordTextField.enabled = false
        
        activityIndicatorView.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if comingFromLogin {
            
        } else {
            navItem.title = "Edit Profile"
            passwordTextField.hidden = true
            verifyPasswordTextField!.hidden = true
            passwordTextField!.enabled = false
            verifyPasswordTextField!.enabled = false
            submitButton.setTitle("Submit Changes", forState: .Normal)

            let userRef = self.ref.child("Users").child(appDelegate.uid!)
            
            userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                let user = snapshot.value!
                self.nameTextField.text = user["name"] as? String
                self.emailTextField.text = user["email"] as? String
                self.phoneTextField.text = user["phone"] as? String
            })
        }
    }

    
    func setUp(object: AnyObject?) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        object!.layer.cornerRadius = 5
        object!.layer.borderColor = appDelegate.lightValleybrookBlue.CGColor
        object!.layer.borderWidth = 1
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        activityIndicatorView.startAnimating()
        activityIndicatorView.hidden = false
        
        if comingFromLogin {
        
            if passwordTextField.text == verifyPasswordTextField.text {
                let email = emailTextField.text
                let password = passwordTextField.text
                FIRAuth.auth()?.createUserWithEmail(email!, password: password!) { (user, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        self.createProfileErrorAlert.message = error.localizedDescription
                        self.presentViewController(self.createProfileErrorAlert, animated: true, completion: nil)
                        return
                    }
                    self.setDisplayName(user!)
                }
            } else {
                self.createProfileErrorAlert.message = "The second password does not match the first."
                self.presentViewController(self.createProfileErrorAlert, animated: true, completion: nil)
            }
            
        } else {
            
            let userRef = self.ref.child("Users").child(appDelegate.uid!)
            
            userRef.updateChildValues(["name":nameTextField.text!,
                                        "email":emailTextField.text!,
                                        "phone":phoneTextField.text!])
            
            let subscriptionsVC = storyboard?.instantiateViewControllerWithIdentifier("SubscriptionsTableViewController") as! SubscriptionsTableViewController
            self.presentViewController(subscriptionsVC, animated: false, completion: nil)
            
            activityIndicatorView.hidden = true
            activityIndicatorView.stopAnimating()
            
        }
        
    }
    
    func setDisplayName(user: FIRUser) {
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = user.email!.componentsSeparatedByString("@")[0]
        changeRequest.commitChangesWithCompletion(){ (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.signedIn(FIRAuth.auth()?.currentUser)
        }
    }
    
    func signedIn(user: FIRUser?) {
        let newUser = User(uid: user!.uid, name: nameTextField.text!, email: user!.email!, phone: phoneTextField.text!, admin: false)
        let userRef = self.ref.childByAppendingPath("Users/\(user!.uid)")
        userRef.setValue(newUser.toAnyObject())
        
        MeasurementHelper.sendLoginEvent()
        
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.photoUrl = user?.photoURL
        AppState.sharedInstance.signedIn = true
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
        let subscriptionsVC = storyboard?.instantiateViewControllerWithIdentifier("SubscriptionsTableViewController") as! SubscriptionsTableViewController
        subscriptionsVC.userEmail = user!.email!
        self.presentViewController(subscriptionsVC, animated: false, completion: nil)
        
        activityIndicatorView.hidden = true
        activityIndicatorView.stopAnimating()
        
    }

    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.becomeFirstResponder()
        if passwordTextField.editing || verifyPasswordTextField.editing {
            textField.secureTextEntry = true
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if passwordTextField == textField || verifyPasswordTextField == textField {
            if textField.text == "" {
                textField.secureTextEntry = false
            }
        }
        if passwordTextField.text != "" {
            verifyPasswordTextField.enabled = true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if passwordTextField.editing || verifyPasswordTextField.editing {
            if textField.text == "" {
                textField.secureTextEntry = false
            }
        }
        textField.resignFirstResponder()
        return true
    }
    

    @IBAction func passwordChanged(sender: AnyObject) {
        if passwordTextField.text != "" {
            verifyPasswordTextField.enabled = true
        } else {
            verifyPasswordTextField.enabled = false
        }
    }


}
