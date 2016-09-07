//
//  LoginViewController.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/6/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailOrPhoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginAsChurchMemberButton: UIButton!
    @IBOutlet weak var loginAsAdministratorButton: UIButton!
    @IBOutlet weak var createProfileButton: UIButton!
    
    override func viewDidLoad() {
        self.emailOrPhoneTextField.delegate = self
        self.passwordTextField.delegate = self
        emailOrPhoneTextField.autocorrectionType = .No
        passwordTextField.autocorrectionType = .No
        
        loginAsChurchMemberButton.layer.cornerRadius = 5
        loginAsAdministratorButton.layer.cornerRadius = 5
        
    }
    
    @IBAction func loginAsChurchMemberButtonPressed(sender: AnyObject) {
        let subscriptionsVC = self.storyboard?.instantiateViewControllerWithIdentifier("SubscriptionsTableViewController") as! SubscriptionsTableViewController
        self.presentViewController(subscriptionsVC, animated: false, completion: nil)
    }
    
    @IBAction func loginAsAdministratorButtonPressed(sender: AnyObject) {
        let configureMessageVC = self.storyboard?.instantiateViewControllerWithIdentifier("NavigationController") as! UINavigationController
        self.presentViewController(configureMessageVC, animated: false, completion: nil)
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
