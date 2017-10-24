//
//  RecordNine_Merge.swift
//  CoInQ
//
//  Created by hui on 2017/5/16.
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

class RecordNine_Merge: UIViewController , AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet weak var videoPreviewLayer: UIImageView!
    @IBOutlet weak var ButttonRecord: UIButton!
    @IBOutlet weak var ButtonPlay: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var switchOutput: UILabel!
    @IBOutlet weak var UseRecordSwitch: UISwitch!
    
    var soundRecorder : AVAudioRecorder!
    var SoundPlayer : AVAudioPlayer!
    var audiourl: String?
    var useaudio = false

    var timeTimer: Timer?
    var progressCounter: Float = 0.00
    var videolength: Double = 0
    var progressViewTimer: Timer?
    var milliseconds: Int = 0
    var videoseconds: Double?
    
    var AudioFileName = UUID().uuidString + ".m4a"
    var AudioURL: URL?
    var videourl : URL?

    var Asset: AVAsset? //= AVAsset(url: UserDefaults.standard.url(forKey: "VideoTwo")!)
    var Player: AVPlayer?
    
    let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0) as Float),
                          AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC) as Int32),
                          AVNumberOfChannelsKey : NSNumber(value: 1 as Int32),
                          AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue) as Int32)]
    
    var audioAssetOne: AVAsset?
    var firstAsset: AVAsset?
    var secondAsset: AVAsset?
    var thirdAsset: AVAsset?
    var fourthAsset: AVAsset?
    var fifthAsset: AVAsset?
    var sixthAsset: AVAsset?
    var seventhAsset: AVAsset?
    var eighthAsset: AVAsset?
    var ninethAsset: AVAsset?
    
    var useRecordone :   Bool?
    var useRecordtwo :   Bool?
    var useRecordthree : Bool?
    var useRecordfour :  Bool?
    var useRecordfive :  Bool?
    var useRecordsix :   Bool?
    var useRecordseven : Bool?
    var useRecordeight : Bool?
    var userecordnine :  Bool?

    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getvideo()
        getaudio()
        getuserecordornot()
        videourl = RecordAudio_One().getvideo("videonine_path")
            Asset = AVAsset(url:videourl!)
            //影片縮圖
            let asset = AVURLAsset(url: videourl!, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = false
            
            do {
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                
                videoPreviewLayer.image = thumbnail
                
            } catch let error {
                print("*** Error generating thumbnail: \(error)")
            }
            
            showTimeLabel()
            progressView.progress = progressCounter

            ButtonPlay.isHidden = true
            switchOutput.isHidden = true
            UseRecordSwitch.isHidden = true
            userecordnine = false

    }

