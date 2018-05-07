//
//  TableView_cellcompletevideo.swift
//  CoInQ
//
//  Created by hui on 2017/7/19.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import UIKit

class TableView_cellcompletevideo: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var videoname: UILabel!
    @IBOutlet weak var videolength: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
