//
//  CSCL.swift
//  CoInQ
//
//  Created by hui on 2017/5/2.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import UIKit

class CSCL: UITabBarController{    
    
    @IBAction func signOut(_ sender: AnyObject) {
        
        if !UserDefaults.standard.dictionaryRepresentation().isEmpty{
            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                UserDefaults.standard.removeObject(forKey: key.description)
            }
        }
        
        GIDSignIn.sharedInstance().signOut()
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    func signout() {
        
        if !UserDefaults.standard.dictionaryRepresentation().isEmpty{
            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                UserDefaults.standard.removeObject(forKey: key.description)
            }
        }
        
        GIDSignIn.sharedInstance().signOut()
        _ = self.navigationController?.popViewController(animated: true)
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "CSCL"
        
        let navigationBar = navigationController!.navigationBar
        navigationBar.tintColor = UIColor.blue
        
        let leftButton =  UIBarButtonItem(title: "登出", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CSCL.signout))
        
        navigationItem.leftBarButtonItem = leftButton

        //GIDSignIn.sharedInstance().uiDelegate = self
    }

}
