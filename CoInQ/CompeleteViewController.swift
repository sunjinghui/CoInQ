//
//  CompeleteViewController.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import AVFoundation
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
        
        //影片縮圖
        let videoURL = URL(string: Videoarray.videourl!)
        let asset = AVURLAsset(url: videoURL!, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = false
        
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            cell.imageView?.image = thumbnail
            
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
            
            /*tableView.beginUpdates()
             tableView.deleteRows(at: [indexPath], with: .automatic)
             tableView.endUpdates()*/
            
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Index = indexPath.row
        self.performSegue(withIdentifier: "startvideotask", sender: self)
    }
    
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
            print("Video complete \(Video)")
            print("video count \(Video.count)")
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
