//
//  RecordNine_Merge.swift
//  CoInQ
//
//  Created by hui on 2017/5/16.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import AVFoundation
import MobileCoreServices
import AssetsLibrary
import MediaPlayer
import CoreMedia
import Photos

class RecordNine_Merge: UIViewController{
    
    var loadingAssetOne = false
    var audioAsset: AVAsset?
    var firstAsset: AVAsset?
    var secondAsset: AVAsset?
    var thirdAsset: AVAsset?
    var fourthAsset: AVAsset?
    var fifthAsset: AVAsset?
    var sixthAsset: AVAsset?
    var seventhAsset: AVAsset?
    var eighthAsset: AVAsset?
    var NinthAsset: AVAsset?
    
    @IBOutlet var activityMonitor: UIActivityIndicatorView!
    

    //匯出並儲存影片至相簿
    func exportDidFinish(_ session: AVAssetExportSession) {
        if session.status == AVAssetExportSessionStatus.completed {
            let outputURL = session.outputURL
            PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)}) { saved, error in
                if saved {
                    let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        activityMonitor.stopAnimating()
        firstAsset = nil
        secondAsset = nil
        //audioAsset = nil
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
        if let firstAsset = firstAsset, let secondAsset = secondAsset ,let thirdAsset = thirdAsset{
            activityMonitor.startAnimating()
            
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
            
            // 2.1
            let mainInstruction = AVMutableVideoCompositionInstruction()
            mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, firstAsset.duration + secondAsset.duration + thirdAsset.duration)
            //(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration,thirdAsset.duration))
            
            // 2.2
            let firstInstruction = videoCompositionInstructionForTrack(firstTrack, asset: firstAsset)
            firstInstruction.setOpacity(0.0, at: firstAsset.duration)
            let secondInstruction = videoCompositionInstructionForTrack(secondTrack, asset: secondAsset)
            secondInstruction.setOpacity(0.0, at: firstAsset.duration + secondAsset.duration)
            let thirdInstruction = videoCompositionInstructionForTrack(thirdTrack, asset: thirdAsset)
            
            // 2.3
            mainInstruction.layerInstructions = [firstInstruction, secondInstruction, thirdInstruction]
            let mainComposition = AVMutableVideoComposition()
            mainComposition.instructions = [mainInstruction]
            mainComposition.frameDuration = CMTimeMake(1, 30)
            mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            // 3 - Audio track
            if let loadedAudioAsset = audioAsset {
                let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration)),
                                                   of: loadedAudioAsset.tracks(withMediaType: AVMediaTypeAudio)[0] ,
                                                   at: kCMTimeZero)
                } catch _ {
                    print("Failed to load Audio track")
                }
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
/*        fourthAsset  = AVAsset(url:UserDefaults.standard.url(forKey: "VideoFour")!)
        fifthAsset   = AVAsset(url:UserDefaults.standard.url(forKey: "VideoFive")!)
        sixthAsset   = AVAsset(url:UserDefaults.standard.url(forKey: "VideoSix")!)
        seventhAsset = AVAsset(url:UserDefaults.standard.url(forKey: "VideoSeven")!)
        eighthAsset  = AVAsset(url:UserDefaults.standard.url(forKey: "VideoEight")!)
        NinthAsset   = AVAsset(url:UserDefaults.standard.url(forKey: "VideoNine")!)*/
    }

}//end of class


