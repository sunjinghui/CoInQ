//
//  InviteCell.swift
//  CoInQ
//
//  Created by hui on 2017/12/25.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import UIKit
import AVFoundation

class InviteCell: UITableViewCell {

    @IBOutlet weak var invitedcontext: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    
    var item: Invite? {
        didSet {
            guard let item = item else {
                return
            }
            
            if let pictureUrl = item.img {
                //影片縮圖
                let videourl = URL(string: pictureUrl)
                let asset = AVURLAsset(url: videourl!, options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = false
                
                do {
                    let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    
                    pictureImageView?.image = thumbnail
                    
                } catch let error {
                    print("*** Error generating thumbnail: \(error)")
                }
            }
            
            nameLabel?.text = item.name
            time?.text = item.time
            invitedcontext?.text = item.context
        }
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pictureImageView?.layer.cornerRadius = 40
        pictureImageView?.clipsToBounds = true
        pictureImageView?.contentMode = .scaleAspectFit
        pictureImageView?.backgroundColor = UIColor.lightGray
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        pictureImageView?.image = nil
    }
}
