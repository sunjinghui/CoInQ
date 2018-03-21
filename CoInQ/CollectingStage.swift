//
//  CollectingStage.swift
//  CoInQ
//
//  Created by hui on 2017/12/18.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import MediaPlayer
import Alamofire
import MobileCoreServices
import SwiftyJSON
import Photos

class CollectingStage :  UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var TableEmpty: UIView!
    @IBOutlet weak var tableview : UITableView!
    @IBOutlet weak var editButtom: UIBarButtonItem!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
//    fileprivate let viewModel = ProfileViewModel()
    var clips: [Any]?
    var invites: [Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "蒐集探究資料"
        
        tableview.delegate = self
        tableview?.dataSource = self
//        tableview?.estimatedRowHeight = 154
//        tableview?.rowHeight = UITableViewAutomaticDimension
        tableview.tableFooterView = UIView(frame: .zero)
        let nibName = UINib(nibName: "TableViewCell_clip", bundle: nil)
        tableview.register(nibName, forCellReuseIdentifier: "tableviewcell")
        tableview.register(UINib(nibName: "TableViewCell_invite", bundle: nil), forCellReuseIdentifier: "cellinvite")
//        tableview.register(TableViewCell_clip.nib, forCellReuseIdentifier: TableViewCell_clip.identifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loaddata), name: NSNotification.Name("CoStage"), object: nil)
        loadinvitation()
        loaddata()
    }
    
    @IBAction func backtoStage(_ sender: Any){
        dismiss(animated: true, completion: nil)
        self.SaveClipOrder()
    }
    
    @IBAction func EditClipOrder(_ sender: UIBarButtonItem) {
        tableview.isEditing = !tableview.isEditing
        switch tableview.isEditing {
        case true:
            editButtom.title = "完成"
        case false:
            editButtom.title = "調整資料順序"
            self.SaveClipOrder()
        }
    }
    
    @IBAction func SearchUser(_ sender: Any){
        let navigationtableview = storyboard?.instantiateViewController(withIdentifier: "TableNavigationControllerS") as! TableNavigationController
        present(navigationtableview, animated: true, completion: nil)
    }
    
    func SaveClipOrder(){
        for each in self.clips!{
            let clip = each as? [String: Any]
            let clipID = clip?["id"] as? Int
            let order = (clips as AnyObject).index(of: each)
            self.UpdateOrder(clipid: clipID!, order: order)
        }
    }
    
    func loadinvitation(){
        print(Index)
        Alamofire.request("http://140.122.76.201/CoInQ/v1/collaboration.php", method: .post, parameters: ["google_userid_FROM": google_userid,"videoid": Index]).responseJSON
            {
                response in
                print(response)
                guard response.result.isSuccess else {
                    let errorMessage = response.result.error?.localizedDescription
                    print("\(errorMessage!)")
                    return
                }
                guard let JSON = response.result.value as? [String: Any] else {
                    print("JSON formate error")
                    return
                }
                let error = JSON["error"] as! Bool
                if error {
                    self.clips = []
                    self.tableview.reloadData()
                    
                } else if let invitation = JSON["table"] as? [Any] {
                    self.invites = invitation
                    self.tableview.reloadData()
                }
        }
    }
    
    func loaddata(){
        let parameters: Parameters=["google_userid": google_userid,"videoid":Index]
        Alamofire.request("http://140.122.76.201/CoInQ/v1/getCollectingclips.php", method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
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
                    self.clips = []
                    self.tableview.reloadData()
                    
                } else if let Collecte = JSON["table"] as? [Any] {
                    self.clips = Collecte
//                    var collect = self.clips?[0] as? [String: Any]
//                    var tmp = Collection()
                    for each in self.clips!{
                        let array = each as? [String: Any]
                        let videopath = array?["videopath"] as? String
                        let videoname = array?["videoname"] as? String
                        let id = array?["id"] as? Int
                        let url = URL(string: videopath!)
                        if !(FileManager.default.fileExists(atPath: (url?.path)!)){
                            self.startActivityIndicator()
                            self.donloadVideo(videoname: videoname!,id!)
                        }
                    }
                    
                    if (self.clips?.count)! <= 1 {
                        self.navigationItem.rightBarButtonItem = nil
                    }else{
                        self.navigationItem.rightBarButtonItem = self.editButtom
                    }
                    self.tableview.reloadData()
                }
        }

    }
    
    func uploadvideo(mp4Path : URL,message: String, clip: Int){
        
        Alamofire.upload(
            //同样采用post表单上传
            multipartFormData: { multipartFormData in
                
                multipartFormData.append(mp4Path, withName: "file")//, fileName: "123456.mp4", mimeType: "video/mp4")
                multipartFormData.append("\(Index)".data(using: String.Encoding.utf8, allowLossyConversion: false)!,withName: "videoid")
                multipartFormData.append(google_userid.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "google_userid")
                multipartFormData.append((mp4Path.absoluteString.data(using: String.Encoding.utf8, allowLossyConversion: false)!),withName: "videopath")
                multipartFormData.append("\(clip)".data(using: String.Encoding.utf8, allowLossyConversion: false)!,withName: "clip")
                //                for (key, val) in parameters {
                //                    multipartFormData.append(val.data(using: String.Encoding.utf8)!, withName: key)
                //                }
                
                //SERVER ADD
        },to: "http://140.122.76.201/CoInQ/v1/uploadvideo.php",
          encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                //json处理
                upload.responseJSON { response in
                    //解包
                    guard let result = response.result.value else { return }
                    //                    print("\(result)")
                    //须导入 swiftyJSON 第三方框架，否则报错
                    let success = JSON(result)["success"].int ?? -1
                    if success == 1 {
                        print("Upload Succes")
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title:"提示",message:message, preferredStyle: .alert)
                        let action2 = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action2)
                        self.present(alert , animated: true , completion: nil)
                        self.loaddata()
//                        lognote("u\(clip)s", google_userid, "\(Index)")
                    }else{
                        print("Upload Failed")
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title:"提示",message:"上傳失敗，請重新上傳", preferredStyle: .alert)
                        let action2 = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action2)
                        self.present(alert , animated: true , completion: nil)
