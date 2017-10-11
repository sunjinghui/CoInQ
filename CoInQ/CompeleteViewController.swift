//
//  CompeleteViewController.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import AVFoundation
import AVKit
import CoreData

class CompeleteViewController : UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var VideoTableView: UITableView!
    @IBOutlet weak var TableEmpty: UIView!
    
    
    var Video = [VideoInfo]()
    var managedObjextContext: NSManagedObjectContext!
    
    // Table View Data Source
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Video.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: TableView_cellcompletevideo
        
        cell = tableView.dequeueReusableCell(withIdentifier: "cellvideocomplete", for: indexPath) as! TableView_cellcompletevideo
        let Videoarray = Video[indexPath.row]
        cell.videoname.text = Videoarray.videoname
        cell.videolength.text = Videoarray.videolength
        
        //影片縮圖
        let videoURL = URL(string: Videoarray.videourl!)
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
                self.managedObjextContext.delete(self.Video[indexPath.row])
                self.Video.remove(at: indexPath.row)
                self.loadData()
            }))
            let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
            deleteAlert.addAction(cancelAction)
            self.present(deleteAlert, animated: true, completion: nil)
            
            
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Index = indexPath.row
        let Player = AVPlayer(url: URL(string:Video[indexPath.row].videourl!)!)
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
        
        managedObjextContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        loadData()
    }
    
    func loadData() {
        //let videoRequest: NSFetchRequest<VideoInfo> = VideoInfo.fetchRequest()

        do {
            Video = try managedObjextContext.fetch(VideoInfo.fetchRequest())
            
            self.VideoTableView.reloadData()

        }catch {
            print("Could not load data from coredb \(error.localizedDescription)")
        }
        if Video.count == 0 {
            VideoTableView.backgroundView = TableEmpty
        }else{
            VideoTableView.backgroundView = nil
        }
        
    }

}
