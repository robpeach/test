//
//  BaseService.swift
//  Britannia v2
//
//  Created by Rob Mellor on 10/07/2016.
//  Copyright © 2016 Robert Mellor. All rights reserved.
//

import Foundation
import Firebase
import FBSDKShareKit
import FBSDKLoginKit
import FBSDKCoreKit

let BASE_URL = "https://britannia.firebaseio.com"

let FIREBASE_REF = FIRDatabase.database().reference()


//var CURRENT_USER: Firebase
//{
//    let userID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as? String
//    if let userId = userID {
//        let currentUser = Firebase(url: "\(FIREBASE_REF)").childByAppendingPath("users").childByAppendingPath(userId)
//        return currentUser
//    }
//    else{
//        return nil
//    }
