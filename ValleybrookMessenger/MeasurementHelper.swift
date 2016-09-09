//
//  MeasurementHelper.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/7/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Firebase

class MeasurementHelper: NSObject {
    
    static func sendLoginEvent() {
        FIRAnalytics.logEventWithName(kFIREventLogin, parameters: nil)
    }
    
    static func sendLogoutEvent() {
        FIRAnalytics.logEventWithName("logout", parameters: nil)
    }
    
    static func sendMessageEvent() {
        FIRAnalytics.logEventWithName("message", parameters: nil)
    }
}
