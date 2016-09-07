//
//  CreateProfileViewController.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/6/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class CreateProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!

    override func viewDidLoad() {
        
        emailTextField.delegate = self
        phoneTextField.delegate = self
        passwordTextField.delegate = self
        verifyPasswordTextField.delegate = self
        
        verifyPasswordTextField.enabled = false
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        if passwordTextField.text == verifyPasswordTextField.text {
            let subscriptionsVC = storyboard?.instantiateViewControllerWithIdentifier("SubscriptionsTableViewController") as! SubscriptionsTableViewController
            self.presentViewController(subscriptionsVC, animated: false, completion: nil)
        }
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
    
}
