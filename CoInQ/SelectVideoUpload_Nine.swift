//
//  SelectVideoUpload_Nine.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import AVFoundation
import MobileCoreServices
import MediaPlayer
import CoreMedia
import Photos
import Alamofire
import SwiftyJSON

class SelectVideoUpload_Nine : UIViewController{
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var RecordButton: UIButton!
    
    var clips: [Any]?
    var array: [Any]?
    var isURLempty = true
    var buttonClicked = true
    var loadingAssetOne = false
    var nullstoryboard = [String]()
    var emptystoryboards = [String]()
    var collectClips = [String]()
    var mergeClips = [AVAsset]()

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
                                let videourl = video?["videonine_path"] as? String
                                let url = URL(string: videourl!)
                                let asset = AVURLAsset(url: url!, options: nil)
                                let imgGenerator = AVAssetImageGenerator(asset: asset)
                                imgGenerator.appliesPreferredTrackTransform = false
                                
                                do {
                                    let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                                    let thumbnail = UIImage(cgImage: cgImage)
                                    
                                    self.ninecomplete.image = thumbnail
                                    
                                } catch let error {
                                    print("*** Error generating thumbnail: \(error)")
                                }
                                self.ninecomplete.isHidden = false
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

        let parameter: Parameters=["google_userid": google_userid,"videoid":Index]
        Alamofire.request("http://140.122.76.201/CoInQ/v1/getCollectingclips.php", method: .post, parameters: parameter).responseJSON
            {
                response in
                print(response)
                guard response.result.isSuccess else {
                    let errorMessage = response.result.error?.localizedDescription
                    print("\(errorMessage!)")
                    return
                }
                guard let JSON = response.result.value as? [String: Any] else {
                    print("JSON formate error")
                    return
                }
                // 2.
                let error = JSON["error"] as! Bool
                if error {
                    self.clips = []
                } else if let Collecte = JSON["table"] as? [Any] {
                    self.clips = Collecte
                    for each in Collecte{
                        let arrays = each as? [String: Any]
                        let collectClips = arrays?["videopath"] as? String
                    }
                    
                }
        }
        
    }
    
    func check(_ videonum: String,_ storyboard: String){
        var video = videoArray?[0] as? [String: Any]
        let videopath = video?[videonum] as? String
        if videopath == nil {
            nullstoryboard.append(storyboard)
            emptystoryboards.append(storyboard)
            isURLempty = false
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
                let clipVideo = AVAsset(url: URL(string: videopath)!)
                mergeClips.append(clipVideo)
            }
        }else{
            check("videofour_path", "故事版 4")
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
        update()
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
        
        return isURLempty
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ExplainNine(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小提示",message:"試著將鏡頭轉換成自拍模式\n對著鏡頭說幾句話吧！",preferredStyle: .alert)
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
            //            print("export")
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
                    print("saved")
                    self.uploadFinalvideo(outputURL!, videolength)
                    
                }
            }
        }else if session.status == AVAssetExportSessionStatus.failed{
            let alertController = UIAlertController(title: "合併失敗，請重新操作一次", message: nil, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "確定", style: .default, handler: self.switchPage)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            self.StopActivityIndicator()
        }

        mergeClips = []
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
                }
        }
    }
    
    @IBAction func checkALLvideoLoaded(_ sender: AnyObject) {
        
        if isVideoLoaded() {
            
            mergeVideo(mergeClips)
            
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
            let alertController = UIAlertController(title: "請注意", message: "請選擇以下故事版進行上傳：\n\(printArray)", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            lognote("sbe", google_userid, "id\(Index)\(emptystoryboard)")
        }

        /*if isURLempty("RecordOne") || isURLempty("RecordTwo") {
            UserDefaults.standard.removeObject(forKey: "RecordOne")
            UserDefaults.standard.removeObject(forKey: "RecordTwo")
        }*/
        
    }
    
    func uploadVideo(mp4Path : URL , message : String, clip: Int,check: UIImageView){
        
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

    func mergeVideo(_ mAssetsList: [AVAsset]) {
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
            let currentAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
            do {
                try currentTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero,
                                                                 currentAsset.duration), of: currentAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: startDuration)
                try currentAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, currentAsset.duration), of: currentAsset.tracks(withMediaType: AVMediaTypeAudio)[0], at: startDuration)
                
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())
        let savePath = (documentDirectory as NSString).appendingPathComponent("mergeVideo-\(date).mov")
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
        lognote("mvt", google_userid, "videoid:\(Index)")
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
                        print("Upload Failed")
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
            if loadingAssetOne {
                message = "故事版9 影片已匯入成功！"
                self.startActivityIndicator()
                let videoURL = avAsset
                uploadVideo(mp4Path: videoURL,message: message,clip:9,check: self.ninecomplete)
                loadData()

            }
            
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
