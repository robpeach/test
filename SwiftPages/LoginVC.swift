//
//  LoginVC.swift
//  Britannia v2
//
//  Created by Rob Mellor on 10/07/2016.
//  Copyright © 2016 Robert Mellor. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit
import FirebaseCore

class LoginVC: UIViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var loginLabel: UILabel!
    
    
    var ref: FIRDatabaseReference!
    
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loginButton.delegate = self
        setupFacebookButton()
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        
        
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            
            FIRAuth.auth()?.signInWithCredential(credential, completion: { (user: FIRUser?, error: NSError?) in
                if error != nil {
                    self.loginButton.hidden = false
                    self.loginLabel.text = "Error logging in, please try again."
                    print(error!.localizedDescription)
                    return
                }
                print("User logged in with Facebook....")
                
                let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, picture.type(large)"])
                graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                    
                    if ((error) != nil) {
                        // Process error
                        print("Error: \(error)")
                    }
                  
                        print("fetched user: \(result)")
                        
                        // Facebook users name:
                        let userName:NSString = result.valueForKey("name") as! NSString
                        let displayName = userName
                        print("User Name is: \(displayName)")
                        
                        // Facebook users email:
                        let userEmail:NSString = result.valueForKey("email") as! NSString
                        let email = userEmail
                        print("User Email is: \(email)")
                        
                        // Facebook users ID:
                        let usersID:NSString = result.valueForKey("id") as! NSString
                        let id = usersID
                        print("Users Facebook ID is: \(id)")
                        
                        // Facebook users ID:
                        let userPicture = result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String

                        let profileImageURL = userPicture
                        print("Users Facebook Profile Image is is: \(profileImageURL)")
                
                    let newUser = FIRDatabase.database().reference().child("users").child(user!.uid)
                    newUser.setValue(["displayname": (displayName), "id": (id), "profileImageURL": (userPicture), "email": (email)])
                    
                    self.performSegueWithIdentifier("AutoLogin", sender: nil)
                    
                })
        
            
        })
    }
    
    
    func setupFacebookButton() {
        
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["email", "public_profile"]
        
    }
    
    
    
    
    
    
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        try! FIRAuth.auth()!.signOut()
        print("user logged out")
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        
        
        
        return true
    }
    
    
    
   
    
    
// func loginButtonPressed(loginbutton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
//       if error != nil {
//             print(error!.localizedDescription)
//        return
//                }
//
//      
//                self.loginButton.hidden = false
//                self.loginLabel.text = "Error logging in, please try again."
//
//                
//    
//    let facebookLogin = FBSDKLoginManager()
//                
//    facebookLogin.logInWithReadPermissions(["public_profile", "email"], fromViewController: self, handler: {
//        (facebookResult, facebookError) -> Void in
//        if facebookError != nil {
    
        
                    
//
//                        
//             
//                        print(FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid))
//                
////                        guard let uid = user?.uid else {
////                            return
////                        }
//                        
//                      
//                        
//                        FIRDatabase.database().reference().child("users").child().observeSingleEventOfType(.Value, withBlock: { (snapshot) in
//                            
//                 
//                            
//                            let displayName = snapshot.value?.objectForKey("displayname") as! NSString as String
//                            print(displayName)
//                            
//                            let userID = snapshot.value?.objectForKey("id") as! NSString as String
//                            print(userID)
//                            let photoURL = snapshot.value?.objectForKey("profileImageURL") as! NSString as String
//                            print(photoURL)
//                            
//    
//                           
//                            
//                            let newUser = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid)
//                            newUser.setValue(["displayname": "\(displayName)", "id": "\(userID)", "profileImageURL": "\(photoURL)"])
//                            
//                       
//                            self.performSegueWithIdentifier("AutoLogin", sender: nil)
                    
//                            })
//                    
//                    }})
//            }

    

                        
                       // print(user!.displayName!)
                       // print(user!.photoURL!)
                        
                        
                    
                        
                       
        
    
    
    
    func signedin(){
        
    }
    
    
    
