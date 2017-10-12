//
//  SelectVideoUpload_1&2.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import MobileCoreServices
import MediaPlayer
import CoreData
import Alamofire
import SwiftyJSON

var videoArray: [Any]?

class SelectVideoUpload_One_Two : UIViewController{
    
    var loadingAssetOne = false
//    var firstAsset: URL?
//    var secondAsset: URL?

//    var VideoNameArray = [VideoTaskInfo]()
//    var managedObjextContext: NSManagedObjectContext!
    
    @IBOutlet weak var firstcomplete: UIImageView!
    @IBOutlet weak var secondcomplete: UIImageView!
    
    @IBAction func ExplainOne(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小解釋",message:"圖片與影片是記錄「自然現象」最佳的工具喔！",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func ExplainTwo(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小解釋",message:"例如：\n天空為什麼會出現彩虹？\n天空中的彩虹是如何形成的？",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
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
    
    
    @IBAction func loadAssetOne(_ sender: AnyObject) {
        
        if savedPhotosAvailable() {
            loadingAssetOne = true
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
    
    
    @IBAction func loadAssetTwo(_ sender: AnyObject) {
        if savedPhotosAvailable() {
            loadingAssetOne = false
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let requestUrl = "http://140.122.76.201/CoInQ/v1/upload/circle1_1.png"
//        
//        Alamofire.request( requestUrl, method: .get)
//            .downloadProgress { progress in
//                print("Download Progress: \(progress.fractionCompleted)")
//            }
//            .responseData { response in
//                if let data = response.result.value {
//                    let image = UIImage(data: data)
//                    if image != nil {
//                        self.firstcomplete.image = image
//                        print("image load success")
//                    } else {
//                        print("image hasn't been generated yet")
//                    }
//                }
//        }
        
        firstcomplete.isHidden = true
        secondcomplete.isHidden = true
//        managedObjextContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        loadData()
    }
    
    func loadData(){
        getvideoinfo(pathone: "videoone_path", checkone: self.firstcomplete, pathtwo: "videotwo_path", checktwo: self.secondcomplete)
    }
    
    func getvideoinfo(pathone: String,checkone: UIImageView,pathtwo: String,checktwo:UIImageView){
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
                // 2.
                if let videoinfo = JSON["videoURLtable"] as? [Any] {
                    videoArray = videoinfo
                    var video = videoArray?[0] as? [String: Any]
                    let videoone = video?[pathone] as? String
                    let videotwo = video?[pathtwo] as? String
                    if !(videoone == nil) {
                        checkone.isHidden = false
                    }
                    if !(videotwo == nil) {
                        checktwo.isHidden = false
                    }
                }
        }
    }

//    func loadData() {
//        let videotaskRequest: NSFetchRequest<VideoTaskInfo> = VideoTaskInfo.fetchRequest()
//        do {
//            VideoNameArray = try managedObjextContext.fetch(videotaskRequest)
//            
//            if (VideoNameArray[Index].videoone) != nil {
//                print("videoone is not empty")
//                self.firstAsset = URL(string: VideoNameArray[Index].videoone!)
//                firstcomplete.isHidden = false
//            }
//            
//            if (VideoNameArray[Index].videotwo) != nil{
//                print("videotwo is not empty")
//                self.secondAsset = URL(string: VideoNameArray[Index].videotwo!)
//                secondcomplete.isHidden = false
//            }
//        }catch {
//            print("Could not load data from coredb \(error.localizedDescription)")
//        }
//
//        
//    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //上传视频到服务器
    func uploadVideo(mp4Path : URL , message : String, clip: Int,VC: UIViewController,check: UIImageView){
        
        Alamofire.upload(
            //同样采用post表单上传
            multipartFormData: { multipartFormData in

                multipartFormData.append(mp4Path, withName: "file")//, fileName: "123456.mp4", mimeType: "video/mp4")
                multipartFormData.append("\(Index)".data(using: String.Encoding.utf8, allowLossyConversion: false)!,withName: "videoid")
                multipartFormData.append(google_userid.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "google_userid")
                multipartFormData.append(mp4Path.absoluteString.data(using: String.Encoding.utf8, allowLossyConversion: false)!,withName: "videopath")
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
                        let alert = UIAlertController(title:"提示",message:message, preferredStyle: .alert)
                        let action2 = UIAlertAction(title: "OK", style: .default, handler: {
                            (action) -> Void in
                            check.isHidden = false
                        })
                        alert.addAction(action2)
                        VC.present(alert , animated: true , completion: nil)
                    }else{
                        print("Upload Failed")
                        let alert = UIAlertController(title:"提示",message:"上傳失敗，請重新上傳", preferredStyle: .alert)
                        let action2 = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action2)
                        VC.present(alert , animated: true , completion: nil)
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
    
}


// MARK: - UIImagePickerControllerDelegate
extension SelectVideoUpload_One_Two : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        if mediaType == kUTTypeMovie {
            let avAsset = info[UIImagePickerControllerMediaURL] as! URL
            var message = ""
            
            if loadingAssetOne {
                message = "故事版1 影片已匯入成功！"
//                firstAsset = avAsset
//                firstcomplete.isHidden = false
//                VideoNameArray[Index].videoone = firstAsset?.absoluteString
                
                let videoURL = avAsset
                self.uploadVideo(mp4Path: videoURL,message: message,clip:1,VC: self,check: self.firstcomplete)
                loadData()
            } else {
                message = "故事版2 影片已匯入成功！"
//                secondAsset = avAsset
//                secondcomplete.isHidden = false
//                VideoNameArray[Index].videotwo = secondAsset?.absoluteString
//                self.loadData()
                let videoURL = avAsset
                self.uploadVideo(mp4Path: videoURL,message: message,clip:2,VC: self,check: self.secondcomplete)
                loadData()

            }
            
            loadData()
            
//            let alert = UIAlertController(title: "太棒了", message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
//            present(alert, animated: true, completion: nil)
            

            //let userdefault = UserDefaults.standard
            //userdefault.set(firstAsset, forKey: "VideoOne")
            //userdefault.set(secondAsset, forKey: "VideoTwo")
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension SelectVideoUpload_One_Two : UINavigationControllerDelegate {
}
