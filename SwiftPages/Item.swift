//
//  Item.swift
//  Quick JSON
//
//  Created by Beau Young on 31/03/2016.
//  Copyright © 2016 Pear Pi. All rights reserved.
//

import UIKit

class Item: NSObject {
    
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
