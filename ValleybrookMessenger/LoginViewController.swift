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
    
    let ref = FIRDatabase.database().reference()
    
    //Outlets*******************************************************************
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginAsChurchMemberButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var createProfileButton: UIButton!
    
    //Life Cycle Functions*******************************************************
    
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
        
        
        
    }
    
    //Methods*******************************************************************
    
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
        
        if Methods.sharedInstance.hasConnectivity() {
        
            Methods.sharedInstance.toggleActivityIndicator(self.activityIndicatorView)
            let email = emailTextField.text
            let password = passwordTextField.text
            FIRAuth.auth()?.signInWithEmail(email!, password: password!) { (user, error) in
                if let user = user {
                    self.signedIn(user)
                } else {
                    print(error!.localizedDescription)
                    Methods.sharedInstance.toggleActivityIndicator(self.activityIndicatorView)
                    
                    let loginError = UIAlertController(title: "Bad email or password.", message: "Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    loginError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(loginError, animated: true, completion: nil)
                    return
                }
            }
            
        } else {
            
            let networkConnectivityError = UIAlertController(title: "No Internet Connection", message: "Please check your connection.", preferredStyle: UIAlertControllerStyle.Alert)
            networkConnectivityError.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(networkConnectivityError, animated: true, completion: nil)
            
        }
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
            
            Methods.sharedInstance.toggleActivityIndicator(self.activityIndicatorView)
            
            })
        
    }
    
    //Text Field Functions*******************************************************

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

    //Actions*******************************************************************
    
    @IBAction func loginAsChurchMemberButtonPressed(sender: AnyObject) {
        self.view.endEditing(true)
        login()
    }
    
    @IBAction func createProfileButtonPressed(sender: AnyObject) {
        let createProfileVC = self.storyboard?.instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
        self.presentViewController(createProfileVC, animated: false, completion: nil)
    }
    
}
