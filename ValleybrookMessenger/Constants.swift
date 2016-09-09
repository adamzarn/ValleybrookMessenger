//
//  Constants.swift
//  ValleybrookMessenger
//
//  Created by Adam Zarn on 9/7/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

struct Constants {
    
    struct NotificationKeys {
        static let SignedIn = "onSignInCompleted"
    }
    
    struct Segues {
        static let SignInToFp = "SignInToFP"
        static let FpToSignIn = "FPToSignIn"
    }
    
    struct MessageFields {
        static let name = "name"
        static let text = "text"
        static let photoUrl = "photoUrl"
        static let imageUrl = "imageUrl"
    }

}
