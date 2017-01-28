//
//  NetworkCalls.swift
//  Quick JSON
//
//  Created by Beau Young on 31/03/2016.
//  Copyright © 2016 Pear Pi. All rights reserved.
//

import UIKit


class NetworkCalls: NSObject {
    
    let jsonURL = "http://britanniaclub.co.uk/app/json/blogs2.json?\(arc4random())"
    
    
    
    func items(items: [Item] -> ()) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(NSURL(string: jsonURL)!) { (data, response, error) in
            
            if let jsonData = data {
                do {
                    print(self.jsonURL)
                    
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .AllowFragments)
                    if let itemArray = jsonDictionary["data"] as? [[String:AnyObject]] {
                        
                        
                        
                        let completeItems = itemArray.map {Item(dictionary: $0)}
                        dispatch_async(dispatch_get_main_queue(), {
                            items(completeItems)
                            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                            
                           
                        })
                       
                        return
                    }
                } catch {}
            }
            
            items([Item]())
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }.resume()
    }
    
}
