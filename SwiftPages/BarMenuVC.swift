//
//  BarMenuVC.swift
//  Britannia v2
//
//  Created by Rob Mellor on 12/07/2016.
//  Copyright © 2016 Robert Mellor. All rights reserved.
//

import UIKit

class BarMenuVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    
    
    @IBAction func btnBackTapped(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    
        }

    
    
    
    

}
