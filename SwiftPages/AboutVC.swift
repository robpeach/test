//
//  AboutVC.swift
//  Britannia v2
//
//  Created by Rob Mellor on 10/08/2016.
//  Copyright © 2016 Robert Mellor. All rights reserved.
//

import UIKit
import Foundation
import MessageUI

class AboutVC: UIViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func findusButton(sender: AnyObject) {
        
        UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?address=198,HighStreet,Scunthorpe.DN156EA")!)
        
        
        
    }
    
    
    @IBAction func sendEmailButtonTapped(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {

            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.view.window!.rootViewController?.presentViewController(mailComposeViewController, animated: true, completion: nil)
            })
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["britannia.bar@gmail.com"])
        mailComposerVC.setSubject("")
        mailComposerVC.setMessageBody("Sent from The Britannia App - We aim to reply within 24 hours.", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }

    @IBAction func movetoChatBtn(sender: AnyObject) {
        
        print("button pressed")
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : ChatVC = storyboard.instantiateViewControllerWithIdentifier("ChatView") as! ChatVC
       // vc.teststring = "hello"
        
        let navigationController = UINavigationController(rootViewController: vc)
        
        self.presentViewController(navigationController, animated: true, completion: nil)
        
    }


    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
