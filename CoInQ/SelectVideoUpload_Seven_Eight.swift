//
//  SelectVideoUpload_Seven_Eight.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import MobileCoreServices
import MediaPlayer
import Alamofire
import SwiftyJSON
import AVKit

class SelectVideoUpload_Seven_Eight : UIViewController{
    
    var loadingAssetOne = false
    var loadingCamera = false
    var isClicked = true
    var previewSeven = UIView.init(frame: CGRect(x: 225,y: 274,width: 465,height: 257))
    var previewEight = UIView.init(frame: CGRect(x: 225,y: 675,width: 465,height: 257))

    @IBOutlet weak var recSeven: UIButton!
    @IBOutlet weak var recEight: UIButton!
    @IBOutlet weak var delSeven: UIButton!
    @IBOutlet weak var delEight: UIButton!
    
    var player: AVPlayer!
    var playerController = AVPlayerViewController()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBAction func StageTitleFour(_ sender: UIButton) {
        lognote("h4d", google_userid, "\(Index)")
        if isClicked {
            isClicked = false
            sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
            sender.setTitle("最終的解釋要是科學的、有邏輯的，不能自相矛盾、不講道理", for: UIControlState())
        }else{
            isClicked = true
            sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
            sender.setTitle("形成解釋", for: UIControlState())
        }
    }
    
