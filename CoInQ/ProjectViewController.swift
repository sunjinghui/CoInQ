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
import Photos
import MPCoachMarks

var Index = 0
func lognote(_ actiontype: String,_ google_userid: String,_ note: String){
    Alamofire.request("http://140.122.76.201/CoInQ/v1/log.php", method: .post, parameters: ["actiontype":actiontype,"google_userid": google_userid,"note":note])
}

class ProjectViewController : UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var TableEmpty: UILabel!
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var VideoNameTableView: UITableView!
    
    var videoInfoArray: [Any]?
    var coachMarksView = MPCoachMarks()
    // Table View Data Source
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let num = videoInfoArray?.count
        if num == nil || num == 0 {
            TableEmpty.text = "沒有影片專案\n請按下方 + 新增並命名"
            self.view.addSubview(TableEmpty)
            return 0
        } else {
            TableEmpty.text = ""
            return num!
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: TableView_cellvideotask

            cell = tableView.dequeueReusableCell(withIdentifier: "cellvideotask", for: indexPath) as! TableView_cellvideotask
        
        guard let videoInfo = self.videoInfoArray?[indexPath.row] as? [String: Any] else {
            print("Get row \(indexPath.row) error")
            return cell
        }
        cell.VideoName.text = videoInfo["videoname"] as? String
        cell.Date.text = videoInfo["date"] as? String
        cell.editVideoName.tag = indexPath.row
        cell.editVideoName.addTarget(self, action: #selector(self.editVideoName(_:)), for: .touchUpInside)
        cell.backgroundView = UIImageView(image: #imageLiteral(resourceName: "tablecell_bg"))
        return cell
    }
    
    @IBAction func editVideoName(_ sender: UIButton){
        
        let alertController = UIAlertController(title:"請更改影片名稱",message: nil, preferredStyle: .alert)
        let videoinfo = self.videoInfoArray?[sender.tag] as? [String: Any]
        let originaltext = videoinfo?["videoname"] as? String
        let videoid = videoinfo?["id"] as? Int
        alertController.addTextField(configurationHandler: {(textField) -> Void in
            textField.delegate = self
            textField.text = originaltext
        })
        
        let StartVideoTask = UIAlertAction(title:"完成", style: .default, handler:{
            (action) -> Void in
            let VideoName = alertController.textFields?.first?.text
            if !(VideoName?.isEmpty)! {
                //UPLOAD VideoTask
                let parameters: Parameters=[
                    "videoid":      videoid!,
                    "videopath":    VideoName!,
                    "clip": 10
                    ]
                print(parameters)
                //Sending http post request
                Alamofire.request("http://140.122.76.201/CoInQ/v1/uploadvideo.php", method: .post, parameters: parameters).responseJSON
                    {
                        response in
                        //                    if let result = response.result.value {
                        //                        let jsonData = result as! NSDictionary
                        //
                        //                        //self.labelMessage.text = jsonData.value(forKey: "message") as! String?
                        //                        print(jsonData.value(forKey: "message") as Any)
                        //                    }
                }
                SelectVideoUpload_Nine().update()
                lognote("ctn", google_userid, VideoName!)
                self.reload()
            }else{
                let errorAlert = UIAlertController(title:"請注意",message: "不能沒有探究影片名稱", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title:"OK",style: .cancel, handler:{ (action) -> Void in self.present(alertController, animated: true, completion: nil)}))
                self.present(errorAlert, animated: true, completion: nil)
            }
            
        })
        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
        
        alertController.addAction(StartVideoTask)
        alertController.addAction(cancelAction)
        reload()
        self.present(alertController, animated: true, completion: nil)
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){

        if editingStyle == .delete {
            let videoInfo = self.videoInfoArray?[indexPath.row] as? [String: Any]
            let videoid = videoInfo?["id"] as? Int
            lognote("tdv", google_userid, "\(videoid!)")
            
            let deleteAlert = UIAlertController(title:"確定要刪除影片任務嗎？",message: "刪除影片任務後無法復原！", preferredStyle: .alert)
            deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:{ (action) -> Void in
//                let videoname = videoInfo?["videoname"] as? String
                self.deleteData(id: videoid!)
//                SelectVideoUpload_Nine().update()
            }))
            let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
            deleteAlert.addAction(cancelAction)
            self.present(deleteAlert, animated: true, completion: nil)

        }

    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        Index = indexPath.row
        let videoInfo = self.videoInfoArray?[indexPath.row] as? [String: Any]
        let videoid = videoInfo?["id"] as? Int
        lognote("evt", google_userid, "\(String(describing: videoid))")
        self.performSegue(withIdentifier: "startvideotask", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AddButton.layer.cornerRadius = 8
        VideoNameTableView.tableFooterView = UIView(frame: .zero)
        reload()
    }
    override func viewDidAppear(_ animated: Bool) {
        let coachMarksShown: Bool = UserDefaults.standard.bool(forKey: "MPCoachMarksShown")
        if coachMarksShown == false {
            UserDefaults.standard.set(true, forKey: "MPCoachMarksShown")
            UserDefaults.standard.synchronize()
            coachmark()
        }
    }
    
    func coachmark(){
        let coachmark1 = CGRect(x: (UIScreen.main.bounds.size.width / 3) - 170, y: 960, width: 170, height: 65)
        let coachmark2 = CGRect(x: (UIScreen.main.bounds.size.width / 3) + 55, y: 960, width: 170, height: 65)
        let coachmark3 = CGRect(x: (UIScreen.main.bounds.size.width / 3) * 2 , y: 960, width: 170, height: 65)
        let coachmark4 = CGRect(x: 700, y: 40, width: 50, height: 50)

        let coachMarks = [
            ["rect": NSValue(cgRect: coachmark1), "caption": "即將開始創作影片嘍！\n\n\n\n這個頁面用來管理製作中的影片專案\n製作影片的過程中\n您可以請別人提供他的影片\n\n\n\n\n\n\n\n", "position": 2],
            ["rect": NSValue(cgRect: coachmark2), "caption": "完成的成果影片會呈現在這一頁\n\n\n\n\n\n\n\n\n\n", "position": 2],
            ["rect": NSValue(cgRect: coachmark3), "caption": "製作影片的過程中\n您可以請別人提供他的影片\n\n這個頁面則列出\n別人請你提供影片的邀請\n\n\n\n\n\n","position": 2],
            ["rect": NSValue(cgRect: coachmark4), "caption": "開始之前來看看要經歷哪些步驟吧！","position": 5, "showArrow": true]
        ]
        coachMarksView = MPCoachMarks(frame: (tabBarController?.view.bounds)! , coachMarks: coachMarks)
        coachMarksView.enableContinueLabel = false
        coachMarksView.maxLblWidth = 350
        coachMarksView.skipButtonText = "跳過"
        tabBarController?.view.addSubview(coachMarksView)
//        var coachMarksView = MPCoachMarks(frame: view.bounds, coachMarks: coachMarks)
//        view.addSubview(coachMarksView)
        coachMarksView.start()
    }
    
    func coachmarkAfterNewTask(){
        let coachmark5 = CGRect(x: (UIScreen.main.bounds.size.width / 10)-63 , y: (UIScreen.main.bounds.size.height / 7)-10,width:80,height:80)
        let coachmark6 = CGRect(x: (UIScreen.main.bounds.size.width - 690), y: (UIScreen.main.bounds.size.height / 10),width:650,height: 150)
        let coachMarks = [
            ["rect": NSValue(cgRect: coachmark5),"caption": "這裡可以修改專案名稱","position": 4,"shape":1,"showArrow":true],
            ["rect": NSValue(cgRect: coachmark6),"caption": "將專案區塊往左滑←--會出現刪除按鈕\n即可刪除此專案","position": 5,"shape":2]
        ]
        coachMarksView = MPCoachMarks(frame: view.bounds, coachMarks: coachMarks)
        coachMarksView.enableContinueLabel = false
        coachMarksView.enableSkipButton = false
        coachMarksView.maxLblWidth = 350
        view.addSubview(coachMarksView)
        coachMarksView.start()
    }
    
    func reload() {
        
        let parameters: Parameters=["google_userid": google_userid]
        Alamofire.request("http://140.122.76.201/CoInQ/v1/getvideoinfo.php", method: .post, parameters: parameters).responseJSON
            {
                response in
                
                guard response.result.isSuccess else {
                    let errorMessage = response.result.error?.localizedDescription
                    print("load video task \(errorMessage!)")
                    return
                }
                guard let JSON = response.result.value as? [String: Any] else {
                    print("JSON formate error")
                    return
                }
                // 2.
                let error = JSON["error"] as! Bool
                if error {
                    self.videoInfoArray = []
                    self.VideoNameTableView.reloadData()

                } else if let videoinfo = JSON["table"] as? [Any] {
                    self.videoInfoArray = videoinfo
                    self.VideoNameTableView.reloadData()
                }
        }

    }
    
    func deleteData(id: Int){
        Alamofire.request("http://140.122.76.201/CoInQ/v1/deletevideo.php", method: .post, parameters: ["videoid":id]).responseJSON
            {
                response in
//                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    let error = jsonData.value(forKey: "error") as? Bool
                    if error! {
                        let deleteAlert = UIAlertController(title:"提示",message: "影片任務刪除失敗，請確認網路連線並重新刪除", preferredStyle: .alert)
                        deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:nil))
                        self.present(deleteAlert, animated: true, completion: nil)
                        lognote("dtf", google_userid, "\(id)")
                        self.reload()
                    }else{
                        lognote("dvt", google_userid, "\(id)")
                        self.reload()
                    }
                    
                }
        }
        
    }
    
    @IBAction func AddVideoTask(_ sender: Any) {
        
        let alertController = UIAlertController(title:"探究影片名稱",message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n生活中有各式各樣的自然現象\n這些現象是如何產生的呢？\n讓我們一起來探究並透過\n影音將這探究過程記錄下來！\n", preferredStyle: .alert)
        
//        let saveAction = UIAlertAction(title: "Zip Viewer", style: .default, handler: nil)
//        saveAction.setValue(UIImage(named:"circle1")?.withRenderingMode(UIImageRenderingMode.automatic), forKey: "image")
//        alertController.addAction(saveAction)
        
        alertController.addTextField(configurationHandler: {(textField) -> Void in
            textField.delegate = self
            textField.placeholder = "請輸入你想問的探究問題"
        })
        let img = #imageLiteral(resourceName: "circle")
        let imgView = UIImageView(frame: CGRect(x: 17, y: 48, width: 236, height: 220))
        imgView.image = img
//        imgView.sizeToFit()
        
        alertController.view.addSubview(imgView)

//        let button = UIButton(type: .system)
//        button.setTitle("Button", for: .normal)
//        button.addTarget(responder, action: "tap", forControlEvents: .TouchUpInside)
//        button.sizeToFit()
//        button.center = CGPoint(x: 50, y: 25)
//        let rect = CGRect(x: 50,y: 110, width: 120, height: 120)
//        let view = UIView(frame: rect)
//        view.backgroundColor = UIColor.white
//        view.addSubview(button)
        
//        let height:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.80)
//        alertController.view.addConstraint(height)
//        alertController.view.addSubview(view)
        
        // set the date
        let date = Date()
        let formater = DateFormatter()
        formater.dateFormat = "yyyy/MM/dd"
        let dateresult = formater.string(from: date)
        
        let StartVideoTask = UIAlertAction(title:"建立影片專案", style: .default, handler:{
            (action) -> Void in
            let VideoName = alertController.textFields?.first?.text
            if !(VideoName?.isEmpty)! {
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
                                    if response.result.isSuccess {
                                        let coachMarksShown: Bool = UserDefaults.standard.bool(forKey: "MPCoachMarksShown_AfterNewTask")
                                        if coachMarksShown == false {
                                            UserDefaults.standard.set(true, forKey: "MPCoachMarksShown_AfterNewTask")
                                            UserDefaults.standard.synchronize()
                                            self.coachmarkAfterNewTask()
                                        }
                                    }
                        }
                        
                SelectVideoUpload_Nine().update()
                print(VideoName!)
                lognote("nvt", google_userid, VideoName!)
                self.reload()

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
        reload()
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
