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

class SelectVideoUpload_Five_Six : UIViewController{
    
    var loadingAssetOne = false
    
    @IBOutlet weak var fivecomplete: UIImageView!
    @IBOutlet weak var sixcomplete: UIImageView!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBAction func ExplainFive(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小解釋",message:"便條紙是一個適合用來\n分類與比較證據的小工具喔！",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func ExplainSix(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小解釋",message:"文字、聲音、影片都是適合紀錄可能原因的方式。",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fivecomplete.isHidden = true
        sixcomplete.isHidden = true
        
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
                        if existone == 2 || existtwo == 2 {
                            print("first \(existone) \(existtwo)")
                            
                            self.startActivityIndicator()
                            
                            switch (existone){
                            case 1:
                                self.fivecomplete.isHidden = false
                            case 2:
                                let videourl = video?["videofive_path"] as? String
                                let url = URL(string: videourl!)
                                SelectVideoUpload_One_Two().donloadVideo(url: url!, 5)
                            case 3:
                                break
                            default: break
                            }
                            switch (existtwo){
                            case 1:
                                self.sixcomplete.isHidden = false
                            case 2:
                                let videourl = video?["videosix_path"] as? String
                                let url = URL(string: videourl!)
                                SelectVideoUpload_One_Two().donloadVideo(url: url!, 6)
                            case 3:
                                break
                            default: break
                            }
                            
                            self.stopActivityIndicator()
                        }else if existone == 3 || existtwo == 3 {
                            print("second \(existone) \(existtwo)")
                            
                            switch (existone){
                            case 1:
                                self.fivecomplete.isHidden = false
                            case 2:
                                let videourl = video?["videofive_path"] as? String
                                let url = URL(string: videourl!)
                                SelectVideoUpload_One_Two().donloadVideo(url: url!, 5)
                            case 3:
                                break
                            default: break
                            }
                            switch (existtwo){
                            case 1:
                                self.sixcomplete.isHidden = false
                            case 2:
                                let videourl = video?["videosix_path"] as? String
                                let url = URL(string: videourl!)
                                SelectVideoUpload_One_Two().donloadVideo(url: url!, 6)
                            case 3:
                                break
                            default: break
                            }
                        }else{
                            print("third \(existone) \(existtwo)")
                            self.fivecomplete.isHidden = false
                            self.sixcomplete.isHidden = false
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
    
    @IBAction func loadAssetFive(_ sender: AnyObject) {
        
        if savedPhotosAvailable() {
            loadingAssetOne = true
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
    
    
    @IBAction func loadAssetSix(_ sender: AnyObject) {
        if savedPhotosAvailable() {
            loadingAssetOne = false
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }
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
            if loadingAssetOne {
                message = "故事版5 影片已匯入成功！"
                let videoURL = avAsset
                SelectVideoUpload_One_Two().uploadVideo(mp4Path: videoURL,message: message,clip:5,VC: self,check: self.fivecomplete)
                loadData()
            } else {
                message = "故事版6 影片已匯入成功！"
                let videoURL = avAsset
                SelectVideoUpload_One_Two().uploadVideo(mp4Path: videoURL,message: message,clip:6,VC: self,check: self.sixcomplete)
                loadData()

            }

        }
    }
}

// MARK: - UINavigationControllerDelegate
extension SelectVideoUpload_Five_Six : UINavigationControllerDelegate {
}