func getaudio(){
    let parameters: Parameters=["videoid": Index,"num": 9]
    
    Alamofire.request("http://140.122.76.201/CoInQ/v1/getAudioInfo.php", method: .post, parameters: parameters).responseJSON
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
            if let audioinfo = JSON["audiopath"] as? String {
                let audiopath = audioinfo
                
                if !(audiopath.isEmpty) {
                    let url = URL(string: audiopath)
                    if FileManager.default.fileExists(atPath: (url?.path)!) {
                        print("FILE 9 FOUND")
                        self.ButtonPlay.isHidden = false
                        self.switchOutput.isHidden = false
                        self.UseRecordSwitch.isHidden = false
                        self.AudioURL = URL(string: audiopath)
                        self.userecordnine = true
                        self.UseRecordSwitch.isOn = false
                        
                    } else {
                        //self.donloadVideo(url: url!)
                        print("FILE 9 NOT FOUND")
                    }
                }
            }
    }
    
}
    
    func getuserecordornot(){
        useRecordone    = UserDefaults.standard.bool(forKey: "userecordone")
        useRecordtwo    = UserDefaults.standard.bool(forKey: "userecordtwo")
        useRecordthree  = UserDefaults.standard.bool(forKey: "userecordthree")
        useRecordfour   = UserDefaults.standard.bool(forKey: "userecordfour")
        useRecordfive   = UserDefaults.standard.bool(forKey: "userecordfive")
        useRecordsix    = UserDefaults.standard.bool(forKey: "userecordsix")
        useRecordseven  = UserDefaults.standard.bool(forKey: "userecordseven")
        useRecordeight  = UserDefaults.standard.bool(forKey: "userecordeight")
        print(useRecordone,useRecordtwo,useRecordthree)

    }

    func getvideo(){
        var video = videoArray?[0] as? [String: Any]
        let videoone = video?["videoone_path"] as? String
        firstAsset   = AVAsset(url: URL(string: videoone!)!)
        let videotwo = video?["videotwo_path"] as? String
        secondAsset   = AVAsset(url: URL(string: videotwo!)!)
        let videothree = video?["videothree_path"] as? String
        thirdAsset   = AVAsset(url: URL(string: videothree!)!)
        let videofour = video?["videofour_path"] as? String
        fourthAsset   = AVAsset(url: URL(string: videofour!)!)
        let videofive = video?["videofive_path"] as? String
        fifthAsset   = AVAsset(url: URL(string: videofive!)!)
        let videosix = video?["videosix_path"] as? String
        sixthAsset   = AVAsset(url: URL(string: videosix!)!)
        let videoseven = video?["videoseven_path"] as? String
        seventhAsset   = AVAsset(url: URL(string: videoseven!)!)
        let videoeight = video?["videoeight_path"] as? String
        eighthAsset   = AVAsset(url: URL(string: videoeight!)!)
        let videonine = video?["videonine_path"] as? String
        ninethAsset   = AVAsset(url: URL(string: videonine!)!)
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
    }

    //匯出並儲存影片至相簿
    func exportDidFinish(_ session: AVAssetExportSession) {
        if session.status == AVAssetExportSessionStatus.completed {
            let outputURL = session.outputURL
            PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)}) { saved, error in
                if saved {
                    let vmilliseconds = Int(self.videoseconds!) * 60
                    let vmilli = (vmilliseconds % 60) + 39
                    let vsec = (vmilliseconds / 60) % 60
                    let vmin = vmilliseconds / 3600
                    let videolength = NSString(format: "%02d:%02d.%02d", vmin, vsec, vmilli) as String
                    
                    self.uploadFinalvideo(outputURL!, videolength)
                    
                    let alertController = UIAlertController(title: "恭喜你順利完成一支精彩的\n科學探究影片！\n你可以在「已完成」中\n找到你的傑作。", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "確定", style: .default, handler: self.switchPage)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)

                }
            }
        }
        
        stopActivityIndicator()
        firstAsset = nil
        secondAsset = nil
        thirdAsset = nil
        fourthAsset = nil
        fifthAsset = nil
        sixthAsset = nil
        seventhAsset = nil
        eighthAsset = nil
        ninethAsset = nil
        audioAssetOne = nil
    }
    
    func switchPage(action: UIAlertAction){
        //7 - Page switch to CompleteVC
//        dismiss(animated: true, completion: nil)
        for vc in (self.navigationController?.viewControllers ?? []) {
            print(vc)
            if vc is CSCL {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                NotificationCenter.default.post(name: NSNotification.Name("CSCL"), object: nil)
                break
            }
        }
        //self.tabBarController?.selectedIndex = 3
//        self.performSegue(withIdentifier: "completevideotask", sender: self)
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
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.width / 2))
            if assetInfo.orientation == .down {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                let windowBounds = UIScreen.main.bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
                concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
            }
            instruction.setTransform(concat, at: kCMTimeZero)
        }
        
        return instruction
    }
    
    
    @IBAction func merge(_ sender: AnyObject) {
        
        if let firstAsset = firstAsset, let secondAsset = secondAsset ,let thirdAsset = thirdAsset ,let fourthAsset = fourthAsset ,let fifthAsset = fifthAsset ,let sixthAsset = sixthAsset ,let seventhAsset = seventhAsset ,let eighthAsset = eighthAsset ,let ninethAsset = ninethAsset{
            startActivityIndicator()
            
            let totalTIME = firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration + seventhAsset.duration + eighthAsset.duration + ninethAsset.duration
            videoseconds = totalTIME.seconds

            // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
            let mixComposition = AVMutableComposition()
            
            // 2 - Create video tracks
            // Video One
            let firstTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            do {
                try firstTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstAsset.duration), of: firstAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: kCMTimeZero)
            } catch _ {
                print("Failed to load first track")
            }
            // Video Two
            let secondTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            do {
                try secondTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration), of: secondAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: firstAsset.duration)
            } catch _ {
                print("Failed to load second track")
            }
            // Video Three
            let thirdTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            do {
                try thirdTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, thirdAsset.duration), of: thirdAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: firstAsset.duration + secondAsset.duration)
            } catch _ {
                print("Failed to load third track")
            }
            // Video Four
            let fourthTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            do {
                try fourthTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, fourthAsset.duration), of: fourthAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: firstAsset.duration + secondAsset.duration + thirdAsset.duration)
            } catch _ {
                print("Failed to load fourth track")
            }
            // Video Five
            let fifthTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            do {
                try fifthTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, fifthAsset.duration), of: fifthAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration)
            } catch _ {
                print("Failed to load fifth track")
            }
            // Video Six
            let sixthTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            do {
                try sixthTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, sixthAsset.duration), of: sixthAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration)
            } catch _ {
                print("Failed to load sixth track")
            }
            // Video Seven
            let seventhTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            do {
                try seventhTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, seventhAsset.duration), of: seventhAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration)
            } catch _ {
                print("Failed to load seventh track")
            }
            // Video Eight
            let eighthTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            do {
                try eighthTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, eighthAsset.duration), of: eighthAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration + seventhAsset.duration)
            } catch _ {
                print("Failed to load eighth track")
            }
            // Video Nine
            let ninethTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            do {
                try ninethTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, ninethAsset.duration), of: ninethAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration + seventhAsset.duration + eighthAsset.duration)
            } catch _ {
                print("Failed to load nineth track")
            }
            
            
            // 2.1
            let mainInstruction = AVMutableVideoCompositionInstruction()
            mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, totalTIME)
            //(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration,thirdAsset.duration))
            
            // 2.2
            let firstInstruction = videoCompositionInstructionForTrack(firstTrack, asset: firstAsset)
            firstInstruction.setOpacity(0.0, at: firstAsset.duration)
            
            let secondInstruction = videoCompositionInstructionForTrack(secondTrack, asset: secondAsset)
            secondInstruction.setOpacity(0.0, at: firstAsset.duration + secondAsset.duration)
            
            let thirdInstruction = videoCompositionInstructionForTrack(thirdTrack, asset: thirdAsset)
            thirdInstruction.setOpacity(0.0, at: firstAsset.duration + secondAsset.duration + thirdAsset.duration)
            
            let fourthInstruction = videoCompositionInstructionForTrack(fourthTrack, asset: fourthAsset)
            fourthInstruction.setOpacity(0.0, at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration)
            
            let fifthInstruction = videoCompositionInstructionForTrack(fifthTrack, asset: fifthAsset)
            fifthInstruction.setOpacity(0.0, at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration)
            
            let sixthInstruction = videoCompositionInstructionForTrack(sixthTrack, asset: sixthAsset)
            sixthInstruction.setOpacity(0.0, at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration)
            
            let seventhInstruction = videoCompositionInstructionForTrack(seventhTrack, asset: seventhAsset)
            seventhInstruction.setOpacity(0.0, at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration + seventhAsset.duration)
            
            let eighthInstruction = videoCompositionInstructionForTrack(eighthTrack, asset: eighthAsset)
            eighthInstruction.setOpacity(0.0, at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration + seventhAsset.duration + eighthAsset.duration)
            
            let ninethInstruction = videoCompositionInstructionForTrack(ninethTrack, asset:ninethAsset)
            
            // 2.3
            mainInstruction.layerInstructions = [firstInstruction, secondInstruction, thirdInstruction ,fourthInstruction ,fifthInstruction , sixthInstruction , seventhInstruction , eighthInstruction , ninethInstruction]
            let mainComposition = AVMutableVideoComposition()
            mainComposition.instructions = [mainInstruction]
            mainComposition.frameDuration = CMTimeMake(1, 30)
            mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            // 3 - Audio track
          if useRecordone! {
            
            getaudiourl(1){ (success,audiourl) in
                print(audiourl)
            self.audioAssetOne = AVAsset(url:audiourl!)
            
                let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration)),
                                                   of: (self.audioAssetOne?.tracks(withMediaType: AVMediaTypeAudio)[0])! ,
                                                   at: kCMTimeZero)
                } catch _ {
                    print("Failed to load Audio track")
                }
            }
            
            }else{
             
                let v1audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try v1audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstAsset.duration),
                                               of: firstAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                               at: kCMTimeZero)
                } catch _ {
                    print("Failed to load 故事版 1 Audio track")
                }
             
            }
            
            // Record Auido Two
            if useRecordtwo! {
                
                getaudiourl(2){ (success,audiourl) in
                    //audioAssetOne = AVAsset(url:UserDefaults.standard.url(forKey: "RecordTwo")!)
                    self.audioAssetOne = AVAsset(url:audiourl!)
                    let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                    do {
                        try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration),
                                                       of: (self.audioAssetOne?.tracks(withMediaType: AVMediaTypeAudio)[0])! ,
                                                       at: firstAsset.duration)
                    } catch _ {
                        print("Failed to load Audio track")
                    }
                }
                
            }else{
                print("false2")
                
                let v2audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try v2audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration),
                                                     of: secondAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                     at: firstAsset.duration)
                } catch _ {
                    print("Failed to load 故事版 2 Audio track")
                }
                
            }
            
            // Record Auido Three
            if useRecordthree!  {
                getaudiourl(3){ (success,audiourl) in
                    self.audioAssetOne = AVAsset(url:audiourl!)
                    let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                    do {
                        try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, thirdAsset.duration),
                                                       of: (self.audioAssetOne?.tracks(withMediaType: AVMediaTypeAudio)[0])! ,
                                                       at: firstAsset.duration + secondAsset.duration)
                    } catch _ {
                        print("Failed to load Audio track")
                    }
                }
                
            }else{
                print("false3")
                
                let v3audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try v3audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, thirdAsset.duration),
                                                     of: thirdAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                     at: firstAsset.duration + secondAsset.duration)
                } catch _ {
                    print("Failed to load 故事版 3 Audio track")
                }
                
            }
 /*           // Record Auido Four
            if useRecordfour  {
                
                let audioURL = URL(string: VideoNameArray[Index].audiofour!)
                audioAssetOne = AVAsset(url:audioURL!)
                
                let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, fourthAsset.duration),
                                                   of: (audioAssetOne?.tracks(withMediaType: AVMediaTypeAudio)[0])! ,
                                                   at: firstAsset.duration + secondAsset.duration + thirdAsset.duration)
                } catch _ {
                    print("Failed to load Audio track")
                }
                
            }else{
                print("false")
                
                let v4audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try v4audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, fourthAsset.duration),
                                                     of: fourthAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                     at: firstAsset.duration + secondAsset.duration + thirdAsset.duration)
                } catch _ {
                    print("Failed to load 故事版 4 Audio track")
                }
                
            }
            
            // Record Auido Five
            if useRecordfive  {
                
                let audioURL = URL(string: VideoNameArray[Index].audiofive!)
                audioAssetOne = AVAsset(url:audioURL!)
                
                let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, fifthAsset.duration),
                                                   of: (audioAssetOne?.tracks(withMediaType: AVMediaTypeAudio)[0])! ,
                                                   at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration)
                } catch _ {
                    print("Failed to load Audio track")
                }
                
            }else{
                print("false")
                
                let v5audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try v5audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, fifthAsset.duration),
                                                     of: fifthAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                     at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration)
                } catch _ {
                    print("Failed to load 故事版 5 Audio track")
                }
                
            }
            // Record Auido Six
            if useRecordsix  {
                
                let audioURL = URL(string: VideoNameArray[Index].audiosix!)
                audioAssetOne = AVAsset(url:audioURL!)
                
                let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, sixthAsset.duration),
                                                   of: (audioAssetOne?.tracks(withMediaType: AVMediaTypeAudio)[0])! ,
                                                   at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration)
                } catch _ {
                    print("Failed to load Audio track")
                }
                
            }else{
                print("false")
                
                let v6audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try v6audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, sixthAsset.duration),
                                                     of: sixthAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                     at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration)
                } catch _ {
                    print("Failed to load 故事版 6 Audio track")
                }
                
            }
            // Record Auido Seven
            if useRecordseven  {
                
                let audioURL = URL(string: VideoNameArray[Index].audioseven!)
                audioAssetOne = AVAsset(url:audioURL!)
                
                let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, seventhAsset.duration),
                                                   of: (audioAssetOne?.tracks(withMediaType: AVMediaTypeAudio)[0])! ,
                                                   at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration)
                } catch _ {
                    print("Failed to load Audio track")
                }
                
            }else{
                print("false")
                
                let v7audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try v7audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, seventhAsset.duration),
                                                     of: seventhAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                     at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration)
                } catch _ {
                    print("Failed to load 故事版 7 Audio track")
                }
                
            }
            // Record Auido Eight
            if useRecordeight  {
                
                let audioURL = URL(string: VideoNameArray[Index].audioeight!)
                audioAssetOne = AVAsset(url:audioURL!)
                
                let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, eighthAsset.duration),
                                                   of: (audioAssetOne?.tracks(withMediaType: AVMediaTypeAudio)[0])! ,
                                                   at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration + seventhAsset.duration)
                } catch _ {
                    print("Failed to load Audio track")
                }
                
            }else{
                print("false")
                
                let v8audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try v8audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, eighthAsset.duration),
                                                     of: eighthAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                     at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration + seventhAsset.duration)
                } catch _ {
                    print("Failed to load 故事版 8 Audio track")
                }
                
            }

            // Record Auido Nine
            if useRecordnine  {
                
                let audioURL = URL(string: VideoNameArray[Index].audionine!)
                audioAssetOne = AVAsset(url:audioURL!)
                
                let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, ninethAsset.duration),
                                                   of: (audioAssetOne?.tracks(withMediaType: AVMediaTypeAudio)[0])! ,
                                                   at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration + seventhAsset.duration + eighthAsset.duration)
                } catch _ {
                    print("Failed to load Audio track")
                }
                
            }else{
                print("false")
                
                let v9audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try v9audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, ninethAsset.duration),
                                                     of: ninethAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                     at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration + seventhAsset.duration + eighthAsset.duration)
                } catch _ {
                    print("Failed to load 故事版 9 Audio track")
                }
            }
            */
            
            // 4 - Get path
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            let date = dateFormatter.string(from: Date())
            let savePath = (documentDirectory as NSString).appendingPathComponent("mergeVideo-\(date).mov")
            let url = URL(fileURLWithPath: savePath)
            
            // 4.5 - store complete video url to core data
