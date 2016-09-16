//
//  Methods.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/16/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import UIKit

class Methods: NSObject {
    
    func formatPhoneNumber(phone:String) -> String {
        
        let a = phone.substringWithRange(phone.startIndex ..< phone.startIndex.advancedBy(3))
        let b = phone.substringWithRange(phone.startIndex.advancedBy(3) ..< phone.startIndex.advancedBy(6))
        let c = phone.substringWithRange(phone.startIndex.advancedBy(6) ..< phone.startIndex.advancedBy(10))
        return "(\(a)) \(b)-\(c)"
    }
    
    func undoPhoneNumberFormat(formattedPhone:String) -> String {
        
        if formattedPhone.characters.count == 14 {
            let a = formattedPhone.substringWithRange(formattedPhone.startIndex.advancedBy(1) ..< formattedPhone.startIndex.advancedBy(4))
            let b = formattedPhone.substringWithRange(formattedPhone.startIndex.advancedBy(6) ..< formattedPhone.startIndex.advancedBy(9))
            let c = formattedPhone.substringWithRange(formattedPhone.startIndex.advancedBy(10) ..< formattedPhone.startIndex.advancedBy(14))
            return "\(a)\(b)\(c)"
        } else {
            return ""
        }
        
    }
    
    func toggleActivityIndicator(activityIndicatorView: UIActivityIndicatorView) {
        
        if activityIndicatorView.isAnimating() {
            activityIndicatorView.hidden = true
            activityIndicatorView.stopAnimating()
        } else {
            activityIndicatorView.startAnimating()
            activityIndicatorView.hidden = false
        }
    }
    
    static let sharedInstance = Methods()
    private override init() {
        super.init()
    }
}
