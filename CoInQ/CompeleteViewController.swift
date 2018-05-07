//
//  CompeleteViewController.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import AVFoundation
import AVKit
import Alamofire


class CompeleteViewController : UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var VideoTableView: UITableView!
    @IBOutlet weak var TableEmpty: UILabel!
    
    var FinalVideoArray: [Any]?
//    var finalvideoURL: String?
    
    // Table View Data Source
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let num = FinalVideoArray?.count
        if num == nil || num == 0 {
            TableEmpty.text = "尚未有影片成果\n請前往【影片專案】頁面開始創作"
            self.view.addSubview(TableEmpty)
            return 0
        } else {
            TableEmpty.text = ""
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
        let videoname = finalvideo["videoname"] as? String
        cell.videoname.text = "影片名稱：".appending(videoname!)
        let videolength = finalvideo["videolength"] as? String
        cell.videolength.text = "影片長度：".appending(videolength!)
        let timestamp = finalvideo["timestamp"] as? String
        cell.timestamp.text = timestamp
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
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let finalvideo = FinalVideoArray?[indexPath.row] as? [String: Any]
        let videoid = finalvideo?["id"] as? Int
        lognote("pfv", google_userid, "\(videoid!)")
        
        let finalvideopath = finalvideo?["finalvideopath"] as? String
//        let finalvideoURL = URL(string: finalvideopath!)
//        let requestUrl = "http://140.122.76.201/CoInQ/upload/"
//        let urls = requestUrl.appending(google_userid).appending("/").appending("\(videoid)").appending("/").appending((finalvideoURL?.lastPathComponent)!)
//        let videourl = URL(string: urls)
        let Player = AVPlayer(url: URL(string: finalvideopath!)!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = Player
        self.present(playerViewController,animated: true){
            playerViewController.player!.play()
        }

    }
    
//    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
//        let size = image.size
//        
//        let widthRatio  = targetSize.width  / image.size.width
//        let heightRatio = targetSize.height / image.size.height
//        
//        // Figure out what our orientation is, and use that to form the rectangle
//        var newSize: CGSize
//        if(widthRatio > heightRatio) {
//            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
//        } else {
//            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
//        }
//        
//        // This is the rect that we've calculated out and this is what is actually used below
//        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
//        
//        // Actually do the resizing to the rect using the ImageContext stuff
//        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
//        image.draw(in: rect)
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return newImage!
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VideoTableView.tableFooterView = UIView(frame: .zero)
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name("CSCL"), object: nil)
        loadData()
    }
    
    func loadData() {
        let parameters: Parameters=["google_userid": google_userid]
        Alamofire.request("http://140.122.76.201/CoInQ/v1/getFinalVideo.php", method: .post, parameters: parameters).responseJSON
            {
                response in
                guard response.result.isSuccess else {
                    let errorMessage = response.result.error?.localizedDescription
                    print("\(errorMessage!)")
                    return
                }
                guard let JSON = response.result.value as? [String: Any] else {
                    print("JSON formate error")
                    return
                }
                // 2.
                let error = JSON["error"] as! Bool
                if error {
                    self.FinalVideoArray = []
                    self.VideoTableView.reloadData()
                    
                } else if let FinalVideo = JSON["table"] as? [Any] {
                    self.FinalVideoArray = FinalVideo
//                    print(self.FinalVideoArray)
                    self.FinalVideoArray?.reverse()
                    self.VideoTableView.reloadData()
                }
        }
        
    }
    
    func deleteData(id: Int){
        Alamofire.request("http://140.122.76.201/CoInQ/v1/deleteFinalVideo.php", method: .post, parameters: ["videoid":id]).responseJSON
            {
                response in
//                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    let error = jsonData.value(forKey: "error") as? Bool
                    if error! {
                        let deleteAlert = UIAlertController(title:"提示",message: "影片刪除失敗，請確認網路連線並重新刪除", preferredStyle: .alert)
                        deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:nil))
                        lognote("dvf", google_userid, "\(id)")
                        self.present(deleteAlert, animated: true, completion: nil)
                    }else{
                        self.loadData()
                    }
                }
        }
        
    }

}
