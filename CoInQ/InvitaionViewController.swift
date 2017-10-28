//
//  InvitaionViewController.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation

class InvitaionViewController : UIViewController{
    
    @IBOutlet weak var googleSignInEmail: UILabel!
    override func viewDidLoad() {
        let text = "\(google_username)\n\(google_useremail)\n敬請期待"
        googleSignInEmail.text = text
        super.viewDidLoad()
    }
}