    @IBAction func revSeven(_ sender: AnyObject) {
        
        let controller = AudioRecorderViewController()
        controller.audioRecorderDelegate = self
        lognote("g7r", google_userid, "\(Index)")

        let video = videoArray?[0] as? [String: Any]
        let videourl = video?["videoseven_path"] as? String
        let url = URL(string: videourl!)
        controller.childViewController.videourl = url
        controller.childViewController.clip = 7
        controller.childViewController.note = "說說看，我發現科學家的研究方法與結果有哪些特別的地方。"
        present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func recEight(_ sender: AnyObject) {
        
        let controller = AudioRecorderViewController()
        controller.audioRecorderDelegate = self
        lognote("g8r", google_userid, "\(Index)")

        let video = videoArray?[0] as? [String: Any]
        let videourl = video?["videoeight_path"] as? String
        let url = URL(string: videourl!)
        controller.childViewController.videourl = url
        controller.childViewController.clip = 8
        controller.childViewController.note = "說說看，我修改了哪些內容才讓我的解釋變得科學、有邏輯。"
        present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func delSeven(_ sender: Any) {
        let deleteAlert = UIAlertController(title:"確定要清空故事版7的影片嗎？",message: "刪除影片後無法復原！", preferredStyle: .alert)
        deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:{ (action) -> Void in
            SelectVideoUpload_One_Two().deleteVideoPath(sb: 7, self.previewSeven, self.recSeven, self.delSeven,self)
        }))
        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }
    @IBAction func delEight(_ sender: Any) {
        let deleteAlert = UIAlertController(title:"確定要清空故事版8的影片嗎？",message: "刪除影片後無法復原！", preferredStyle: .alert)
        deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:{ (action) -> Void in
            SelectVideoUpload_One_Two().deleteVideoPath(sb: 8, self.previewEight, self.recEight, self.delEight,self)
        }))
        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recSeven.isHidden = true
        recEight.isHidden = true
        delSeven.isHidden = true
        delEight.isHidden  = true
        check()
    }
    
    func check(){
        loadData()
    }
    
    func loadData() {
        
        let parameters: Parameters=["videoid": Index]
        Alamofire.request("http://140.122.76.201/CoInQ/v1/getvideoinfo.php", method: .post, parameters: parameters).responseJSON
            {
                response in
                
                guard response.result.isSuccess else {
                    let errorMessage = response.result.error?.localizedDescription
                    print(errorMessage!)
                    return
                }
                guard let JSON = response.result.value as? [String: Any] else {
                    print("JSON formate error")
                    return
                }
                
                if let videoinfo = JSON["videoURLtable"] as? [Any] {
                    videoArray = videoinfo
                    let video = videoArray?[0] as? [String: Any]
                    if !(video?.isEmpty)! {
                        let existone = SelectVideoUpload_One_Two().checkVideoExist(video!, "videoseven_path", 7)
                        let existtwo = SelectVideoUpload_One_Two().checkVideoExist(video!, "videoeight_path", 8)
                        switch (existone){
                        case 1:
                            self.previewVideo(video!, "videoseven_path", self.previewSeven,self.recSeven, self.delSeven)
                            switch (existtwo){
                            case 1:
                                self.previewVideo(video!, "videoeight_path", self.previewEight,self.recEight, self.delEight)
                            case 2:
                                self.startActivityIndicator()
                                let videourl = video?["videoeight_path"] as? String
                                let url = URL(string: videourl!)
                                SelectVideoUpload_One_Two().donloadVideo(url: url!,self.stopActivityIndicator(_:),8)
                            case 3:
                                break
                            default: break
                            }
                        case 2:
                            self.startActivityIndicator()
                            let videourl = video?["videoseven_path"] as? String
                            let url = URL(string: videourl!)
                            SelectVideoUpload_One_Two().donloadVideo(url: url!,self.stopActivityIndicator(_:),7)
                        case 3:
                            
                            switch (existtwo){
                            case 1:
                                self.previewVideo(video!, "videoeight_path", self.previewEight,self.recEight, self.delEight)
                            case 2:
                                self.startActivityIndicator()
                                let videourl = video?["videoeight_path"] as? String
                                let url = URL(string: videourl!)
                                SelectVideoUpload_One_Two().donloadVideo(url: url!,self.stopActivityIndicator(_:),8)
                            case 3:
                                break
                            default: break
                            }
                            
                        default: break
                        }
                        
                    }
                    
                }
        }
    }
    
    func previewVideo(_ videoinfo: [String: Any],_ videopath: String,_ preview: UIView,_ recbtn: UIButton,_ delbtn: UIButton){
        let videourl = videoinfo[videopath] as? String
        let url = URL(string: videourl!)
        self.player = AVPlayer(url: url!)
        self.playerController = AVPlayerViewController()
        self.playerController.player = self.player
        self.playerController.view.frame = preview.frame
        self.addChildViewController(self.playerController)
        self.view.addSubview(self.playerController.view)
        preview.isHidden = false
        recbtn.isHidden = false
        delbtn.isHidden = false
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
        let alertController = UIAlertController(title: "故事版\(clip)影片已同步\n您可以在相簿中找到", message: nil, preferredStyle: .alert)
        let checkagainAction = UIAlertAction(title: "OK", style: .default, handler:{
            (action) -> Void in
            self.check()
        })
        alertController.addAction(checkagainAction)
        self.present(alertController, animated: true, completion: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ExplainSeven(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小提示",message:"仔細觀察與記錄\n科學家使用的科學方法與研究結果。\n可以善用iPad螢幕錄製的功能！",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        lognote("ve7",google_userid,"\(Index)")
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func ExplainEight(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小提示",message:"試試看加入科學家提出的科學術語\n重新表達分析證據後的結果\n讓解釋看起來更專業！",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        lognote("ve8",google_userid,"\(Index)")
        self.present(myAlert, animated: true, completion: nil)
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
    
    func startCameraFromViewController(_ viewController: UIViewController, withDelegate delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            return false
        }
        
        let cameraController = UIImagePickerController()
        cameraController.allowsEditing = true
        cameraController.sourceType = .camera
        cameraController.mediaTypes = [kUTTypeMovie as NSString as String]
        cameraController.cameraCaptureMode = .video
        cameraController.videoQuality = .typeHigh
        cameraController.allowsEditing = true
        cameraController.delegate = delegate
        cameraController.videoMaximumDuration = 30.0
        
        present(cameraController, animated: true, completion: nil)
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
    
    @IBAction func loadAssetSeven(_ sender: AnyObject) {
        let alert = UIAlertController(title: "請選擇影片途徑", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "開啟相機進行錄影", style: .default, handler: {
            (action) -> Void in
            self.loadingAssetOne = true
            self.loadingCamera = true
            lognote("v7s", google_userid, "\(Index)")
            _ = self.startCameraFromViewController(self, withDelegate: self)
        }))
        alert.addAction(UIAlertAction(title: "打開相簿選擇影片", style: .default, handler: {
            (action) -> Void in
            if self.savedPhotosAvailable() {
                self.loadingAssetOne = true
                lognote("a7s", google_userid, "\(Index)")
                _ = self.startMediaBrowserFromViewController(self, usingDelegate: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "取消",style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func loadAssetEight(_ sender: AnyObject) {
        let alert = UIAlertController(title: "請選擇影片途徑", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "開啟相機進行錄影", style: .default, handler: {
            (action) -> Void in
            self.loadingAssetOne = false
            self.loadingCamera = true
            lognote("v8s", google_userid, "\(Index)")
            _ = self.startCameraFromViewController(self, withDelegate: self)
        }))
        alert.addAction(UIAlertAction(title: "打開相簿選擇影片", style: .default, handler: {
            (action) -> Void in
            if self.savedPhotosAvailable() {
                self.loadingAssetOne = false
                lognote("a8s", google_userid, "\(Index)")
                _ = self.startMediaBrowserFromViewController(self, usingDelegate: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "取消",style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func uploadVideo(mp4Path : URL , message : String, clip: Int,_ preview: UIView,_ recbtn: UIButton,_ delbtn: UIButton){
        
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
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title:"提示",message:message, preferredStyle: .alert)
                        let action2 = UIAlertAction(title: "OK", style: .default, handler: {
                            (action) -> Void in
                            SelectVideoUpload_Nine().update()
                            self.loadData()
                        })
                        alert.addAction(action2)
                        self.present(alert , animated: true , completion: nil)
                        lognote("u\(clip)s", google_userid, "\(Index)")
                    }else{
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title:"提示",message:"上傳失敗，請重新上傳", preferredStyle: .alert)
                        let action2 = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action2)
                        self.present(alert , animated: true , completion: nil)
                        lognote("u\(clip)f", google_userid, "\(Index)")
                    }
                }
                //上传进度
                upload.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                    //                    print("Upload Progress: \(progress.fractionCompleted)")
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
}


// MARK: - UIImagePickerControllerDelegate
extension SelectVideoUpload_Seven_Eight : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        if mediaType == kUTTypeMovie {
            let avAsset = info[UIImagePickerControllerMediaURL] as! URL
            var message = ""
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(avAsset.path) && loadingCamera {
                UISaveVideoAtPathToSavedPhotosAlbum(avAsset.path, self, nil, nil)
                loadingCamera = false
            }
            if loadingAssetOne {
                message = "故事版7 影片已匯入成功！"
                self.startActivityIndicator()
                let videoURL = avAsset
                uploadVideo(mp4Path: videoURL,message: message,clip:7, self.previewSeven,self.recSeven, self.delSeven)
            } else {
                message = "故事版8 影片已匯入成功！"
                self.startActivityIndicator()
                let videoURL = avAsset
                uploadVideo(mp4Path: videoURL,message: message,clip:8, self.previewEight,self.recEight, self.delEight)
            }

        }
    }
}

extension SelectVideoUpload_Seven_Eight: AudioRecorderViewControllerDelegate {
    func audioRecorderViewControllerDismissed(withFileURL fileURL: URL?,clip: Int) {
        dismiss(animated: true, completion: nil)
        if clip == 7 {
            self.startActivityIndicator()
            let message = "故事版7 影片已匯入成功！"
            self.uploadVideo(mp4Path: fileURL!, message: message, clip: 7, self.previewSeven, self.recSeven, self.delSeven)
        }else if clip == 8 {
            self.startActivityIndicator()
            let message = "故事版8 影片已匯入成功！"
            self.uploadVideo(mp4Path: fileURL!, message: message, clip: 8, self.previewEight, self.recEight, self.delEight)
        }
        
    }
}

// MARK: - UINavigationControllerDelegate
extension SelectVideoUpload_Seven_Eight : UINavigationControllerDelegate {
}

