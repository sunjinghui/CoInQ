//
//  TableView_cellinvite.swift
//  CoInQ
//
//  Created by hui on 2017/12/18.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import UIKit

class TableView_cellinvite: UITableViewCell {

    @IBOutlet weak var google_userimg: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var invitedcontext: UILabel!
    @IBOutlet weak var time: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
