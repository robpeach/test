//
//  WelcomeVC.swift
//  Britannia v2
//
//  Created by Rob Mellor on 10/07/2016.
//  Copyright © 2016 Robert Mellor. All rights reserved.
//

import UIKit
import SafariServices

class WelcomeVC: UIViewController, SFSafariViewControllerDelegate {
    @IBOutlet weak var joinclubBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //StatusBarColour
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        //LightContent
        return UIStatusBarStyle.LightContent
        
        //Default
        //return UIStatusBarStyle.Default
        
    }
    
    
    
    
//BritanniaClub
    @available(iOS 9.0, *)
    @IBAction func getcouponButton(sender: AnyObject) {
        
        
        let safariVC = SFSafariViewController(URL: NSURL(string: "https://d.pslot.io/l/y7ir42UTY")!)
        self.presentViewController(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
    
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

}
