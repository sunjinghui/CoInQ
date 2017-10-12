//
//  ProjectViewController.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import CoreData
import Alamofire
import SwiftyJSON

var Index = 0

class ProjectViewController : UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var VideoNameTableView: UITableView!
    @IBOutlet weak var TableEmpty: UIView!
    
    var videoInfoArray: [Any]?
//    var VideoNameArray = [VideoTaskInfo]()
//    var managedObjextContext: NSManagedObjectContext!
    
    // Table View Data Source
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let num = self.videoInfoArray?.count {
            VideoNameTableView.backgroundView = nil
            return num
        } else {
            VideoNameTableView.backgroundView = TableEmpty
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: TableView_cellvideotask

            cell = tableView.dequeueReusableCell(withIdentifier: "cellvideotask", for: indexPath) as! TableView_cellvideotask
        
        guard let videoInfo = self.videoInfoArray?[indexPath.row] as? [String: Any] else {
            print("Get row \(indexPath.row) error")
            return cell
        }
            //let VideoNamearray = VideoNameArray[indexPath.row]
            cell.VideoName.text = videoInfo["videoname"] as? String
            cell.Date.text = videoInfo["date"] as? String
        
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){

        if editingStyle == .delete {

            let deleteAlert = UIAlertController(title:"確定要刪除影片任務嗎？",message: "刪除影片任務後無法復原！", preferredStyle: .alert)
            deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:{ (action) -> Void in
//                self.managedObjextContext.delete(self.VideoNameArray[indexPath.row])
//                self.VideoNameArray.remove(at: indexPath.row)
                
                let videoInfo = self.videoInfoArray?[indexPath.row] as? [String: Any]
                let videoid = videoInfo?["id"] as? Int
                
                self.deleteData(id: videoid!)
                
                self.loadData()
            }))
            let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
            deleteAlert.addAction(cancelAction)
            //self.loadData()
            self.present(deleteAlert, animated: true, completion: nil)
            
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        Index = indexPath.row
        self.performSegue(withIdentifier: "startvideotask", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AddButton.layer.cornerRadius = 8
        VideoNameTableView.tableFooterView = UIView(frame: .zero)
        
//        managedObjextContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        loadData()
    }
    
    func loadData() {
//        let videotaskRequest: NSFetchRequest<VideoTaskInfo> = VideoTaskInfo.fetchRequest()
//        do {
//            VideoNameArray = try managedObjextContext.fetch(videotaskRequest)
//            self.VideoNameTableView.reloadData()
//        }catch {
//            print("Could not load data from coredb \(error.localizedDescription)")
//        }
        
        let parameters: Parameters=["google_userid": google_userid]
        Alamofire.request("http://140.122.76.201/CoInQ/v1/getvideoinfo.php", method: .post, parameters: parameters).responseJSON
            {
                response in
                
                guard response.result.isSuccess else {
                    let errorMessage = response.result.error?.localizedDescription
                    print("1\(errorMessage!)")
                    return
                }
                guard let JSON = response.result.value as? [String: Any] else {
                    print("JSON formate error")
                    return
                }
                // 2.
                if let videoinfo = JSON["table"] as? [Any] {
                    print(videoinfo)
                    self.videoInfoArray = videoinfo
                    self.VideoNameTableView.reloadData()
                }
        }
        
//        if VideoNameArray.count == 0 {
//            VideoNameTableView.backgroundView = TableEmpty
//        }else{
//            VideoNameTableView.backgroundView = nil
//        }

    }
    
    func deleteData(id: Int){
        Alamofire.request("http://140.122.76.201/CoInQ/v1/deletevideo.php", method: .post, parameters: ["videoid":id]).responseJSON
            {
                response in
                print(response)
        }
    }
    
    @IBAction func AddVideoTask(_ sender: Any) {
        //  Delete the data in the VideoInfo
//        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "VideoInfo")
//        let request = NSBatchDeleteRequest(fetchRequest: fetch)
//        do{
//            try managedObjextContext.execute(request)
//        }catch{
//            
//        }
//        print(VideoInfo())
//        
//        let videotaskitem = VideoTaskInfo(context: managedObjextContext)
//        
//        Index = self.VideoNameArray.count
        
        let alertController = UIAlertController(title:"探究影片名稱",message: "生活中有各式各樣的自然現象\n這些現象是如何產生的呢？\n讓我們一起來探究並透過\n影音將這探究過程記錄下來！", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: {(textField) -> Void in
            textField.delegate = self
            textField.placeholder = "請輸入你想問的探究問題"
        })
        
        // set the date
        let date = Date()
        let formater = DateFormatter()
        formater.dateFormat = "yyyy/MM/dd"
        let dateresult = formater.string(from: date)
        
        let StartVideoTask = UIAlertAction(title:"開始製作影片", style: .default, handler:{
            (action) -> Void in
            let VideoName = alertController.textFields?.first?.text
            if VideoName != ""{

//                    videotaskitem.videoname = VideoName?.text
//                    videotaskitem.creatdate = dateresult
//                    do {
//                        try self.managedObjextContext.save()
                        //UPLOAD VideoTask
                        let parameters: Parameters=[
                            "google_userid": google_userid,
                            "videoname":    VideoName!,
                            "cdate":        dateresult,
                        ]
                
                        //Sending http post request
                        Alamofire.request("http://140.122.76.201/CoInQ/v1/uploadvideo.php", method: .post, parameters: parameters).responseJSON
                            {
                                response in
                                //printing response
                                print(response)
                                
                                //getting the json value from the server
                                //                    if let result = response.result.value {
                                //
                                //                        //converting it as NSDictionary
                                //                        let jsonData = result as! NSDictionary
                                //
                                //                        //displaying the message in label
                                //                        //self.labelMessage.text = jsonData.value(forKey: "message") as! String?
                                //                        print(jsonData.value(forKey: "message") as Any)
                                //                    }
                        }
                        
                        self.loadData()
//                    }catch {
//                        print("Could not save data \(error.localizedDescription)")
//                    }
//                UserDefaults.standard.removeObject(forKey: "VideotaskTitle")
//                UserDefaults.standard.set(VideoName, forKey: "VideotaskTitle")
//                self.performSegue(withIdentifier: "startvideotask", sender: self)
                
            }else{
                let errorAlert = UIAlertController(title:"請注意",message: "不能沒有探究影片名稱", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title:"OK",style: .cancel, handler:{ (action) -> Void in self.present(alertController, animated: true, completion: nil)}))
                self.present(errorAlert, animated: true, completion: nil)
            }

        })
        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)

        alertController.addAction(StartVideoTask)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startvideotask" {
            guard let videotaskViewController = segue.destination as? VideoTaskViewController,
                let row = self.VideoNameTableView.indexPathForSelectedRow?.row,
                let videoinfo = self.videoInfoArray?[row] as? [String: Any]
                else { return }
            
            videotaskViewController.title = videoinfo["videoname"] as? String
            Index = (videoinfo["id"] as? Int)!
            
        }
    }
    
}