//                        lognote("u\(clip)f", google_userid, "\(Index)")
                    }
                }
                //上传进度
                upload.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                        print("Upload Progress: \(progress.fractionCompleted)")
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    func donloadVideo(videoname : String,_ dataid: Int){
        
        let requestUrl = "http://140.122.76.201/CoInQ/upload/"
        let videoid = "\(Index)"
        
        let urls = requestUrl.appending(google_userid).appending("/").appending(videoid).appending("/").appending(videoname)
        let videourl = URL(string: urls)
        
        let downloadfilename = UUID().uuidString + ".mov"
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let file = directoryURL.appendingPathComponent(downloadfilename, isDirectory: false)
            return (file, [.createIntermediateDirectories, .removePreviousFile])
        }
        
        Alamofire.download(videourl!, to: destination).validate().responseData { response in
            let tmpurl = response.destinationURL
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            let alertController = UIAlertController(title: "影片已接收完成\n您可以在相簿中找到", message: nil, preferredStyle: .alert)
            let checkagainAction = UIAlertAction(title: "OK", style: .default, handler:{
                (action) -> Void in
                self.loaddata()
            })
            alertController.addAction(checkagainAction)
            self.present(alertController, animated: true, completion: nil)
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tmpurl!)
            }) { saved, error in
                if saved {
                    let parameters: Parameters=[
                        "id":  dataid,
                        "videopath":  tmpurl!.absoluteString,
                    ]
                    
                    //Sending http post request
                    Alamofire.request("http://140.122.76.201/CoInQ/v1/getCollectingclips.php", method: .post, parameters: parameters).responseJSON
                        {
                            response in
                            //                            print(response)
                            
                    }
                }
            }
        }
    }

    
    func savedPhotosAvailable() -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            let alert = UIAlertController(title: "Not Available", message: "No Saved Album found", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func startMediaBrowserFromViewController(_ viewController: UIViewController!, usingDelegate delegate : (UINavigationControllerDelegate & UIImagePickerControllerDelegate)!) -> Bool {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            return false
        }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .savedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
        //        mediaUI.videoMaximumDuration = 30.0
        present(mediaUI, animated: true, completion: nil)
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Addclips(_ sender: AnyObject) {
        if savedPhotosAvailable() {
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0 :
            if let num = clips?.count {
                return num
            } else {
                return 0
            }
        case 1 :
            if let num = invites?.count {
                return num
            } else {
                return 0
            }
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section){
        case 0 : return "探究資料影片"
        case 1 : return "共創邀請內容"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableview.dequeueReusableCell(withIdentifier: "tableviewcell", for: indexPath) as! TableViewCell_clip
            
            guard let collect = self.clips?[indexPath.row] as? [String: Any] else {
                print("Get row \(indexPath.row) error")
                return cell
            }
            
            let username = collect["username"] as? String
            let videoURL = collect["videopath"] as? String
            let time = collect["time"] as? String
            let info = collect["info"] as? String
            if info != nil {
                let infos = "請求內容：\n".appending(info!)
                cell.commonInit(username!, videopath: videoURL!, times: time!, info: infos)
            }else{
                let infos = "無資訊"
                cell.commonInit(username!, videopath: videoURL!, times: time!, info: infos)
            }
            return cell
        }else{
            let cell = tableview.dequeueReusableCell(withIdentifier: "cellinvite", for: indexPath) as! TableViewCell_invite
            guard let invitation = self.invites?[indexPath.row] as? [String: Any] else {
                print("Get row \(indexPath.row) error")
                return cell
            }
            cell.inviteinfo.text = invitation["context"] as? String
            let invitewho = invitation["ownername"] as? String
            cell.invitewho.text = "邀請對象：".appending(invitewho!)
            
            return cell
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        }else{
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            let clipitem = self.clips?[sourceIndexPath.row] as? [String: Any]
            let clipID = clipitem?["id"] as? Int
            
            clips?.remove(at: sourceIndexPath.row)
            clips?.insert(clipitem, at: destinationIndexPath.row)
            self.UpdateOrder(clipid: clipID!, order: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        
        if editingStyle == .delete {
            if indexPath.section == 0 {
                let deleteAlert = UIAlertController(title:"確定要刪除探究資料影片嗎？",message: "刪除探究資料影片後無法復原！", preferredStyle: .alert)
                deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:{ (action) -> Void in
                    
                    let clipInfo = self.clips?[indexPath.row] as? [String: Any]
                    let clipid = clipInfo?["id"] as? Int
    //                let videoname = clipInfo?["videoname"] as? String
    //                lognote("dcc", google_userid, "\(videoid!)\(videoname ?? "nil")")
                    self.deleteData(id: clipid!)
                    //                SelectVideoUpload_Nine().update()
                }))
                let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
                deleteAlert.addAction(cancelAction)
                self.present(deleteAlert, animated: true, completion: nil)
            }else{
                
            }
        }
        
    }
    
    func UpdateOrder(clipid: Int,order: Int){
        Alamofire.request("http://140.122.76.201/CoInQ/v1/deleteclips.php", method: .post, parameters: ["clipsid": clipid,"order": order]).responseJSON{
            response in
//            print("UUUUpdate order \(clipid) \(response)")

        }
    }

    func deleteData(id: Int){
        Alamofire.request("http://140.122.76.201/CoInQ/v1/deleteclips.php", method: .post, parameters: ["clipsid":id]).responseJSON
            {
                response in
//                print("DDDelete ID\(id) \(response)")
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    let error = jsonData.value(forKey: "error") as? Bool
                    if error! {
                        let deleteAlert = UIAlertController(title:"提示",message: "刪除失敗，請確認網路連線並重新刪除", preferredStyle: .alert)
                        deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:nil))
                        self.present(deleteAlert, animated: true, completion: nil)
                        self.loaddata()
                    }else{
//                        lognote("dcf", google_userid, "\(id)")
                        self.loaddata()
                    }
                    
                }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 350
        }else{
            return 98.5
        }
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        }else{
            return false
        }
    }

    func startActivityIndicator() {
        let screenSize: CGRect = UIScreen.main.bounds
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0,width: 100,height: 100))
        activityIndicator.frame = CGRect(x: 0,y: 0,width: screenSize.width,height: screenSize.height)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        
        // Change background color and alpha channel here
        activityIndicator.backgroundColor = UIColor.black
        activityIndicator.clipsToBounds = true
        activityIndicator.alpha = 0.5
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
}

extension CollectingStage : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        if mediaType == kUTTypeMovie {
            let avAsset = info[UIImagePickerControllerMediaURL] as! URL
            var message = ""
                message = "影片已匯入成功！"
                self.startActivityIndicator()
            let videoURL = avAsset
            uploadvideo(mp4Path: videoURL,message: message,clip:10)
            
            
        }
    }
}

extension CollectingStage : UINavigationControllerDelegate{
}
