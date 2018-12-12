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
import Alamofire
import SwiftyJSON
import Photos
import AVKit
import MPCoachMarks

    var videoArray: [Any]?

class VideoPreviewButton: UIButton{
    var videopath: String?
}

class SelectVideoUpload_One_Two : UIViewController{
    
    var loadingAssetOne = false
    var loadingCamera = false
    var isClicked = true
    var Asset : AVAsset?
    var player: AVPlayer!
    var playerController = AVPlayerViewController()
    var previewOne = VideoPreviewButton(frame: CGRect(x: 225,y: 274,width: 465,height: 257))
    var previewTwo = VideoPreviewButton(frame: CGRect(x: 225,y: 675,width: 465,height: 257))
    var coachMarksView = MPCoachMarks()

    @IBOutlet weak var recAudio: UIButton!
    @IBOutlet weak var recAudioTwo: UIButton!
    @IBOutlet weak var deletVideopath: UIButton!
    @IBOutlet weak var delTwo: UIButton!
    
    @IBAction func AudioRecord(_ sender: AnyObject) {
        
        let controller = AudioRecorderViewController()
        controller.audioRecorderDelegate = self
        
        let video = videoArray?[0] as? [String: Any]
        let videourl = video?["videoone_path"] as? String
        let url = URL(string: videourl!)
        controller.childViewController.videourl = url
        controller.childViewController.clip = 1
        
        present(controller, animated: true, completion: nil)
        
    }
    @IBAction func AudioRecordTwo(_ sender: AnyObject) {
        
        let controller = AudioRecorderViewController()
        controller.audioRecorderDelegate = self
        
        let video = videoArray?[0] as? [String: Any]
        let videourl = video?["videotwo_path"] as? String
        let url = URL(string: videourl!)
        controller.childViewController.videourl = url
        controller.childViewController.clip = 2
        present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func deletVideopath(_ sender: Any) {
        let deleteAlert = UIAlertController(title:"確定要清空故事版1的影片嗎？",message: "刪除影片後無法復原！", preferredStyle: .alert)
        deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:{ (action) -> Void in
            self.deleteVideoPath(sb: 1, self.previewOne,self.recAudio,self.deletVideopath, self)
        }))
        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    @IBAction func delTwo(_ sender: Any) {
        let deleteAlert = UIAlertController(title:"確定要清空故事版2的影片嗎？",message: "刪除影片後無法復原！", preferredStyle: .alert)
        deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:{ (action) -> Void in
            self.deleteVideoPath(sb: 2, self.previewTwo,self.recAudioTwo,self.delTwo, self)
        }))
        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBAction func StageTitleOne(_ sender: UIButton) {
        if isClicked {
            isClicked = false
            sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
            sender.setTitle("科學探究皆從一個問題開始", for: UIControlState())
        }else{
            isClicked = true
            sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
            sender.setTitle("決定問題", for: UIControlState())
        }
    }
    
    @IBAction func ExplainOne(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小提示",message:"將我想要探究的自然現象記錄下來吧！",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:nil)
        myAlert.addAction(action)
        lognote("ve1",google_userid,"\(Index)")
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func ExplainTwo(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小提示",message:"試著用「為什麼」或「如何」來表示我的探究問題吧！",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:nil)
        myAlert.addAction(action)
        lognote("ve2",google_userid,"\(Index)")
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
        mediaUI.videoMaximumDuration = 30.0
        present(mediaUI, animated: true, completion: nil)
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
    
//    func video(_ videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
//        var title = "成功"
//        var message = "影片已儲存"
//        if let _ = error {
//            title = "出錯"
//            message = "影片儲存失敗"
//        }
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.cancel, handler: nil))
//        present(alert, animated: true, completion: nil)
//    }
    
    @IBAction func loadAssetOne(_ sender: AnyObject) {
        let alert = UIAlertController(title: "請選擇影片途徑", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "開啟相機進行錄影", style: .default, handler: {
            (action) -> Void in
            self.loadingAssetOne = true
            self.loadingCamera = true
            _ = self.startCameraFromViewController(self, withDelegate: self)
        }))
        alert.addAction(UIAlertAction(title: "打開相簿選擇影片", style: .default, handler: {
            (action) -> Void in
            if self.savedPhotosAvailable() {
                self.loadingAssetOne = true
                _ = self.startMediaBrowserFromViewController(self, usingDelegate: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "取消",style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func loadAssetTwo(_ sender: AnyObject) {
        let alert = UIAlertController(title: "請選擇影片途徑", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "開啟相機進行錄影", style: .default, handler: {
            (action) -> Void in
            self.loadingAssetOne = false
            self.loadingCamera = true
            _ = self.startCameraFromViewController(self, withDelegate: self)
        }))
        alert.addAction(UIAlertAction(title: "打開相簿選擇影片", style: .default, handler: {
            (action) -> Void in
            if self.savedPhotosAvailable() {
                self.loadingAssetOne = false
                _ = self.startMediaBrowserFromViewController(self, usingDelegate: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "取消",style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        previewOne.isHidden = true
//        previewTwo.isHidden = true
        recAudio.isHidden = true
        recAudioTwo.isHidden = true
        delTwo.isHidden = true
        deletVideopath.isHidden = true
        load()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let coachMarksShown: Bool = UserDefaults.standard.bool(forKey: "MPCoachMarksShown_Storyboard")
        if coachMarksShown == false {
            UserDefaults.standard.set(true, forKey: "MPCoachMarksShown_Storyboard")
            UserDefaults.standard.synchronize()
            coachmarks()
        }
    }
    
    func coachmarks(){
        let coachmark1 = CGRect(x: 5, y: 150, width: 150, height: 150)//故事版圖案
        let coachmark2 = CGRect(x: 205 , y: 170, width: 465, height: 80)//引導文字
        let coachmark3 = CGRect(x: 140, y: 198, width: 50, height: 50)//小提示
        let coachmark4 = CGRect(x: 55, y: 280, width: 150, height: 150)//上傳影片
        let coachmark5 = CGRect(x: 10, y: 72, width: 768, height: 78)
        let coachmark6 = CGRect(x: 700, y: 5, width: 50, height: 50)
        
        let coachMarks = [
            ["rect": NSValue(cgRect: coachmark1), "caption": "影片專案中分為5個階段\n\n共有9個故事版\n\n\n\n\n\n\n\n\n", "position": 4,"shape":1],
            ["rect": NSValue(cgRect: coachmark2), "caption": "每個故事版會引導你進行探究\n\n請耐心閱讀並動動腦\n試著回答這些問題\n\n\n\n\n\n\n\n\n\n\n", "position": 0],
            ["rect": NSValue(cgRect: coachmark3), "caption": "看完引導卻仍然不知道該怎麼製作影片\n\n可以點這個【提示】按鈕！\n\n\n\n\n\n\n\n\n\n\n","position": 4,"shape":1],
            ["rect": NSValue(cgRect: coachmark4), "caption": "點這裡可以選擇拍攝影片\n\n或者在相簿中挑選影片\n\n\n\n\n*** 注意 ***\n\n播放影片頁面中\n上方的影片時間軸會有黑色框框\n\n按著右邊的箭頭\n框框會變成黃色\n就可以剪輯影片的長短了！！！\n\n\n\n\n","position": 4],
            ["rect": NSValue(cgRect: coachmark5), "caption": "你仍然可以在這裡回顧探究的步驟！","position": 0, "showArrow": true],
            ["rect": NSValue(cgRect: coachmark6), "caption": "或者這裡！","position": 5, "showArrow": true]
        ]
        coachMarksView = MPCoachMarks(frame: (tabBarController?.view.bounds)! , coachMarks: coachMarks)
        coachMarksView.enableContinueLabel = false
        coachMarksView.maxLblWidth = 400
        coachMarksView.enableSkipButton = false
        //        coachMarksView.skipButtonText = "跳過"
        tabBarController?.view.addSubview(coachMarksView)
        //        var coachMarksView = MPCoachMarks(frame: view.bounds, coachMarks: coachMarks)
        //        view.addSubview(coachMarksView)
        coachMarksView.start()
    }
    
    func load(){
        check()
    }
    
    func check(){
        
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
                        let existone = self.checkVideoExist(video!, "videoone_path", 1)
                        let existtwo = self.checkVideoExist(video!, "videotwo_path", 2)
                        switch (existone){
                        case 1:
                            self.showthumbnail(video!, "videoone_path", self.previewOne, self.recAudio, self.deletVideopath)
                            switch (existtwo){
                            case 1:
                                self.showthumbnail(video!, "videotwo_path", self.previewTwo, self.recAudioTwo, self.delTwo)
                            case 2:
                                self.startActivityIndicator()
                                let videourl = video?["videotwo_path"] as? String
                                let url = URL(string: videourl!)
                                self.donloadVideo(url: url!,self.stopActivityIndicator(_:),2)
                            case 3:
//                                self.showSBimage(self.previewTwo, #imageLiteral(resourceName: "sb2img.png"))
                                break
                            default: break
                            }
                        case 2:
                            self.startActivityIndicator()
                            let videourl = video?["videoone_path"] as? String
                            let url = URL(string: videourl!)
                            self.donloadVideo(url: url!,self.stopActivityIndicator(_:),1)
                        case 3:
//                            self.showSBimage(self.previewOne, #imageLiteral(resourceName: "sb1img.png"))
                            
                            switch (existtwo){
                            case 1:
                                self.showthumbnail(video!, "videotwo_path", self.previewTwo, self.recAudioTwo, self.delTwo)

                            case 2:
                                self.startActivityIndicator()
                                let videourl = video?["videotwo_path"] as? String
                                let url = URL(string: videourl!)
                                self.donloadVideo(url: url!,self.stopActivityIndicator(_:),2)
                            case 3:
//                                self.showSBimage(self.previewTwo, #imageLiteral(resourceName: "sb2img.png"))
                                break
                            default: break
                            }
                            
                        default: break
                        }
                    }
                }
        }
    }
    
//    func previewVideo(_ videoinfo: [String: Any],_ videopath: String,_ preview: UIView,_ recbtn: UIButton,_ delbtn: UIButton){
//        let videourl = videoinfo[videopath] as? String
//        let url = URL(string: videourl!)
//        self.player = AVPlayer(url: url!)
//        self.playerController = AVPlayerViewController()
//        self.playerController.player = self.player
//        self.playerController.view.frame = preview.frame
//        self.addChildViewController(self.playerController)
//        self.view.addSubview(self.playerController.view)
//        preview.isHidden = false
//        recbtn.isHidden = false
//        delbtn.isHidden = false
//    }
    
    func showthumbnail(_ videoinfo: [String: Any],_ videopath: String,_ check: VideoPreviewButton,_ recbtn: UIButton,_ delbtn: UIButton){
        let videourl = videoinfo[videopath] as? String
        let url = URL(string: videourl!)
        let asset = AVURLAsset(url: url!, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        
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
            self.load()
        })
        alertController.addAction(checkagainAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func checkVideoExist(_ videoinfo: [String: Any],_ videopath: String,_ clip: Int) -> Int{
        let video = videoinfo[videopath] as? String
        if !(video == nil) {
            let url = URL(string: video!)
            //print("videoone\(videoone)")
            if FileManager.default.fileExists(atPath: (url?.path)!) {
//                print("video \(clip) exist")
                return 1
            } else {
                return 2
            }
        }else{
            return 3
        }
    }

    func getclipname(_ clip: Int, completion: @escaping (NSDictionary?, Error?) -> ()){
        let parameters: Parameters=["videoid": Index,"clip": clip]
        
        Alamofire.request("http://140.122.76.201/CoInQ/v1/getvideoinfo.php", method: .post, parameters: parameters).responseJSON
            {
                response in
                switch response.result {
                case .success(let videoname):
                    completion(videoname as? NSDictionary, nil)
                case .failure(let error):
                    completion(nil,error)
                }
            }
    }
    
    func donloadVideo(url : URL,_ stopAI: @escaping (Int)->(),_ clip: Int){
        
        let requestUrl = "http://140.122.76.201/CoInQ/upload/"
        let videoid = "\(Index)"
        getclipname(clip){ responseObject, error in
            let video = responseObject?.value(forKey: "videoname") as? String

        let urls = requestUrl.appending(google_userid).appending("/").appending(videoid).appending("/").appending(video?.description ?? "none")
        let videourl = URL(string: urls)
        
        let downloadfilename = UUID().uuidString + ".mov"
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let file = directoryURL.appendingPathComponent(downloadfilename, isDirectory: false)
            return (file, [.createIntermediateDirectories, .removePreviousFile])
        }
        
        Alamofire.download(videourl!, to: destination).validate().responseData { response in
            let tmpurl = response.destinationURL
            stopAI(clip)
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tmpurl!)
            }) { saved, error in
                if saved {
                    let parameters: Parameters=[
                        "videoid":    Index,
                        "videopath":  tmpurl!.absoluteString,
                        "clip" : clip
                    ]
                    
                    //Sending http post request
                    Alamofire.request("http://140.122.76.201/CoInQ/v1/uploadvideo.php", method: .post, parameters: parameters).responseJSON
                        {
                            response in
//                            print(response)
                            
                    }
                    
//                                    let fetchOptions = PHFetchOptions()
//                                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
//                    
//                                    // After uploading we fetch the PHAsset for most recent video and then get its current location url
//                    
//                                    let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
//                                    PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
//                                        let newObj = avurlAsset as! AVURLAsset
//                                        self.deleteFile(newObj.url)
////                                        print("store path\(newObj.url)")
//                                    })
        
                }
            }
        }
            return
        }
    }

//
//        Alamofire.request( videourl!, method: .get)
//            .downloadProgress { progress in
//                print("Download Progress: \(progress.fractionCompleted)")
//            }
//            .responseData { response in
//                print(response.result.value)
//        }

//        let downloadfilename = UUID().uuidString + ".mov"
//        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        let savePath = (documentDirectory as NSString).appendingPathComponent(downloadfilename)
//        let urll = URL(fileURLWithPath: savePath)

        //        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        //            let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //            let file = directoryURL.appendingPathComponent(saveUrl, isDirectory: false)
        //            print(file)
        //            return (file, [.createIntermediateDirectories, .removePreviousFile])
        //        }
        

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //刪除故事版的videopath
    func deleteVideoPath(sb: Int,_ preview: UIView,_ recbtn:UIButton,_ delbtn: UIButton,_ vc: UIViewController){
        let parameters: Parameters=[
            "id":    Index,
            "clip" : sb
        ]
        Alamofire.request("http://140.122.76.201/CoInQ/v1/deletevideo.php", method: .post, parameters: parameters).responseJSON
            {
                response in
                if response.result.isSuccess{
                    for item in vc.view.subviews{
                        if item.frame == preview.frame {
                            item.removeFromSuperview()
                        }
                    }
                    recbtn.isHidden = true
                    delbtn.isHidden = true
                }
        }
    }
    func showSBimage(_ preview: UIView,_ image: UIImage){
        let imageview = UIImageView(frame: preview.frame)
        imageview.image = image
        imageview.contentMode = .scaleAspectFill
        self.view.addSubview(imageview)
    }
    
    //上传视频到服务器
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
                            self.load()

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
    
//    func deleteFile(_ filePath:URL) {
//        
//        guard FileManager.default.fileExists(atPath: filePath.path) else { return }
//        
//        do {
//            try    FileManager.default.removeItem(atPath: filePath.path)
//        } catch {
//            fatalError("Unable to delete file: \(error) : \(#function).")
//        }
//    }
    
}


// MARK: - UIImagePickerControllerDelegate
extension SelectVideoUpload_One_Two : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        if mediaType == kUTTypeMovie {
            let avAsset = info[UIImagePickerControllerMediaURL] as! URL
            var message = ""
            
//            guard let path = (info[UIImagePickerControllerMediaURL] as! NSURL).path else { return }
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(avAsset.path) &&  loadingCamera {
                UISaveVideoAtPathToSavedPhotosAlbum(avAsset.path, self, nil, nil)
                loadingCamera = false
            }
            
            if loadingAssetOne {
                message = "故事版1 影片已匯入成功！"
                self.startActivityIndicator()
                let videourl = avAsset
//                Asset = AVAsset(url: videourl)
//                let time = Asset?.duration.seconds as! Double
//                if time > 30.0{
//                    let alertController = UIAlertController(title: "影片需少於30秒，請重新上傳", message: nil, preferredStyle: .alert)
//                    let checkagainAction = UIAlertAction(title: "OK", style: .default, handler:nil)
//                    alertController.addAction(checkagainAction)
//                    self.present(alertController, animated: true, completion: nil)
//                }else{
                    self.uploadVideo(mp4Path: videourl,message: message,clip:1,self.previewOne,self.recAudio,self.deletVideopath)
//                    load()
//                }
            } else {
                message = "故事版2 影片已匯入成功！"
                self.startActivityIndicator()
                let videoURL = avAsset
                self.uploadVideo(mp4Path: videoURL,message: message,clip:2,self.previewTwo,self.recAudioTwo,self.delTwo)
//                load()
            }
            
            //let userdefault = UserDefaults.standard
            //userdefault.set(firstAsset, forKey: "VideoOne")
            //userdefault.set(secondAsset, forKey: "VideoTwo")
        }
    }
}

extension SelectVideoUpload_One_Two: AudioRecorderViewControllerDelegate {
    func audioRecorderViewControllerDismissed(withFileURL fileURL: URL?,clip: Int) {
        dismiss(animated: true, completion: nil)
        if clip == 1 {
            self.startActivityIndicator()
            let message = "故事版1 影片已匯入成功！"
            self.uploadVideo(mp4Path: fileURL!, message: message, clip: 1, self.previewOne, self.recAudio, self.deletVideopath)
        }else if clip == 2 {
            self.startActivityIndicator()
            let message = "故事版2 影片已匯入成功！"
            self.uploadVideo(mp4Path: fileURL!, message: message, clip: 2, self.previewTwo, self.recAudioTwo, self.delTwo)
        }

    }
}

// MARK: - UINavigationControllerDelegate
extension SelectVideoUpload_One_Two : UINavigationControllerDelegate {
}
