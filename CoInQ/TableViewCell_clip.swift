//
//  TableViewCell_clip.swift
//  CoInQ
//
//  Created by hui on 2018/1/5.
//  Copyright © 2018年 NTNUCSCL. All rights reserved.
//

import UIKit
import AVFoundation

class TableViewCell_clip: UITableViewCell {

    @IBOutlet weak var time: UILabel?
    @IBOutlet weak var pictureImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    
    
//    var item: Clips? {
//        didSet {
//            guard let item = item else {
//                print("nothing")
//                return
//            }
//            if let picture = item.pictureUrl {
//                pictureImageView?.image = picture
//            }
//            let username = "作者：".appending(item.name!)
//            nameLabel?.text = username
//            time?.text = item.time
//        }
//    }
//    static var nib:UINib {
//        return UINib(nibName: identifier, bundle: nil)
//    }
//    static var identifier: String {
//        return String(describing: self)
//    }
    
    func commonInit(_ username: String, videopath: String, times: String) {
        let videopath = videopath
        let videourl = URL(string: videopath)
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
        
        let name = "作者：".appending(username) 
        nameLabel?.text = name
        time?.text = times
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        

//        pictureImageView?.layer.cornerRadius = 40
//        pictureImageView?.clipsToBounds = true
//                pictureImageView?.contentMode = .scaleAspectFit
        //        pictureImageView?.backgroundColor = UIColor.lightGray
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        
//        pictureImageView?.image = nil
//    }

    
}
