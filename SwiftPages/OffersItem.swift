//
//  OffersItem.swift
//  Britannia v2
//
//  Created by Rob Mellor on 09/08/2016.
//  Copyright © 2016 Robert Mellor. All rights reserved.
//

import UIKit

class OffersItem: NSObject {

    var name: String?
    var imageURL: NSURL?
    var title: String?
    var des: String?
    var pageURL: NSURL?
    
    init(dictionary: [String:AnyObject]) {
        name = dictionary["name"] as? String
        imageURL = NSURL(string: (dictionary["imageurl"] as? String)!)!
        title = dictionary["title"] as? String
        des = dictionary["des"] as? String
        pageURL = NSURL(string: (dictionary["pageurl"] as? String)!)!
        
}

}