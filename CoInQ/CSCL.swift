//
//  CSCL.swift
//  CoInQ
//
//  Created by hui on 2017/5/2.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import UIKit
import  GoogleSignIn

class CSCL: UITabBarController{    
    
    @IBAction func signOut(_ sender: AnyObject) {
        
        if !UserDefaults.standard.dictionaryRepresentation().isEmpty{
            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                UserDefaults.standard.removeObject(forKey: key.description)
            }
        }
        
        GIDSignIn.sharedInstance().signOut()
        let deleteAlert = UIAlertController(title:"確定要登出CoInQ嗎？",message: "可以進行新一輪的探究喔！", preferredStyle: .alert)
        deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:{ (action) -> Void in
            SignInViewController().log("lgo",google_userid)
            self.navigationController?.popViewController(animated: true)
        }))
        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = google_username.appending(" の探究歷程")
        /*UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12)], for: .normal)
        self.title = "CSCL"
        
        let navigationBar = navigationController!.navigationBar
        navigationBar.tintColor = UIColor.blue
        
        let leftButton =  UIBarButtonItem(title: "登出", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CSCL.signout))
        
        navigationItem.leftBarButtonItem = leftButton*/

        //GIDSignIn.sharedInstance().uiDelegate = self
    }

}
