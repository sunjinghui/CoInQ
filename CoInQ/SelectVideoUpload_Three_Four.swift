//
//  SelectVideoUpload_Three_Four.swift
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

class SelectVideoUpload_Three_Four : UIViewController{
    
    var loadingAssetOne = false
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
//    @IBOutlet weak var threecomplete: UIImageView!
//    @IBOutlet weak var fourcomplete: UIImageView!
    @IBOutlet weak var previewThree: UIView!
    @IBOutlet weak var StageTitle: UIButton!
    var player: AVPlayer!
    var playerController = AVPlayerViewController()
    
    @IBAction func Cooperation(_ sender: Any){
        let navigationtableview = storyboard?.instantiateViewController(withIdentifier: "TableNavigationController") as! TableNavigationController
        present(navigationtableview, animated: true, completion: nil)
//        self.navigationController?.pushViewController(navigationtableview, animated: true)
    }
    
    @IBAction func ExplainThree(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小提示",message:"心智圖是一個適合用來制定蒐集計畫的好工具。",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        lognote("ve3",google_userid,"\(Index)")
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func ExplainFour(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小提示",message:"我們可以邀請夥伴加入蒐集證據的行列。",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        lognote("ve4",google_userid,"\(Index)")
        self.present(myAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewThree.isHidden = true
//        fourcomplete.isHidden = true
        check()
    }
    
    func check(){
        loaddata()
    }
    
    func loaddata(){
        
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
                        let existone = SelectVideoUpload_One_Two().checkVideoExist(video!, "videothree_path", 3)

                            switch (existone){
                            case 1:
                                SelectVideoUpload_One_Two().previewVideo(video!, "videothree_path", self.previewThree)
                                
                            case 2:
                                self.startActivityIndicator()
                                let videourl = video?["videothree_path"] as? String
                                let url = URL(string: videourl!)
                                SelectVideoUpload_One_Two().donloadVideo(url: url!,self.stopActivityIndicator(_:),3)
                            case 3:
                                break
                            default: break
                            }
                    }
                    
                }
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
//        mediaUI.videoMaximumDuration = 30.0
        present(mediaUI, animated: true, completion: nil)
        return true
    }
    
    @IBAction func loadAssetThree(_ sender: AnyObject) {
        let alert = UIAlertController(title: "請選擇影片途徑", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "開啟相機進行錄影", style: .default, handler: {
            (action) -> Void in
            self.loadingAssetOne = true
            _ = self.startCameraFromViewController(self, withDelegate: self)
        }))
        alert.addAction(UIAlertAction(title: "打開相簿選擇影片", style: .default, handler: {
            (action) -> Void in
            if self.savedPhotosAvailable() {
                self.loadingAssetOne = true
                _ = self.startMediaBrowserFromViewController(self, usingDelegate: self)
            }
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
//    @IBAction func loadAssetFour(_ sender: AnyObject) {
//        if savedPhotosAvailable() {
//            loadingAssetOne = false
//            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
//        }
//    }
    
    func uploadVideo(mp4Path : URL , message : String, clip: Int,VC: UIViewController,check: UIView){
        
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
                            self.player = AVPlayer(url: mp4Path)
                            self.playerController = AVPlayerViewController()
                            self.playerController.player = self.player
                            self.playerController.view.frame = check.frame
                            self.addChildViewController(self.playerController)
                            self.view.addSubview(self.playerController.view)
                            check.isHidden = false
                        })
                        alert.addAction(action2)
                        VC.present(alert , animated: true , completion: nil)
                        lognote("u\(clip)s", google_userid, "\(Index)")
                    }else{
                        print("Upload Failed")
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title:"提示",message:"上傳失敗，請重新上傳", preferredStyle: .alert)
                        let action2 = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action2)
                        VC.present(alert , animated: true , completion: nil)
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
extension SelectVideoUpload_Three_Four : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        if mediaType == kUTTypeMovie {
            let avAsset = info[UIImagePickerControllerMediaURL] as! URL
            var message = ""
            guard let path = (info[UIImagePickerControllerMediaURL] as! NSURL).path else { return }
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path) {
                UISaveVideoAtPathToSavedPhotosAlbum(path, self, nil, nil)
            }
            if loadingAssetOne {
                message = "故事版3 影片已匯入成功！"
                self.startActivityIndicator()
                let videoURL = avAsset
                uploadVideo(mp4Path: videoURL,message: message,clip:3,VC: self,check: self.previewThree)
                loaddata()
            }
//            else {
//                message = "故事版4 影片已匯入成功！"
//                self.startActivityIndicator()
//                let videoURL = avAsset
//                uploadVideo(mp4Path: videoURL,message: message,clip:4,VC: self,check: self.previewThree)
//                loaddata()
//            }
            
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension SelectVideoUpload_Three_Four : UINavigationControllerDelegate {
}

