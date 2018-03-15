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

extension InvitaionViewController : UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let num = FinalVideoArray?.count
        if num == nil || num == 0 {
            VideoTableView.backgroundView = TableEmpty
            return 0
        } else {
            VideoTableView.backgroundView = nil
            return num!
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: TableView_cellcompletevideo
        
        cell = tableView.dequeueReusableCell(withIdentifier: "cellvideocomplete", for: indexPath) as! TableView_cellcompletevideo
        guard let finalvideo = FinalVideoArray?[indexPath.row] as? [String: Any] else {
            print("Get row \(indexPath.row) error")
            return cell
        }
        cell.videoname.text = finalvideo["videoname"] as? String
        cell.videolength.text = finalvideo["videolength"] as? String
        let finalvideoURL = finalvideo["finalvideopath"] as? String
        //影片縮圖
        let videoURL = URL(string: finalvideoURL!)
        let asset = AVURLAsset(url: videoURL!, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = false
        
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            cell.thumbnail.image = thumbnail
            
        } catch let error {
            print("*** Error generating thumbnail: \(error)")
        }
        
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        
        if editingStyle == .delete {
            
            let deleteAlert = UIAlertController(title:"確定要刪除影片嗎？",message: "刪除影片後無法復原！", preferredStyle: .alert)
            deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:{ (action) -> Void in
                let finalvideo = self.FinalVideoArray?[indexPath.row] as? [String: Any]
                let videoid = finalvideo?["id"] as? Int
                lognote("dfv", google_userid, "\(videoid!)")
                self.deleteData(id: videoid!)
                
                self.loadData()
            }))
            let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
            deleteAlert.addAction(cancelAction)
            self.present(deleteAlert, animated: true, completion: nil)
            
            
        }
    }

    
}
