//
//  CSCL.swift
//  CoInQ
//
//  Created by hui on 2017/5/2.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import UIKit

class CSCL: UITabBarController{

    @IBOutlet weak var signoutButton: UIButton!
    
    
    @IBAction func signOut(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signOut()
        _ = self.navigationController?.popViewController(animated: true)
        //refreshedInterface()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //GIDSignIn.sharedInstance().uiDelegate = self
    }

}
