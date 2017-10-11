//
//  SignInViewController.swift
//  CoInQ
//
//  Created by hui on 2017/4/27.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import UIKit
import Alamofire

var google_userid = ""

class SignInViewController: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate
{
    
    let URL_USER_REGISTER = "http://140.122.76.201/CoInQ/v1/register.php"
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil{
            print(error)
            return
        }else{
            print(user.userID)
            //print(user.profile.name)
            //print(user.profile.email)
            //print(user.profile.imageURL(withDimension: 400))
            print("google sign in")
            
            google_userid = user.userID
            
            let parameters: Parameters=[
                "username":        user.profile.name,
                "google_userid":   user.userID,
                "email":           user.profile.email
            ]
            
            //Sending http post request
            Alamofire.request(URL_USER_REGISTER, method: .post, parameters: parameters).responseJSON
                {
                    response in
                    //printing response
                    print(response)
                    
                    //getting the json value from the server
//                    if let result = response.result.value {
//                        
//                        //converting it as NSDictionary
//                        let jsonData = result as! NSDictionary
//                        
//                        //displaying the message in label
//                        //self.labelMessage.text = jsonData.value(forKey: "message") as! String?
//                        print(jsonData.value(forKey: "message") as Any)
//                    }
            }
            
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

