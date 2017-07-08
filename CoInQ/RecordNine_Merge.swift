//
//  RecordNine_Merge.swift
//  CoInQ
//
//  Created by hui on 2017/5/16.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import AVFoundation
import MobileCoreServices
import MediaPlayer
import CoreMedia
import Photos

class RecordNine_Merge: UIViewController{
    
    var loadingAssetOne = false
    var audioAssetOne: AVAsset?
    var firstAsset: AVAsset?
    var secondAsset: AVAsset?
    var thirdAsset: AVAsset?
    var fourthAsset: AVAsset?
    var fifthAsset: AVAsset?
    var sixthAsset: AVAsset?
    var seventhAsset: AVAsset?
    var eighthAsset: AVAsset?
    var ninthAsset: AVAsset?

    
    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func startActivityIndicator() {
        let screenSize: CGRect = UIScreen.main.bounds
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
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
                    let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: self.switchPage)
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
        ninthAsset = nil
        //audioAsset = nil
    }
    
    func switchPage(action: UIAlertAction){
        //7 - Page switch to CompleteVC
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "CSCL") as! UITabBarController
        self.present(vc, animated: true, completion: nil)
        //self.tabBarController?.selectedIndex = 3
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
        
        if let firstAsset = firstAsset, let secondAsset = secondAsset ,let thirdAsset = thirdAsset ,let fourthAsset = fourthAsset ,let fifthAsset = fifthAsset ,let sixthAsset = sixthAsset ,let seventhAsset = seventhAsset ,let eighthAsset = eighthAsset ,let ninethAsset = ninthAsset{
            startActivityIndicator()
            
            let totalTIME = firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration + seventhAsset.duration + eighthAsset.duration + ninethAsset.duration
            
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
          if UserDefaults.standard.bool(forKey: "UseRecordOne")  {
            
            audioAssetOne = AVAsset(url:UserDefaults.standard.url(forKey: "RecordOne")!)
            print(UserDefaults.standard.bool(forKey: "UseRecordOne"))
            
                let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration)),
                                                   of: (audioAssetOne?.tracks(withMediaType: AVMediaTypeAudio)[0])! ,
                                                   at: kCMTimeZero)
                } catch _ {
                    print("Failed to load Audio track")
                }
             
            }else{
            print("false")
             
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
            if UserDefaults.standard.bool(forKey: "UseRecordTwo")  {
                
                audioAssetOne = AVAsset(url:UserDefaults.standard.url(forKey: "RecordTwo")!)
                print(UserDefaults.standard.bool(forKey: "UseRecordTwo"))
                
                let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration),
                                                   of: (audioAssetOne?.tracks(withMediaType: AVMediaTypeAudio)[0])! ,
                                                   at: firstAsset.duration)
                } catch _ {
                    print("Failed to load Audio track")
                }
                
            }else{
                print("false")
                
                let v2audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try v2audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration),
                                                     of: secondAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                     at: firstAsset.duration)
                } catch _ {
                    print("Failed to load 故事版 2 Audio track")
                }
                
            }
            
            

            let v3audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
            do {
                try v3audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, thirdAsset.duration),
                                                 of: thirdAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                 at: firstAsset.duration + secondAsset.duration)
            } catch _ {
                print("Failed to load 故事版 3 Audio track")
            }
            let v4audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
            do {
                try v4audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, fourthAsset.duration),
                                                 of: fourthAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                 at: firstAsset.duration + secondAsset.duration + thirdAsset.duration)
            } catch _ {
                print("Failed to load 故事版 4 Audio track")
            }
            let v5audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
            do {
                try v5audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, fifthAsset.duration),
                                                 of: fifthAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                 at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration)
            } catch _ {
                print("Failed to load 故事版 5 Audio track")
            }
            let v6audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
            do {
                try v6audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, sixthAsset.duration),
                                                 of: sixthAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                 at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration)
            } catch _ {
                print("Failed to load 故事版 6 Audio track")
            }
            let v7audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
            do {
                try v7audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, seventhAsset.duration),
                                                 of: seventhAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                 at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration)
            } catch _ {
                print("Failed to load 故事版 7 Audio track")
            }
            let v8audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
            do {
                try v8audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, eighthAsset.duration),
                                                 of: eighthAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                 at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration + seventhAsset.duration)
            } catch _ {
                print("Failed to load 故事版 8 Audio track")
            }
            let v9audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
            do {
                try v9audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, ninethAsset.duration),
                                                 of: ninethAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                 at: firstAsset.duration + secondAsset.duration + thirdAsset.duration + fourthAsset.duration + fifthAsset.duration + sixthAsset.duration + seventhAsset.duration + eighthAsset.duration)
            } catch _ {
                print("Failed to load 故事版 9 Audio track")
            }
            
            
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
            
            // 6 - Perform the Export
            exporter.exportAsynchronously() {
                DispatchQueue.main.async { _ in
                    self.exportDidFinish(exporter)
                }
            }
            
        }
        
        
    }
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstAsset   = AVAsset(url:UserDefaults.standard.url(forKey: "VideoOne")!)
        secondAsset  = AVAsset(url:UserDefaults.standard.url(forKey: "VideoTwo")!)
        thirdAsset   = AVAsset(url:UserDefaults.standard.url(forKey: "VideoThree")!)
        fourthAsset  = AVAsset(url:UserDefaults.standard.url(forKey: "VideoFour")!)
        fifthAsset   = AVAsset(url:UserDefaults.standard.url(forKey: "VideoFive")!)
        sixthAsset   = AVAsset(url:UserDefaults.standard.url(forKey: "VideoSix")!)
        seventhAsset = AVAsset(url:UserDefaults.standard.url(forKey: "VideoSeven")!)
        eighthAsset  = AVAsset(url:UserDefaults.standard.url(forKey: "VideoEight")!)
        ninthAsset   = AVAsset(url:UserDefaults.standard.url(forKey: "VideoNine")!)
    }

}//end of class


