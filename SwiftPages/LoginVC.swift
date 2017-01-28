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
                    
                    self.loginLabel.text = "Logged in"
                    loginButton.alpha = 0
                    Pushbots.sharedInstance().setAlias("\(email)");
                    
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
    
  

        
}

