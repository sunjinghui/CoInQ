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

class SelectVideoUpload_Seven_Eight : UIViewController{
    
    var loadingAssetOne = false
    
    @IBOutlet weak var sevencomplete: UIImageView!
    @IBOutlet weak var eightcomplete: UIImageView!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sevencomplete.isHidden = true
        eightcomplete.isHidden = true
        
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
                        if existone == 2 || existtwo == 2 {
                            print("first \(existone) \(existtwo)")
                            
                            self.startActivityIndicator()
                            
                            switch (existone){
                            case 1:
                                SelectVideoUpload_One_Two().showthumbnail(video!, "videoseven_path", self.sevencomplete)
                            case 2:
                                let videourl = video?["videoseven_path"] as? String
                                let url = URL(string: videourl!)
                                SelectVideoUpload_One_Two().donloadVideo(url: url!, 7)
                            case 3:
                                break
                            default: break
                            }
                            switch (existtwo){
                            case 1:
                                SelectVideoUpload_One_Two().showthumbnail(video!, "videoeight_path", self.eightcomplete)
                            case 2:
                                let videourl = video?["videoeight_path"] as? String
                                let url = URL(string: videourl!)
                                SelectVideoUpload_One_Two().donloadVideo(url: url!, 8)
                            case 3:
                                break
                            default: break
                            }
                            
                            self.stopActivityIndicator()
                        }else if existone == 3 || existtwo == 3 {
                            print("second \(existone) \(existtwo)")
                            
                            switch (existone){
                            case 1:
                                SelectVideoUpload_One_Two().showthumbnail(video!, "videoseven_path", self.sevencomplete)
                            case 2:
                                let videourl = video?["videoseven_path"] as? String
                                let url = URL(string: videourl!)
                                SelectVideoUpload_One_Two().donloadVideo(url: url!, 7)
                            case 3:
                                break
                            default: break
                            }
                            switch (existtwo){
                            case 1:
                                let videourl = video?["videoeight_path"] as? String
                                let url = URL(string: videourl!)
                                let asset = AVURLAsset(url: url!, options: nil)
                                let imgGenerator = AVAssetImageGenerator(asset: asset)
                                imgGenerator.appliesPreferredTrackTransform = false
                                
                                do {
                                    let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                                    let thumbnail = UIImage(cgImage: cgImage)
                                    
                                    self.eightcomplete.image = thumbnail
                                    
                                } catch let error {
                                    print("*** Error generating thumbnail: \(error)")
                                }
                                SelectVideoUpload_One_Two().showthumbnail(video!, "videoeight_path", self.eightcomplete)
                            case 2:
                                let videourl = video?["videoeight_path"] as? String
                                let url = URL(string: videourl!)
                                SelectVideoUpload_One_Two().donloadVideo(url: url!, 8)
                            case 3:
                                break
                            default: break
                            }
                        }else{
                            print("third \(existone) \(existtwo)")
                            SelectVideoUpload_One_Two().showthumbnail(video!, "videoseven_path", self.sevencomplete)
                            SelectVideoUpload_One_Two().showthumbnail(video!, "videoeight_path", self.eightcomplete)
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
    
    func stopActivityIndicator() {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        
        let alertController = UIAlertController(title: "影片已同步\n您可以在相簿中找到", message: nil, preferredStyle: .alert)
        let checkagainAction = UIAlertAction(title: "OK", style: .default, handler:
        {
            (action) -> Void in
            self.check()
        }
        )
        alertController.addAction(checkagainAction)
        self.present(alertController, animated: true, completion: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ExplainSeven(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小提示",message:"仔細觀察與紀錄\n科學家使用的科學方法與研究結果吧！",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        lognote("ve7",google_userid,"\(Index)")
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func ExplainEight(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小提示",message:"試試看加入科學家提出的科學術語，\n讓解釋看起來更專業！",preferredStyle: .alert)
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
    
    func startMediaBrowserFromViewController(_ viewController: UIViewController!, usingDelegate delegate : (UINavigationControllerDelegate & UIImagePickerControllerDelegate)!) -> Bool {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            return false
        }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .savedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
        present(mediaUI, animated: true, completion: nil)
        return true
    }
    
    @IBAction func loadAssetSeven(_ sender: AnyObject) {
        
        if savedPhotosAvailable() {
            loadingAssetOne = true
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
    
    
    @IBAction func loadAssetEight(_ sender: AnyObject) {
        if savedPhotosAvailable() {
            loadingAssetOne = false
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
    
    func uploadVideo(mp4Path : URL , message : String, clip: Int,VC: UIViewController,check: UIImageView){
        
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
                    print("\(result)")
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
                            let asset = AVURLAsset(url: mp4Path, options: nil)
                            let imgGenerator = AVAssetImageGenerator(asset: asset)
                            imgGenerator.appliesPreferredTrackTransform = false
                            
                            do {
                                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                                let thumbnail = UIImage(cgImage: cgImage)
                                
                                check.image = thumbnail
                                
                            } catch let error {
                                print("*** Error generating thumbnail: \(error)")
                            }
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
extension SelectVideoUpload_Seven_Eight : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        if mediaType == kUTTypeMovie {
            let avAsset = info[UIImagePickerControllerMediaURL] as! URL
            var message = ""
            if loadingAssetOne {
                message = "故事版7 影片已匯入成功！"
                self.startActivityIndicator()
                let videoURL = avAsset
                uploadVideo(mp4Path: videoURL,message: message,clip:7,VC: self,check: self.sevencomplete)
                loadData()
            } else {
                message = "故事版8 影片已匯入成功！"
                self.startActivityIndicator()
                let videoURL = avAsset
                uploadVideo(mp4Path: videoURL,message: message,clip:8,VC: self,check: self.eightcomplete)
                loadData()

            }

        }
    }
}

// MARK: - UINavigationControllerDelegate
extension SelectVideoUpload_Seven_Eight : UINavigationControllerDelegate {
}

