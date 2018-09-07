//
//  SelectVideoUpload_Nine.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import AVFoundation
import AVKit
import MobileCoreServices
import MediaPlayer
import CoreMedia
import Photos
import Alamofire
import SwiftyJSON

class SelectVideoUpload_Nine : UIViewController{
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var videoPreview = UIView.init(frame: CGRect(x: 225,y: 264,width: 465,height: 257))
    @IBOutlet weak var RecordButton: UIButton!
//    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var recNine: UIButton!
    @IBOutlet weak var delNine: UIButton!
    
//    var clips: [Any]?
    var array: [Any]?
    var isURLempty = true
    var isClicked = true
    var loadingAssetOne = false
    var loadingCamera = false
    var nullstoryboard = [String]()
    var emptystoryboards = [String]()
    var collectClips = [String]()
    var mergeClips = [AVAsset]()
    
    var player: AVPlayer!
    var playerController = AVPlayerViewController()

    var printArray: String{
        var str = ""
        for element in nullstoryboard {
            str += "\n\(element)"
        }
        return str
    }
    
    var emptystoryboard: String{
        var str = ""
        for element in emptystoryboards {
            str += "\(element)"
        }
        return str
    }
    
    
//    @IBOutlet weak var ninecomplete: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RecordButton.layer.cornerRadius = 8
        videoPreview.isHidden = true
        recNine.isHidden = true
        delNine.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(loadCollectionVideo), name: NSNotification.Name("CoClipDownload"), object: nil)

        checknine()
    }
    
    @IBAction func StageTitleFive(_ sender: UIButton) {
        lognote("h5d", google_userid, "\(Index)")
        if isClicked {
            isClicked = false
            sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
            sender.setTitle("與他人分享我的解釋會激發更多新想法與新問題", for: UIControlState())
        }else{
            isClicked = true
            sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32)
            sender.setTitle("分享與回饋", for: UIControlState())
        }
    }
    
    @IBAction func recNine(_ sender: AnyObject) {
        
        let controller = AudioRecorderViewController()
        controller.audioRecorderDelegate = self
        lognote("g9r", google_userid, "\(Index)")

        let video = videoArray?[0] as? [String: Any]
        let videourl = video?["videonine_path"] as? String
        let url = URL(string: videourl!)
        controller.childViewController.videourl = url
        controller.childViewController.clip = 9
        controller.childViewController.note = "說說看，當他人對於我的解釋有所懷疑時，我是如何回應的。"
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func delNine(_ sender: Any) {
        let deleteAlert = UIAlertController(title:"確定要清空故事版9的影片嗎？",message: "刪除影片後無法復原！", preferredStyle: .alert)
        deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:{ (action) -> Void in
            SelectVideoUpload_One_Two().deleteVideoPath(sb: 9, self.videoPreview, self.recNine, self.delNine,self)
        }))
        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    func checknine(){
        loadData()
        loadCollectionVideo()
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
                if let videoinfo = JSON["videoURLtable"] as? [Any] {
                    self.array = videoinfo
                    var video = self.array?[0] as? [String: Any]
                    if !(video?.isEmpty)! {
                        let existone = SelectVideoUpload_One_Two().checkVideoExist(video!, "videonine_path", 9)
                            switch (existone){
                            case 1:
                                self.previewVideo(video!, "videonine_path", self.videoPreview,self.recNine, self.delNine)
                                break
                            case 2:
                                self.startActivityIndicator()
                                let videourl = video?["videonine_path"] as? String
                                let url = URL(string: videourl!)
                                SelectVideoUpload_One_Two().donloadVideo(url: url!,self.stopActivityIndicator(_:),9)
                            case 3:
                                break
                            default: break
                            }
                    }
                }
        }
    }

    func loadCollectionVideo(){
        let parameter: Parameters=["google_userid": google_userid,"videoid":Index]
        Alamofire.request("http://140.122.76.201/CoInQ/v1/getCollectingclips.php", method: .post, parameters: parameter).responseJSON
            {
                response in
//                print(response)
                guard response.result.isSuccess else {
                    let errorMessage = response.result.error?.localizedDescription
                    print("\(errorMessage!)")
                    return
                }
                guard let JSON = response.result.value as? [String: Any] else {
                    print("JSON formate error")
                    return
                }
                let error = JSON["error"] as! Bool
                if error {
                    self.collectClips = []
//                    self.clips = []
                } else if let Collecte = JSON["table"] as? [Any] {
//                    self.clips = Collecte
                    self.collectClips = []
                    for each in Collecte{
                        let arrays = each as? [String: Any]
                        let collectClips = arrays?["videopath"] as? String
                        self.collectClips.append(collectClips!)
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
    
    func check(_ videonum: String,_ storyboard: String){
        var video = videoArray?[0] as? [String: Any]
        let videopath = video?[videonum] as? String
        if videopath == nil {
//            故事版是空的
            nullstoryboard.append(storyboard)
            emptystoryboards.append(storyboard)
        }else{
            let clipVideo = AVAsset(url: URL(string: videopath!)!)
            mergeClips.append(clipVideo)
        }
    }
    
    func checkCollectStageClips(){
        //判斷有無搜集資料 沒有就記錄log 有就將videopath加入array 裡面
//        let clips = self.clips?[0] as? [String: Any]
        if collectClips.count != 0 {
            for each in collectClips{
                let videopath = each
                let url = URL(string: videopath)
                if FileManager.default.fileExists(atPath: (url?.path)!){
                    let clipVideo = AVAsset(url: URL(string: videopath)!)
                    mergeClips.append(clipVideo)
                }else{
                    isURLempty = false
                    let alert = UIAlertController(title: "已有人傳回共創影片資料\n請前往故事版4進行確認", message: nil, preferredStyle: .alert)
                    let checkagainAction = UIAlertAction(title: "OK", style: .default, handler:nil)
                    alert.addAction(checkagainAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
//            故事版4是空的
//            check("videofour_path", "故事版 4")
            nullstoryboard.append("故事版 4")
            emptystoryboards.append("故事版 4")
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
            self.checknine()
        })
        alertController.addAction(checkagainAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func StopActivityIndicator() {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func isVideoLoaded() -> Bool {
        isURLempty = true
        nullstoryboard = [String]()
        emptystoryboards = [String]()
        check("videoone_path", "故事版 1")
        check("videotwo_path", "故事版 2")
        check("videothree_path", "故事版 3")
        checkCollectStageClips()
        check("videofive_path", "故事版 5")
        check("videosix_path", "故事版 6")
        check("videoseven_path", "故事版 7")
        check("videoeight_path", "故事版 8")
        check("videonine_path", "故事版 9")
        
        return (mergeClips.count > 1)&&isURLempty
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ExplainNine(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小提示",message:"試著將鏡頭轉換成自拍模式\n對著鏡頭回答頁面上的問題吧！",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        lognote("ve9",google_userid,"\(Index)")
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
    
    func exportDidFinish(_ session: AVAssetExportSession) {
        if session.status == AVAssetExportSessionStatus.completed {
            let outputURL = session.outputURL
                        print("completed")
            PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)}) { saved, error in
                if saved {
                    let outputVideo = AVAsset(url: outputURL!)
                    let duration = outputVideo.duration
                    let videoseconds = CMTimeGetSeconds(duration)
                    let vmilliseconds = Int(videoseconds) * 60
                    let vmilli = (vmilliseconds % 60) + 39
                    let vsec = (vmilliseconds / 60) % 60
                    let vmin = vmilliseconds / 3600
                    let videolength = NSString(format: "%02d:%02d.%02d", vmin, vsec, vmilli) as String
                    self.uploadFinalvideo(outputURL!, videolength)
                    
                }
            }
        }else if session.status == AVAssetExportSessionStatus.failed{
            print(session.error)
            lognote("mvf", google_userid, "\(Index)")
            let alertController = UIAlertController(title: "影片輸出失敗，請重新操作一次", message: nil, preferredStyle: .alert)
//            let defaultAction = UIAlertAction(title: "確定", style: .default, handler: self.switchPage)
            let defaultAction = UIAlertAction(title: "再合併一次", style: .default, handler:{
                (action) -> Void in
//                self.mergeVideo(self.mergeClips)
            })
            alertController.addAction(defaultAction)
            alertController.addAction(UIAlertAction(title:"取消", style: .cancel, handler: self.switchPage))
            self.present(alertController, animated: true, completion: nil)
            self.StopActivityIndicator()
        }else{print(session.status)}

        mergeClips = []
    }
    
    @IBAction func loadAssetNine(_ sender: AnyObject) {
        let alert = UIAlertController(title: "請選擇影片途徑", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "開啟相機進行錄影", style: .default, handler: {
            (action) -> Void in
            self.loadingAssetOne = true
            self.loadingCamera = true
            lognote("v9s", google_userid, "\(Index)")
            _ = self.startCameraFromViewController(self, withDelegate: self)
        }))
        alert.addAction(UIAlertAction(title: "打開相簿選擇影片", style: .default, handler: {
            (action) -> Void in
            if self.savedPhotosAvailable() {
                self.loadingAssetOne = true
                lognote("a9s", google_userid, "\(Index)")
                _ = self.startMediaBrowserFromViewController(self, usingDelegate: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "取消",style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
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
                }
        }
    }
    
    @IBAction func checkALLvideoLoaded(_ sender: AnyObject) {
        mergeClips = []
        update()
        loadCollectionVideo()
        if isVideoLoaded() {
            let     uniqueID = NSUUID().uuidString
            mergeVideo(mergeClips,uniqueID)
            lognote("mvt", google_userid, "\(Index)")

            //新增VC
//            let recordNavigationController = storyboard?.instantiateViewController(withIdentifier: "RecordNavigationController") as! RecordNavigationController
//            present(recordNavigationController, animated: true, completion: nil)
            //在 navigationVC 中再新增
//            let recordNavigationController = storyboard?.instantiateViewController(withIdentifier: "RecordAudio_One") as! RecordAudio_One
//            self.navigationController?.pushViewController(recordNavigationController, animated: true)
            
//            lognote("sra", google_userid, "\(Index)")
            // 沒再用
//            self.performSegue(withIdentifier: "StartRecord", sender: self)
        }else{
            
            //  警告視窗 提醒未上傳的故事版
            let alertController = UIAlertController(title: "請注意", message: "請選擇以下故事版進行上傳：\(printArray)", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            lognote("sbe", google_userid, "\(Index)+\(emptystoryboard)")
        }
        /*if isURLempty("RecordOne") || isURLempty("RecordTwo") {
            UserDefaults.standard.removeObject(forKey: "RecordOne")
            UserDefaults.standard.removeObject(forKey: "RecordTwo")
        }*/
    }
    
    func uploadVideo(mp4Path : URL , message : String, clip: Int,check: UIView,_ recbtn: UIButton){
        
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
//                        print("Upload Succes")
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
                            recbtn.isHidden = false
                            self.delNine.isHidden = false
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

    func mergeVideo(_ mAssetsList: [AVAsset],_ MergedVideoID: String) {
        startActivityIndicator()
        let mainComposition = AVMutableVideoComposition()
        var startDuration:CMTime = kCMTimeZero
        var endDuration:CMTime = kCMTimeZero
        let mainInstruction = AVMutableVideoCompositionInstruction()
        let mixComposition = AVMutableComposition()
        var allVideoInstruction = [AVMutableVideoCompositionLayerInstruction]()
        
        var assets = mAssetsList
        for i in 0 ..< assets.count {
            let currentAsset:AVAsset = assets[i] //Current Asset.
            endDuration = CMTimeAdd(startDuration,currentAsset.duration)

            let currentTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
//            let currentAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
            do {
                try currentTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero,
                                                                 currentAsset.duration), of: currentAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: startDuration)
//                try currentAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, currentAsset.duration), of: currentAsset.tracks(withMediaType: AVMediaTypeAudio)[0], at: startDuration)
                
                //Creates Instruction for current video asset.
                let currentInstruction:AVMutableVideoCompositionLayerInstruction = videoCompositionInstructionForTrack(currentTrack, asset: currentAsset)
                currentInstruction.setOpacity(0.0, at: endDuration)
//                currentInstruction.setOpacityRamp(fromStartOpacity: 0.0,
//                                                  toEndOpacity: 1.0,
//                                                  timeRange:CMTimeRangeMake(
//                                                    startDuration,
//                                                    CMTimeMake(1, 1)))
//                if i != assets.count - 1 {
//                    //Sets Fade out effect at the end of the video.
//                    currentInstruction.setOpacityRamp(fromStartOpacity: 1.0,
//                                                      toEndOpacity: 0.0,
//                                                      timeRange:CMTimeRangeMake(
//                                                        CMTimeSubtract(
//                                                            CMTimeAdd(currentAsset.duration, startDuration),
//                                                            CMTimeMake(1, 1)),
//                                                        CMTimeMake(2, 1)))
//                }
                
                allVideoInstruction.append(currentInstruction) //Add video instruction in Instructions Array.
                
                startDuration = CMTimeAdd(startDuration, currentAsset.duration)
            } catch _ {
                print("ERROR_LOADING_VIDEO")
            }
        }
        
        
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, startDuration)
        mainInstruction.layerInstructions = allVideoInstruction
        
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 30)
        mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)//width: 640, height: 480)
        
        // 4 - Get path
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        dateFormatter.timeStyle = .short
//        let date = dateFormatter.string(from: Date())
        let savePath = (documentDirectory as NSString).appendingPathComponent("\(MergedVideoID).mov")
        let url = URL(fileURLWithPath: savePath)
        
        // 5 - Create Exporter
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        exporter.outputURL = url
        exporter.outputFileType = AVFileTypeQuickTimeMovie
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = mainComposition
        // Perform the Export
        exporter.exportAsynchronously() {
            DispatchQueue.main.async { _ in
                self.exportDidFinish(exporter)
            }
        }
    }

    func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
    func videoCompositionInstructionForTrack(_ track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        
        var scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
        if assetInfo.isPortrait {
            scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor),
                                     at: kCMTimeZero)
        } else {
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: (UIScreen.main.bounds.width/2) - 75))
            if (assetTrack.naturalSize.width > assetTrack.naturalSize.height){
                concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: (UIScreen.main.bounds.width/2) - 75))
            }else{
                concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: 0))
            }
            if assetInfo.orientation == .down {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                let windowBounds = UIScreen.main.bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height/2
                let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
                concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
            }
            instruction.setTransform(concat, at: kCMTimeZero)
        }
        
        return instruction
    }
    
    func uploadFinalvideo(_ mp4Path: URL,_ videolength: String){
        Alamofire.upload(
            //同样采用post表单上传
            multipartFormData: { multipartFormData in
                
                multipartFormData.append(mp4Path, withName: "file")//, fileName: "123456.mp4", mimeType: "video/mp4")
                multipartFormData.append("\(Index)".data(using: String.Encoding.utf8, allowLossyConversion: false)!,withName: "videoid")
                multipartFormData.append(google_userid.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "google_userid")
                multipartFormData.append((mp4Path.absoluteString.data(using: String.Encoding.utf8, allowLossyConversion: false)!),withName: "videopath")
                multipartFormData.append(videolength.data(using: String.Encoding.utf8, allowLossyConversion: false)!,withName: "videolength")
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
                    //须导入 swiftyJSON 第三方框架，否则报错
                    let success = JSON(result)["success"].int ?? -1
                    if success == 1 {
                        let alertController = UIAlertController(title: "恭喜你順利完成一支精彩的\n科學探究影片！\n你可以在「已完成」中\n找到你的傑作。", message: nil, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "確定", style: .default, handler: self.switchPage)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                        self.StopActivityIndicator()
                        lognote("ufs", google_userid, "\(Index)")
                    }else{
                        lognote("uff", google_userid, "\(Index)")
                        let alert = UIAlertController(title:"提示",message:"上傳失敗，請檢察網路是否已連線並重新上傳", preferredStyle: .alert)
                        let action2 = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action2)
                        self.present(alert , animated: true , completion: nil)
                    }
                }
                //上传进度
                upload.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                    print("Upload Progress: \(progress.fractionCompleted)")
                }
            case .failure(let encodingError):
                print(encodingError)
                let alert = UIAlertController(title:"提示",message:"上傳失敗，請檢察網路是否已連線並重新上傳", preferredStyle: .alert)
                let action2 = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action2)
                self.present(alert , animated: true , completion: nil)
            }
        })
    }
    
    func switchPage(action: UIAlertAction){
        //7 - Page switch to CompleteVC
        //        dismiss(animated: true, completion: nil)
        for vc in (self.navigationController?.viewControllers ?? []) {
            //            print(vc)
            if vc is CSCL {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                NotificationCenter.default.post(name: NSNotification.Name("CSCL"), object: nil)
                break
            }
        }
        //self.tabBarController?.selectedIndex = 3
        //        self.performSegue(withIdentifier: "completevideotask", sender: self)
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
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(avAsset.path) && loadingCamera {
                UISaveVideoAtPathToSavedPhotosAlbum(avAsset.path, self, nil, nil)
                loadingCamera = false
            }
            if loadingAssetOne {
                message = "故事版9 影片已匯入成功！"
                self.startActivityIndicator()
                let videoURL = avAsset
                uploadVideo(mp4Path: videoURL,message: message,clip:9,check: self.videoPreview,self.recNine)
            }
            
        }
    }
}

extension SelectVideoUpload_Nine: AudioRecorderViewControllerDelegate {
    func audioRecorderViewControllerDismissed(withFileURL fileURL: URL?,clip: Int) {
        dismiss(animated: true, completion: nil)
        if clip == 9 {
            self.startActivityIndicator()
            let message = "故事版9 影片已匯入成功！"
            uploadVideo(mp4Path: fileURL!, message: message, clip: 9, check: self.videoPreview,self.recNine)
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension SelectVideoUpload_Nine : UINavigationControllerDelegate {
}


extension AVAsset {
    var g_size: CGSize {
        return tracks(withMediaType: AVMediaTypeVideo).first?.naturalSize ?? .zero
    }
    var g_orientation: UIInterfaceOrientation {
        guard let transform = tracks(withMediaType: AVMediaTypeVideo).first?.preferredTransform else {
            return .portrait
        }
        switch (transform.tx, transform.ty) {
        case (0, 0):
            return .landscapeRight
        case (g_size.width, g_size.height):
            return .landscapeLeft
        case (0, g_size.width):
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
}
