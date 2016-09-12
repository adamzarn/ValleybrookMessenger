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
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var createProfileButton: UIButton!
    
    let loginAsAdminError = UIAlertController(title: "Unauthorized.", message: "You are not an administrator.", preferredStyle: UIAlertControllerStyle.Alert)
    let loginError = UIAlertController(title: "Bad Email or Password.", message: "Please try again or create an account.", preferredStyle: UIAlertControllerStyle.Alert)
    
    let ref = FIRDatabase.database().reference()
    var loggingInAsAdmin = false
    
    override func viewDidLoad() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        loginAsChurchMemberButton.setTitleColor(appDelegate.darkValleybrookBlue, forState: .Normal)
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        emailTextField.autocorrectionType = .No
        passwordTextField.autocorrectionType = .No

        setUpTextField(emailTextField, bc: UIColor.clearColor())
        setUpTextField(passwordTextField, bc: UIColor.clearColor())
        setUpButton(loginAsChurchMemberButton, bc: appDelegate.veryLightValleybrookBlue)
        
        activityIndicatorView.hidden = true
        
        createProfileButton.setTitleColor(appDelegate.darkValleybrookBlue, forState: .Normal)
        
        loginAsAdminError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        loginError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
    }
    
    func setUpTextField(object: UITextField, bc: UIColor) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        object.layer.cornerRadius = 5
        object.layer.borderColor = appDelegate.lightValleybrookBlue.CGColor
        object.layer.borderWidth = 2
        object.backgroundColor = bc
    }
    
    func setUpButton(object: UIButton, bc: UIColor) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        object.layer.cornerRadius = 5
        object.layer.borderColor = appDelegate.lightValleybrookBlue.CGColor
        object.layer.borderWidth = 2
        object.backgroundColor = bc
    }
    
    func login() {
        activityIndicatorView.startAnimating()
        activityIndicatorView.hidden = false
        let email = emailTextField.text
        let password = passwordTextField.text
        FIRAuth.auth()?.signInWithEmail(email!, password: password!) { (user, error) in
            if let user = user {
                self.signedIn(user)
            } else {
                print(error!.localizedDescription)
                self.activityIndicatorView.hidden = true
                self.activityIndicatorView.stopAnimating()
                self.presentViewController(self.loginError, animated: true, completion: nil)
                return
            }
        }
    }
    
    @IBAction func loginAsChurchMemberButtonPressed(sender: AnyObject) {
        self.view.endEditing(true)
        login()
    }
    
    func signedIn(user: FIRUser?) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.uid = user!.uid
        appDelegate.email = user!.email
        
        let userRef = self.ref.child("Users").child(appDelegate.uid!)
        
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let theUser = snapshot.value!
            appDelegate.phone = theUser["phone"] as? String
            appDelegate.name = theUser["name"] as? String
            appDelegate.admin = theUser["admin"] as! Bool
            
            MeasurementHelper.sendLoginEvent()
            AppState.sharedInstance.displayName = user?.displayName ?? user?.email
            AppState.sharedInstance.photoUrl = user?.photoURL
            AppState.sharedInstance.signedIn = true
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
            
            let navController = self.storyboard?.instantiateViewControllerWithIdentifier("NavigationController") as! UINavigationController
            self.presentViewController(navController, animated: false, completion: nil)
            
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.hidden = true
            
            
            })
        
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
