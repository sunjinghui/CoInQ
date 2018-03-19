//
//  InvitaionViewController.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import Alamofire
import MobileCoreServices
import SwiftyJSON

class InvitaionViewController : UIViewController{
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var googleSignInEmail: UILabel!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var DataArray: [Any]?
    var context = [String]()
    var videoname = [String]()
    var ownerName = [String]()
    var id = [Int]()
    var owner_googleid = [String]()
    
    override func viewDidLoad() {
        
        tableview.tableFooterView = UIView(frame: .zero)
        super.viewDidLoad()
        
        getCooperateInfo()
    }
    
    func getCooperateInfo(){
        
        let parameters: Parameters=["google_userid_TO": google_userid]
        Alamofire.request("http://140.122.76.201/CoInQ/v1/collaboration.php", method: .post, parameters: parameters).responseJSON
            {
                response in
                
                guard response.result.isSuccess else {
                    let errorMessage = response.result.error?.localizedDescription
                    print("load user info \(errorMessage!)")
                    return
                }
                guard let JSON = response.result.value as? [String: Any] else {
                    print("JSON formate error")
                    return
                }
                // 2.
                let error = JSON["error"] as! Bool
                if error {
                    self.DataArray = []
                    self.tableview.reloadData()
                    
                } else if let cooperationinfo = JSON["table"] as? [Any] {
                    self.DataArray = cooperationinfo
                    
                    for each in self.DataArray!{
                        let array = each as? [String: Any]
                        let ownerName = array?["ownername"] as? String
                        let videoname = array?["videoname"] as? String
                        let context = array?["context"] as? String
                        let id = array?["id"] as? Int
                        let owner_googleid = array?["google_userid_FROM"] as? String
                        self.ownerName.append(ownerName!)
                        self.context.append(context!)
                        self.videoname.append(videoname!)
                        self.id.append(id!)
                        self.owner_googleid.append(owner_googleid!)
                    }
                    
                    self.tableview.reloadData()
                }
        }
        
    }
    
    func deleteData(id: Int){
        Alamofire.request("http://140.122.76.201/CoInQ/v1/deleteclips.php", method: .post, parameters: ["id":id]).responseJSON
            {
                response in
                //                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    let error = jsonData.value(forKey: "error") as? Bool
                    if error! {
                        let deleteAlert = UIAlertController(title:"提示",message: "影片刪除失敗，請確認網路連線並重新刪除", preferredStyle: .alert)
                        deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:nil))
//                        lognote("dcv", google_userid, "\(id)")
                        self.present(deleteAlert, animated: true, completion: nil)
                    }else{
                        self.getCooperateInfo()
                    }
                }
        }
        
    }
    
    func uploadVideo(mp4Path : URL , message : String, clip: Int){
        
        let indexPathRow = self.tableview.indexPathForSelectedRow?.row
        let google_FROM = owner_googleid[indexPathRow!]
        let context = self.context[indexPathRow!]
        
        Alamofire.upload(
            //同样采用post表单上传
            multipartFormData: { multipartFormData in
                
                multipartFormData.append(mp4Path, withName: "file")//, fileName: "123456.mp4", mimeType: "video/mp4")
                multipartFormData.append("\(Index)".data(using: String.Encoding.utf8, allowLossyConversion: false)!,withName: "videoid")
                multipartFormData.append(google_FROM.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "google_userid")
                multipartFormData.append((mp4Path.absoluteString.data(using: String.Encoding.utf8, allowLossyConversion: false)!),withName: "videopath")
                multipartFormData.append("\(clip)".data(using: String.Encoding.utf8, allowLossyConversion: false)!,withName: "clip")
                multipartFormData.append(context.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "context")
                //                for (key, val) in parameters {
                //                    multipartFormData.append(val.data(using: String.Encoding.utf8)!, withName: key)
                //                }
                
                //SERVER ADD
        },to: "http://140.122.76.201/CoInQ/v1/uploadFinalVideo.php",
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
                        let action2 = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                            let inviteid = self.id[indexPathRow!]
                            self.deleteData(id: inviteid)
                            //                SelectVideoUpload_Nine().update()
                        })
                        alert.addAction(action2)
                        self.present(alert , animated: true , completion: nil)
                        self.getCooperateInfo()
//                        lognote("u\(clip)s", google_userid, "\(Index)")
                    }else{
                        print("Upload Failed")
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title:"提示",message:"上傳失敗，請重新上傳", preferredStyle: .alert)
                        let action2 = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action2)
                        self.present(alert , animated: true , completion: nil)
//                        lognote("u\(clip)f", google_FROM, "\(Index)")
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
        mediaUI.videoMaximumDuration = 30.0
        present(mediaUI, animated: true, completion: nil)
        return true
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
    
    func stopActivityIndicator(_ clip: Int) {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
//        let alertController = UIAlertController(title: "故事版\(clip)影片已同步\n您可以在相簿中找到", message: nil, preferredStyle: .alert)
//        let checkagainAction = UIAlertAction(title: "OK", style: .default, handler:{
//            (action) -> Void in
//            self.load()
//        })
//        alertController.addAction(checkagainAction)
//        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension InvitaionViewController : UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let num = DataArray?.count
        if num == nil || num == 0 {
//            tableview.backgroundView = TableEmpty
            let text = "\(google_username)\n\(google_useremail)\n沒有影片共創邀請"
            googleSignInEmail.text = text
            return 0
        } else {
            googleSignInEmail.text = nil
//            tableview.backgroundView = nil
            return num!
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: TableView_cellcooperate
        
        cell = tableView.dequeueReusableCell(withIdentifier: "cellcooperate", for: indexPath) as! TableView_cellcooperate
        cell.videoname.text = videoname[indexPath.row]
        cell.context.text = context[indexPath.row]
        cell.owner.text = ownerName[indexPath.row]
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        
        if editingStyle == .delete {
            
            let deleteAlert = UIAlertController(title:"確定拒絕影片共創邀請嗎？",message: "拒絕邀請後無法復原！", preferredStyle: .alert)
            deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:{ (action) -> Void in
                let inviteid = self.id[indexPath.row]
//                lognote("d??", google_userid, "\(videoid!)")
                self.deleteData(id: inviteid)
                
                self.getCooperateInfo()
            }))
            let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
            deleteAlert.addAction(cancelAction)
            self.present(deleteAlert, animated: true, completion: nil)
            
            
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if savedPhotosAvailable() {
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }
        
    }
    
}
// MARK: - UIImagePickerControllerDelegate
extension InvitaionViewController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        if mediaType == kUTTypeMovie {
            let avAsset = info[UIImagePickerControllerMediaURL] as! URL
            var message = ""
                message = "共創影片影片已傳遞成功！"
                self.startActivityIndicator()
                let videoURL = avAsset
                uploadVideo(mp4Path: videoURL,message: message,clip:11)
                getCooperateInfo()
            
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension InvitaionViewController : UINavigationControllerDelegate {
}