//                    if error != nil {
//                        print("Login failed. \(error)")
//                    } else {
//                        
//                        self.loginButton.hidden = true
//                        self.loginLabel.text = "Logging in.."
//                        
//                        print("Logged in!")
//                  //      NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: KEY_UID)
//                        let userID = FIRAuth.auth()?.currentUser?.uid
//                        
//                        let rootRef = FIRDatabase.database().reference()
//                        let userRef = rootRef.child("users").child(userID!)
//                        
//                        userRef.observeEventType(.Value, withBlock: { snapshot in
//                            if snapshot.value is NSNull {
//                                let newUser = [
//                                    "providerId": user?.providerID,
//                                    "displayName": user?.displayName,
//                                    "email":user?.email,
//                                    "profileURL":user?.photoURL,
//                                    "providerID":user?.providerID,
//                                    "uid":user?.uid
//                                ]
//                                userRef.setValue((newUser as! AnyObject))
                    
                                
                                
                                
                                
                                
                                
                                
                                
                                // perform segue
//                                if FIRAuth.auth() != nil {
//                                    
//                                let email = FIRAuth.auth()?.currentUser?.email
//                                
//                                Pushbots.sharedInstance().setAlias("\(email!)");
                                
                 //   let appDelegate = AppDelegate.sharedAppDelegate()
    // appDelegate?.changeRootViewControllerWithIdentifier("tabBarController")
                                
                              
                                
                                
                                
                                
                                
                                
                                
//                                print(FIRAuth.auth()?.currentUser?.email)
//                                
//        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainVC") as! MainVC
//            self.presentViewController(vc, animated: true, completion: nil)
                                
                                    
                                    
           
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                //  self.performSegueWithIdentifier("AutoLogin", sender: nil)
                        
                                                                            //print("Logged in! \(authData)")
                                    
                                
                           // }
                     
                            
                            
                            
                            
                            
                            
                            
                            
                            
                            
//                            }
//                    })
//                    }}}
            
        
        
        
//        let facebookLogin = FBSDKLoginManager()
//        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self, handler: {
//            (facebookResult, facebookError) -> Void in
//            if facebookError != nil {
//                print("Facebook login failed. Error \(facebookError)")
//            } else if facebookResult.isCancelled {
//                print("Facebook login was cancelled.")
//            } else {
//                self.loginButton.hidden = true
//                self.loginLabel.text = "Logging in.."
//                
//                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
//                FIRAuth.authWithOAuthProvider("facebook", token: accessToken,
//                    withCompletionBlock: { error, authData in
//                        if error != nil {
//                            print("Login failed. \(error)")
//                            self.loginButton.hidden = false
//                            self.loginLabel.text = "Error logging in, please try again."
//                        } else {
//                            
//                            let newUser = [
//                                
//                                "provider": authData.provider,
//                                "id": authData.providerData["id"] as? NSString as? String,
//                                "displayName": authData.providerData["displayName"] as? NSString as? String,
//                                "email": authData.providerData["email"] as? NSString as? String,
//                                "profileImageURL": authData.providerData["profileImageURL"] as? NSString as? String,
//                                
//                            ]
//                            
//                            FIREBASE_REF.childByAppendingPath("users").childByAppendingPath(authData.uid).setValue(newUser)
//                            
//        
//                            
//                                    
//                                    if FIREBASE_REF.authData != nil {
//                                        
//                                        let email = authData.providerData["email"] as? NSString as? String
//                                        Pushbots.sharedInstance().setAlias("\(email!)");
//                                        
//                                       // let appDelegate = AppDelegate.sharedAppDelegate()
//                                       // appDelegate?.changeRootViewControllerWithIdentifier("tabBarController")
//                                        
//                                        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainVC") as! MainVC
//                                        self.presentViewController(vc, animated: true, completion: nil)
//                                        
//                                        
//                                        
//                                      //  self.performSegueWithIdentifier("AutoLogin", sender: nil)
//                                        print(FIREBASE_REF.authData.providerData)
//                                        //print("Logged in! \(authData)")
//        
//                            
//                            
//                                
//                                
//                            }
//                        }
//                })
//            }
//        })
//    }
    
    
    

//        })
//    }

        
}

