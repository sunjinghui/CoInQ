//
//  TableView_cellcooperate.swift
//  CoInQ
//
//  Created by hui on 2018/3/15.
//  Copyright © 2018年 NTNUCSCL. All rights reserved.
//

import UIKit

class TableView_cellcooperate : UITableViewCell {
    
    @IBOutlet weak var videoname: UILabel!
    @IBOutlet weak var context: UILabel!
    @IBOutlet weak var owner: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
