//
//  SelectVideoUpload_Nine.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import MobileCoreServices
import MediaPlayer
import Alamofire

class SelectVideoUpload_Nine : UIViewController{
    
    @IBOutlet weak var RecordButton: UIButton!
    
    var videoarray: [Any]?
    var isURLempty = true
    var buttonClicked = true
    var loadingAssetOne = false
    var nullstoryboard = [String]()

    var printArray: String{
        var str = ""
        for element in nullstoryboard {
            str += "\n\(element)"
        }
        return str
    }
    
    
    @IBOutlet weak var ninecomplete: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ninecomplete.isHidden = true
        RecordButton.layer.cornerRadius = 8
        
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
                // 2.
                if let videoinfo = JSON["videoURLtable"] as? [Any] {
                    self.videoarray = videoinfo
                    print("video info loaded")
                    var video = self.videoarray?[0] as? [String: Any]
                    let videopath = video?["videonine_path"] as? String
                    if !(videopath == nil) {
                        let url = URL(string: videopath!)
                        if FileManager.default.fileExists(atPath: (url?.path)!) {
                            print("FILE FOUND")
                        } else {
                            //self.donloadVideo(url: url!)
                            print("FILE NOT FOUND")
                        }
                        self.ninecomplete.isHidden = false
                    }
                  
                        self.isURLempty = true
                        self.nullstoryboard = [String]()
                        let videopathone = video?["videoone_path"] as? String
                        if (videopathone == nil) {
                            self.nullstoryboard.append("故事版 1")
                            self.isURLempty = false
                        }
                        let videopathtwo = video?["videotwo_path"] as? String
                        if (videopathtwo == nil) {
                            self.nullstoryboard.append("故事版 2")
                            self.isURLempty = false
                        }
                        let videopath3 = video?["videothree_path"] as? String
                        if (videopath3 == nil) {
                            self.nullstoryboard.append("故事版 3")
                            self.isURLempty = false
                        }
                        let videopath4 = video?["videofour_path"] as? String
                        if (videopath4 == nil) {
                            self.nullstoryboard.append("故事版 4")
                            self.isURLempty = false
                        }
                        let videopath5 = video?["videofive_path"] as? String
                        if (videopath5 == nil) {
                            self.nullstoryboard.append("故事版 5")
                            self.isURLempty = false
                        }
                        let videopath6 = video?["videosix_path"] as? String
                        if (videopath6 == nil) {
                            self.nullstoryboard.append("故事版 6")
                            self.isURLempty = false
                        }
                        let videopath7 = video?["videoseven_path"] as? String
                        if (videopath7 == nil) {
                            self.nullstoryboard.append("故事版 7")
                            self.isURLempty = false
                        }
                        let videopath8 = video?["videoeight_path"] as? String
                        if (videopath8 == nil) {
                            self.nullstoryboard.append("故事版 8")
                            self.isURLempty = false
                        }
                        let videopath9 = video?["videonine_path"] as? String
                        if (videopath9 == nil) {
                            self.nullstoryboard.append("故事版 9")
                            self.isURLempty = false
                        }
                    
                }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ExplainNine(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小解釋",message:"積極分享是勇氣，願意回饋是美德。",preferredStyle: .alert)
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
    
    @IBAction func loadAssetNine(_ sender: AnyObject) {
        
        if savedPhotosAvailable() {
            loadingAssetOne = true
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
    
//    func isURLempty(_ key: String) -> Bool {
//
//        if videourl.value(forKey: key) != nil{
//            return true
//        }else{
//            return false
//        }
//    }
    
    
    @IBAction func checkALLvideoLoaded(_ sender: AnyObject) {
        loadData()

        if isURLempty {
            
            let recordNavigationController = storyboard?.instantiateViewController(withIdentifier: "RecordNavigationController") as! RecordNavigationController
            
            present(recordNavigationController, animated: true, completion: nil)
            
        }else{
            loadData()
            let alertController = UIAlertController(title: "請注意", message: "你還有故事版未上傳 ,請確認\(printArray)", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }

        /*if isURLempty("RecordOne") || isURLempty("RecordTwo") {
            UserDefaults.standard.removeObject(forKey: "RecordOne")
            UserDefaults.standard.removeObject(forKey: "RecordTwo")
        }*/
        
    }
}


// MARK: - UIImagePickerControllerDelegate
extension SelectVideoUpload_Nine : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        if mediaType == kUTTypeMovie {
            let avAsset = info[UIImagePickerControllerMediaURL] as! URL
            var message = ""
            if loadingAssetOne {
                message = "故事版9 影片已匯入成功！"
                let videoURL = avAsset
                SelectVideoUpload_One_Two().uploadVideo(mp4Path: videoURL,message: message,clip:9,VC: self,check: self.ninecomplete)
                loadData()

            }
            
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension SelectVideoUpload_Nine : UINavigationControllerDelegate {
}


