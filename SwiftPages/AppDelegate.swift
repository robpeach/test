//
//  AppDelegate.swift
//  SwiftPages
//
//  Created by Gabriel Alvarado on 5/21/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import AVFoundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, AVAudioPlayerDelegate {

    var window: UIWindow?
    var storyboard : UIStoryboard?;
    var audioPlayer = AVPlayer()
    
    
    
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle());
        
        
        FIRApp.configure()
        
        
        
        
        
        //login
        let launchedBefore = NSUserDefaults.standardUserDefaults().boolForKey("launchedB4-2.1.0.22")
        if launchedBefore  {
            // not initial launch
            self.window?.rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("tabBarController");
            
            
            
            
            print("Not first launch.")
        }
        else {
            
            self.window?.rootViewController = self.storyboard?.instantiateViewControllerWithIdentifier("firstLaunchedController");
            print("First launch, setting NSUserDefault.")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedB4-2.1.0.22")
            
        }
        
        
        
        
        
        
        
        
        
        
        // Override point for customization after application launch.
        FBSDKAccessToken.currentAccessToken()
        
        //PushBots
        _ = Pushbots(appId:"56eefefe37d9b0965e8b456b", prompt: true);
        
        
        //Track Push notification opens while launching the app form it
        Pushbots.sharedInstance().trackPushNotificationOpenedWithPayload(launchOptions);
        
        if launchOptions != nil {
            if let userInfo = launchOptions![UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
                //Capture notification data e.g. badge, alert and sound
                if let aps = userInfo["aps"] as? NSDictionary {
                    let alert = aps["alert"] as! String
                    print("Notification message: ", alert);
                    //UIAlertView(title:"Push Notification!", message:alert, delegate:nil, cancelButtonTitle:"OK").show()
                }
                
                //Capture custom fields
                if let articleId = userInfo["articleId"] as? NSString {
                    print("ArticleId: ", articleId);
                    //UIAlertView(title:"Push Notification!", message:articleId as String, delegate:nil, cancelButtonTitle:"OK").show()
                }
            }
        }

        
        
        
        
        //Music
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
        
        return FBSDKApplicationDelegate.sharedInstance()
            .application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    //Pushbots
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        //Track notification only if the application opened from Background by clicking on the notification.
        if application.applicationState == .Inactive  {
            Pushbots.sharedInstance().trackPushNotificationOpenedWithPayload(userInfo);
        }
        
        //The application was already active when the user got the notification, just show an alert.
        //That should *not* be considered open from Push.
        if application.applicationState == .Active  {
            //Capture notification data e.g. badge, alert and sound
            if let aps = userInfo["aps"] as? NSDictionary {
                let alert = aps["alert"] as! String
                UIAlertView(title:"Push Notification!", message:alert, delegate:nil, cancelButtonTitle:"OK").show()
            }
        }
        
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // This method will be called everytime you open the app
        // Register the deviceToken on Pushbots
        Pushbots.sharedInstance().registerOnPushbots(deviceToken);
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Notification Registration Error: ", error);
    }
    
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
//Facebook
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(
            app,
            openURL: url,
            sourceApplication: options["UIApplicationOpenURLOptionsSourceApplicationKey"] as! String,
            annotation: nil)
    }
    
    
//    func changeRootViewControllerWithIdentifier(identifier:String!) {
//        let storyboard = self.window?.rootViewController?.storyboard
//        let desiredViewController = storyboard?.instantiateViewControllerWithIdentifier(identifier);
//        
//        let snapshot:UIView = (self.window?.snapshotViewAfterScreenUpdates(true))!
//        desiredViewController?.view.addSubview(snapshot);
//        
//        self.window?.rootViewController = desiredViewController;
//        
//        UIView.animateWithDuration(0.5, animations: {() in
//            snapshot.layer.opacity = 0;
//            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
//            }, completion: {
//                (value: Bool) in
//                snapshot.removeFromSuperview();
//        });
//    }
    
    
    class func sharedAppDelegate() -> AppDelegate? {
        return UIApplication.sharedApplication().delegate as? AppDelegate;
    }
    
}
