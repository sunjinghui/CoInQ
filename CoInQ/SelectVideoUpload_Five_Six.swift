//
//  SelectVideoUpload_Five_Six.swift
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

class SelectVideoUpload_Five_Six : UIViewController{
    
    var loadingAssetOne = false
    var loadingCamera = false
    var isClicked = true
    var previewFive = VideoPreviewButton(frame: CGRect(x: 225,y: 274,width: 465,height: 257))
    var previewSix = VideoPreviewButton(frame: CGRect(x: 225,y: 675,width: 465,height: 257))
    
    @IBOutlet weak var recFive: UIButton!
    @IBOutlet weak var recSix: UIButton!
    @IBOutlet weak var delFive: UIButton!
    @IBOutlet weak var delSix: UIButton!
    
    var player: AVPlayer!
    var playerController = AVPlayerViewController()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBAction func StageTitleThree(_ sender: UIButton) {
        lognote("h3d", google_userid, "\(Index)")
        if isClicked {
            isClicked = false
            sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
            sender.setTitle("篩選過的「資料」作為 「證據」，分析「證據」來得出可能的解釋", for: UIControlState())
        }else{
            isClicked = true
            sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
            sender.setTitle("分析證據", for: UIControlState())
        }
    }
    
    @IBAction func recFive(_ sender: AnyObject) {
        
        let controller = AudioRecorderViewController()
        controller.audioRecorderDelegate = self
        lognote("g5r", google_userid, "\(Index)")

        let video = videoArray?[0] as? [String: Any]
        let videourl = video?["videofive_path"] as? String
        let url = URL(string: videourl!)
        controller.childViewController.videourl = url
        controller.childViewController.clip = 5
        controller.childViewController.note = "說說看，我運用哪些策略來分類證據，和這樣分類的原因。"
        present(controller, animated: true, completion: nil)
        
    }
    @IBAction func recSix(_ sender: AnyObject) {
        
        let controller = AudioRecorderViewController()
        controller.audioRecorderDelegate = self
        lognote("g6r", google_userid, "\(Index)")

        let video = videoArray?[0] as? [String: Any]
        let videourl = video?["videosix_path"] as? String
        let url = URL(string: videourl!)
        controller.childViewController.videourl = url
        controller.childViewController.clip = 6
        controller.childViewController.note = "解釋文字、圖表或影片來呈現我認為可能的原因。"
        present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func delFive(_ sender: Any) {
        let deleteAlert = UIAlertController(title:"確定要清空故事版5的影片嗎？",message: "刪除影片後無法復原！", preferredStyle: .alert)
        deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:{ (action) -> Void in
            SelectVideoUpload_One_Two().deleteVideoPath(sb: 5, self.previewFive,self.recFive,self.delFive,self)
        }))
        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    @IBAction func delSix(_ sender: Any) {
        let deleteAlert = UIAlertController(title:"確定要清空故事版6的影片嗎？",message: "刪除影片後無法復原！", preferredStyle: .alert)
        deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:{ (action) -> Void in
            SelectVideoUpload_One_Two().deleteVideoPath(sb: 6, self.previewSix, self.recSix, self.delSix,self)
        }))
        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    @IBAction func ExplainFive(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小提示",message:"在清單中的每一筆影片證據後面\n寫下其中包含的多個詳細資訊。\n在這麼多資訊中找出它們的關聯\n用不同的顏色標記\n或把同一類的圈起來、框起來。\n拍下你的分類過程!",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        lognote("ve5",google_userid,"\(Index)")
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func ExplainSix(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小提示",message:"可以用文字、圖表、聲音、影片\n呈現分析證據的結果。",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        lognote("ve6",google_userid,"\(Index)")
        self.present(myAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recFive.isHidden = true
        recSix.isHidden = true
        delFive.isHidden = true
        delSix.isHidden = true
        check()
    }
    
    func check(){
        loadData()
    }
    
    func loadData(){
        
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
                        let existone = SelectVideoUpload_One_Two().checkVideoExist(video!, "videofive_path", 5)
                        let existtwo = SelectVideoUpload_One_Two().checkVideoExist(video!, "videosix_path", 6)
                        switch (existone){
                        case 1:
                            self.showthumbnail(video!, "videofive_path", self.previewFive,self.recFive, self.delFive)
                            switch (existtwo){
                            case 1:
                                self.showthumbnail(video!, "videosix_path", self.previewSix, self.recSix, self.delSix)
                            case 2:
                                self.startActivityIndicator()
                                let videourl = video?["videosix_path"] as? String
                                let url = URL(string: videourl!)
                                SelectVideoUpload_One_Two().donloadVideo(url: url!,self.stopActivityIndicator(_:),6)
                            case 3:
                                break
                            default: break
                            }
                        case 2:
                            self.startActivityIndicator()
                            let videourl = video?["videofive_path"] as? String
                            let url = URL(string: videourl!)
                            SelectVideoUpload_One_Two().donloadVideo(url: url!,self.stopActivityIndicator(_:),5)
                        case 3:
                            
                            switch (existtwo){
                            case 1:
                                self.showthumbnail(video!, "videosix_path", self.previewSix,self.recSix, self.delSix)
                            case 2:
                                self.startActivityIndicator()
                                let videourl = video?["videosix_path"] as? String
                                let url = URL(string: videourl!)
                                SelectVideoUpload_One_Two().donloadVideo(url: url!,self.stopActivityIndicator(_:),6)
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

    func showthumbnail(_ videoinfo: [String: Any],_ videopath: String,_ check: VideoPreviewButton,_ recbtn: UIButton,_ delbtn: UIButton){
        let videourl = videoinfo[videopath] as? String
        let url = URL(string: videourl!)
        let asset = AVURLAsset(url: url!, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = false
        
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            check.setImage(thumbnail, for: .normal)
            check.addTarget(self, action: #selector(self.playPreviewVideo), for: .touchUpInside)
            check.videopath = videourl
        } catch let error {
            print("*** Error generating thumbnail: \(error)")
        }
        
        self.view.addSubview(check)
        recbtn.isHidden = false
        delbtn.isHidden = false
    }
    
    func playPreviewVideo(_ sender: VideoPreviewButton!){
        let Player = AVPlayer(url: URL(string: sender.videopath!)!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = Player
        self.present(playerViewController,animated: true){
            playerViewController.player!.play()
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
    
    @IBAction func loadAssetFive(_ sender: AnyObject) {
        let alert = UIAlertController(title: "請選擇影片途徑", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "開啟相機進行錄影", style: .default, handler: {
            (action) -> Void in
            self.loadingAssetOne = true
            self.loadingCamera = true
            lognote("v5s", google_userid, "\(Index)")
            _ = self.startCameraFromViewController(self, withDelegate: self)
        }))
        alert.addAction(UIAlertAction(title: "打開相簿選擇影片", style: .default, handler: {
            (action) -> Void in
            if self.savedPhotosAvailable() {
                self.loadingAssetOne = true
                lognote("a5s", google_userid, "\(Index)")
                _ = self.startMediaBrowserFromViewController(self, usingDelegate: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "取消",style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func loadAssetSix(_ sender: AnyObject) {
        let alert = UIAlertController(title: "請選擇影片途徑", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "開啟相機進行錄影", style: .default, handler: {
            (action) -> Void in
            self.loadingAssetOne = false
            self.loadingCamera = true
            lognote("v6s", google_userid, "\(Index)")
            _ = self.startCameraFromViewController(self, withDelegate: self)
        }))
        alert.addAction(UIAlertAction(title: "打開相簿選擇影片", style: .default, handler: {
            (action) -> Void in
            if self.savedPhotosAvailable() {
                self.loadingAssetOne = false
                lognote("a6s", google_userid, "\(Index)")
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
                        print("Upload Succes")
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
                        print("Upload Failed")
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
extension SelectVideoUpload_Five_Six : UIImagePickerControllerDelegate {
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
                message = "故事版5 影片已匯入成功！"
                self.startActivityIndicator()
                let videoURL = avAsset
                uploadVideo(mp4Path: videoURL,message: message,clip:5, self.previewFive,self.recFive, self.delFive)
            } else {
                message = "故事版6 影片已匯入成功！"
                self.startActivityIndicator()
                let videoURL = avAsset
                uploadVideo(mp4Path: videoURL,message: message,clip:6, self.previewSix,self.recSix, self.delSix)

            }

        }
    }
}

extension SelectVideoUpload_Five_Six: AudioRecorderViewControllerDelegate {
    func audioRecorderViewControllerDismissed(withFileURL fileURL: URL?,clip: Int) {
        dismiss(animated: true, completion: nil)
        if clip == 5 {
            self.startActivityIndicator()
            let message = "故事版5 影片已匯入成功！"
            self.uploadVideo(mp4Path: fileURL!, message: message, clip: 5, self.previewFive, self.recFive, self.delFive)
        }else if clip == 6 {
            self.startActivityIndicator()
            let message = "故事版6 影片已匯入成功！"
            self.uploadVideo(mp4Path: fileURL!, message: message, clip: 6, self.previewSix, self.recSix, self.delSix)
        }
        
    }
}

// MARK: - UINavigationControllerDelegate
extension SelectVideoUpload_Five_Six : UINavigationControllerDelegate {
}

