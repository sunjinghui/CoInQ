//
//  SignInViewController.swift
//  CoInQ
//
//  Created by hui on 2017/4/27.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate
{
    @IBOutlet weak var welcomeLable: UILabel!


    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil{
            welcomeLable.text = error as? String
            return
        }else{
            print(user.userID)
            print(user.profile.email)
            print(user.profile.imageURL(withDimension: 400))
            self.performSegue(withIdentifier: "login", sender: self)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    
}

