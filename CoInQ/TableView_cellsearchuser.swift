//
//  TableView_cellsearchuser.swift
//  CoInQ
//
//  Created by hui on 2018/3/7.
//  Copyright © 2018年 NTNUCSCL. All rights reserved.
//

import Foundation

class TableView_cellsearchuser : UITableViewCell {
    
    @IBOutlet weak var username: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(text: String){
        username.text = text
    }
    
}
