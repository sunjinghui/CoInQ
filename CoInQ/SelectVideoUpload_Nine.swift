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
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var RecordButton: UIButton!
    
    var array: [Any]?
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
        
        checknine()
    }
    
    func checknine(){
        loadData()
    }
    
    func loadData() {
        let parameters: Parameters=["videoid": Index]
        array = []
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
                    self.array = videoinfo
                    var video = self.array?[0] as? [String: Any]
                    if !(video?.isEmpty)! {
                        let existone = SelectVideoUpload_One_Two().checkVideoExist(video!, "videonine_path", 9)
                        
                            switch (existone){
                            case 1:
                                self.ninecomplete.isHidden = false
                            case 2:
                                self.startActivityIndicator()

                                let videourl = video?["videonine_path"] as? String
                                let url = URL(string: videourl!)
                                SelectVideoUpload_One_Two().donloadVideo(url: url!, 9)
                                self.stopActivityIndicator()

                            case 3:
                                break
                            default: break
                            }
                        
                    }
                  
                }
        }

    }
    
    func check(_ videonum: String,_ storyboard: String){
        var video = videoArray?[0] as? [String: Any]
//        var video = array?[0] as? [String: Any]
        let videopath = video?[videonum] as? String
        if videopath == nil {
            nullstoryboard.append(storyboard)
            isURLempty = false
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
            self.checknine()
        }
        )
        alertController.addAction(checkagainAction)
        self.present(alertController, animated: true, completion: nil)
    }

    
    func isVideoLoaded() -> Bool {
        update()
        isURLempty = true
        nullstoryboard = [String]()
        check("videoone_path", "故事版 1")
        check("videotwo_path", "故事版 2")
        check("videothree_path", "故事版 3")
        check("videofour_path", "故事版 4")
        check("videofive_path", "故事版 5")
        check("videosix_path", "故事版 6")
        check("videoseven_path", "故事版 7")
        check("videoeight_path", "故事版 8")
        check("videonine_path", "故事版 9")
        
        return isURLempty
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
    
    func update(){
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
                    print("info loaded")
                }
        }
    }
    
    @IBAction func checkALLvideoLoaded(_ sender: AnyObject) {
        
        
        if isVideoLoaded() {
            
            let recordNavigationController = storyboard?.instantiateViewController(withIdentifier: "RecordNavigationController") as! RecordNavigationController
            
            present(recordNavigationController, animated: true, completion: nil)
            
        }else{
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


