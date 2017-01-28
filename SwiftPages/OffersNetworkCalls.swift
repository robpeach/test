//
//  OffersNetworkCalls.swift
//  Britannia v2
//
//  Created by Rob Mellor on 09/08/2016.
//  Copyright © 2016 Robert Mellor. All rights reserved.
//

import UIKit

class OffersNetworkCalls: NSObject {

    
    let jsonURL = "http://britanniaclub.co.uk/app/json/offers2.json?\(arc4random())"
    
    func items(items: [OffersItem] -> ()) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let session = NSURLSession.sharedSession()
        
        
        
        session.dataTaskWithURL(NSURL(string: jsonURL)!) { (data, response, error) in
            
            if let jsonData = data {
                do {
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
                    if let itemArray = jsonDictionary["data"] as? [[String:AnyObject]] {
                        
                        let completeItems = itemArray.map {OffersItem(dictionary: $0)}
                        dispatch_async(dispatch_get_main_queue(), {
                            items(completeItems)
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        })
                        
                        return
                    }
                } catch {}
            }
            
            items([OffersItem]())
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }.resume()
    }
    
}
