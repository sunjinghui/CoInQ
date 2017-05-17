//
//  VideoTask.swift
//  CoInQ
//
//  Created by hui on 2017/5/12.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation

class VideoTaskViewController:UITabBarController{

    @IBAction func GoBack(){
                _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
