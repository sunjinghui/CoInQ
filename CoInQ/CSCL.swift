//
//  CSCL.swift
//  CoInQ
//
//  Created by hui on 2017/5/2.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import UIKit

class CSCL: UITabBarController{    
    
    @IBAction func signOut(_ sender: UIButton) {
        
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

        //GIDSignIn.sharedInstance().uiDelegate = self
    }

}