//            let videourlitem = VideoInfo(context: managedObjextContext)
//            videourlitem.videourl = url.absoluteString
//            videourlitem.videoname = VideoNameArray[Index].videoname
//
//            (UIApplication.shared.delegate as! AppDelegate).saveContext()
//            
//            print(VideoInfo.self)
            
//            //  Delete the data in the VideoInfo
//            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "VideoInfo")
//            let request = NSBatchDeleteRequest(fetchRequest: fetch)
//            do{
//                try managedObjextContext.execute(request)
//            }catch{
//            
//            }
            
            // 5 - Create Exporter
            guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
            exporter.outputURL = url
            exporter.outputFileType = AVFileTypeQuickTimeMovie
            exporter.shouldOptimizeForNetworkUse = true 
            exporter.videoComposition = mainComposition
            
            // 6 - Perform the Export
            exporter.exportAsynchronously() {
                DispatchQueue.main.async { _ in
                    self.exportDidFinish(exporter)
                }
            }
            //storevideocompleteURL()

        }
        
    }// end of merge
    
    
    /////////////////  Data Transmit    ////////////////
    
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
                    print(response)
                    //解包
                    guard let result = response.result.value else { return }
                    print("\(result)")
                    //须导入 swiftyJSON 第三方框架，否则报错
                    let success = JSON(result)["success"].int ?? -1
                    if success == 1 {
                        print("Upload Succes")
                        
                    }else{
                        print("Upload Failed")
//                        let alert = UIAlertController(title:"提示",message:"上傳失敗，請檢察網路是否已連線並重新上傳", preferredStyle: .alert)
//                        let action2 = UIAlertAction(title: "OK", style: .default, handler: nil)
//                        alert.addAction(action2)
//                        self.present(alert , animated: true , completion: nil)
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
    
    func getaudiourl(_ num: Int,completion: @escaping ((Bool, URL?)->Void)){
        makecall(num,completion: completion)
    }
    
    func makecall(_ num: Int, completion: @escaping ((Bool, URL?)->Void)) {
        let parameters: Parameters=["videoid": Index,"num": num]
        
        Alamofire.request("http://140.122.76.201/CoInQ/v1/getAudioInfo.php", method: .post, parameters: parameters).responseJSON
            {
                response in
                print (response)
                switch response.result {
                case .success(let result):
                    let jsonData = result as! NSDictionary
                    let audiourl = URL(string: (jsonData.value(forKey: "audiopath") as! String?)!)
                        completion(true,audiourl)
    
                case .failure(let error):
                    print(error)
                    completion(false,nil)
                }
//                guard response.result.isSuccess else {
//                    let errorMessage = response.result.error?.localizedDescription
//                    print("getaudio error\(errorMessage!)")
//                    return
//                }
//                guard let JSON = response.result.value as? [String: Any] else {
//                    print("JSON formate error")
//                    return
//                }
//                // 2.
//                if let audioinfo = JSON["audiopath"] as? String {
//                    let audiopath = audioinfo
//                    let audiourl = URL(string: audiopath)
//                    print(audiopath)
//                    completion(audiourl!)
//                }
        }
        
    }

    
    
    /////////////////   Recorder Part   ////////////////
    
    @IBAction func UseRecordSwitch(_ sender: UISwitch) {
        
        if sender.isOn {
            switchOutput.text = "使用這個配音"
            userecordnine = true
        }else{
            switchOutput.text = "不使用此配音"
            userecordnine = false
        }
    }

    @IBAction func Explain(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小解釋",message:"我可以分享\n我的科學探究歷程與這不科學探究影片\n想要傳達給觀眾的話。",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func play(){
            Player = AVPlayer(url: videourl!)
            let controller = AVPlayerViewController()
            controller.player = Player
            controller.showsPlaybackControls = false
            self.addChildViewController(controller)
            let videoFrame = CGRect(x: 44, y: 176, width: 681, height: 534)
            controller.view.frame = videoFrame
            self.view.addSubview(controller.view)
            Player?.volume = 0.0
            Player?.play()
    }
    
    func stopPlayer() {
        if let playy = Player {
            playy.pause()
            Player = nil
            
        } else {
            print("已經清空")
        }
    }
    
    @IBAction func record(_ sender: AnyObject) {
        setupRecorder()
        timeTimer?.invalidate()
        
        if soundRecorder.isRecording{
            soundRecorder.stop()
            sender.setTitle("錄音", for: UIControlState())
            sender.setImage(#imageLiteral(resourceName: "record"), for: UIControlState())
            ButtonPlay.isHidden = false
            ButtonPlay.isEnabled = true
            showSwitch()
            stopPlayer()
            progressView.progress = 0.0
            if progressViewTimer != nil {
                progressViewTimer?.invalidate()
            }
            //showTimeLabel()
            
        }else{
            //取影片長度並轉為秒數
            let durationtime = CMTimeGetSeconds((Asset?.duration)!)
            soundRecorder.record(forDuration: durationtime)
            
            showTimeLabel()
            timeTimer = Timer.scheduledTimer(timeInterval: 0.0167, target: self, selector: #selector(RecordAudio_Two.updateTimeLabel(_:)), userInfo: nil, repeats: true)
            progressCounter = 0.0
            if progressViewTimer != nil {
                progressViewTimer?.invalidate()
            }
            progressViewTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(RecordAudio_Two.updateProgressView(_:)), userInfo: nil, repeats: true)
            sender.setTitle("Stop", for: UIControlState())
            sender.setImage(#imageLiteral(resourceName: "stop"), for: UIControlState())
            ButtonPlay.isEnabled = false
            play()
            showTimeLabel()
        }
        
        RecordAudio_One().StoreRecord(directoryURL()!,clip: 9)
        
    }
    
    @IBAction func playvideo(_ sender: AnyObject) {
        
        if sender.titleLabel?!.text == "Stop" {
            SoundPlayer.stop()
            stopPlayer()
            print("stop")
            sender.setTitle("Play", for: UIControlState())
            sender.setImage(#imageLiteral(resourceName: "play"), for: UIControlState())
            ButttonRecord.isEnabled = true
            
        }else{
            preparePlayer()
            play()
            SoundPlayer.play()
            progressCounter = 0.0
            if progressViewTimer != nil {
                progressViewTimer?.invalidate()
            }
            progressViewTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(RecordAudio_Two.updateProgressView(_:)), userInfo: nil, repeats: true)
            
            sender.setTitle("Stop", for: UIControlState())
            sender.setImage(#imageLiteral(resourceName: "stop"), for: UIControlState())
            ButttonRecord.isEnabled = false
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: Player?.currentItem)
            
        }
        
    }
    
    //HELPERS
    
    func playerDidFinishPlaying(note: NSNotification){
        ButttonRecord.isEnabled = true
        ButtonPlay.setTitle("Play", for: UIControlState())
        ButtonPlay.setImage(#imageLiteral(resourceName: "play"), for: UIControlState())
    }
    
    func preparePlayer(){
        getaudio()
        let url = playURL()
        do {
            try SoundPlayer = AVAudioPlayer(contentsOf: url!)
            SoundPlayer.delegate = self
            SoundPlayer.prepareToPlay()
            SoundPlayer.volume = 1.0
        } catch {
            print("Error playing")
        }
        
    }
    
    func playURL() -> URL? {
        if AudioURL == nil {
            return directoryURL()
        } else {
            return AudioURL
        }
    }
    
    func setupRecorder(){
        
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        //ask for permission
        if (audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    
                    //set category and activate recorder session
                    do {
                        
                        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                        try self.soundRecorder = AVAudioRecorder(url: self.directoryURL()!, settings: self.recordSettings)
                        self.soundRecorder.prepareToRecord()
                        
                    } catch {
                        
                        print("Error Recording");
                        
                    }
                    
                }
            })
        }
        
    }
    
    func directoryURL() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent(AudioFileName)
        return soundURL
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        ButtonPlay.isEnabled = true
    }
    
    /*func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
     ButttonRecord.isEnabled = true
     ButtonPlay.setTitle("Play", for: UIControlState())
     }*/
    
    // MARK: Time Label
    
    func updateTimeLabel(_ timer: Timer) {
        if timeLabel.text != "00:00.00"{
            milliseconds -= 1
            let milli = (milliseconds % 60) + 39
            let sec = (milliseconds / 60) % 60
            let min = milliseconds / 3600
            timeLabel.text = NSString(format: "%02d:%02d.%02d", min, sec, milli) as String
            if timeLabel.text == "00:03.39" {
                timeLabel.textColor = UIColor.red
            }
        }else{
            ButtonPlay.isEnabled = true
            ButtonPlay.isHidden = false
            ButttonRecord.setTitle("錄音", for: UIControlState())
            ButttonRecord.setImage(#imageLiteral(resourceName: "record"), for: UIControlState())
            showSwitch()
        }
    }
    
    func updateProgressView(_ timer: Timer) {
        if timeLabel.text != "00:00.00"{
            let progressportion = Float(1/CMTimeGetSeconds((Asset?.duration)!))
            progressCounter += progressportion/10
            progressView.progress = progressCounter
            
            if progressCounter == 1.0 {
                progressViewTimer?.invalidate()
            }
            
            /*** DEBUG STATEMENT ***/
            //print("Progress: \(progressCounter)")
        }else{
            progressView.progress = 0.0
        }
    }
    
    func showTimeLabel(){
        //顯示影片秒數
        let durationtime = CMTimeGetSeconds((Asset?.duration)!)
        milliseconds = Int(durationtime) * 60
        let milli = (milliseconds % 60) + 39
        let sec = (milliseconds / 60) % 60
        let min = milliseconds / 3600
        timeLabel.text = NSString(format: "%02d:%02d.%02d", min, sec, milli) as String
        timeLabel.textColor = UIColor.black
    }
    
    func showSwitch(){
        switchOutput.isHidden = false
        UseRecordSwitch.isHidden = false
        userecordnine = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }


}//end of class


