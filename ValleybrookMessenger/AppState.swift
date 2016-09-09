//
//  AppState.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/7/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

import Foundation

class AppState: NSObject {
    
    static let sharedInstance = AppState()
    
    var signedIn = false
    var displayName: String?
    var photoUrl: NSURL?
}
