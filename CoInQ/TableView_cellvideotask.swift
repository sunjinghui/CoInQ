//
//  TableView_cellvideotask.swift
//  CoInQ
//
//  Created by hui on 2017/7/16.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import UIKit

class TableView_cellvideotask: UITableViewCell {

    @IBOutlet weak var VideoName: UILabel!
    @IBOutlet weak var Date: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
