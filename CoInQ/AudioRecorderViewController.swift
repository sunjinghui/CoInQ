//
//  AudioRecorderViewController.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos

protocol AudioRecorderViewControllerDelegate: class {
    func audioRecorderViewControllerDismissed(withFileURL fileURL: URL?,clip: Int)
}


class AudioRecorderViewController: UINavigationController {
    
    internal let childViewController = AudioRecorderChildViewController()
    weak var audioRecorderDelegate: AudioRecorderViewControllerDelegate?
    var statusBarStyle: UIStatusBarStyle = .default
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statusBarStyle = UIApplication.shared.statusBarStyle
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        childViewController.audioRecorderDelegate = audioRecorderDelegate
        viewControllers = [childViewController]
        
        navigationBar.barTintColor = UIColor.black
        navigationBar.tintColor = UIColor.white
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    // MARK: AudioRecorderChildViewController
    
    internal class AudioRecorderChildViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
        
        var saveButton: UIBarButtonItem!
        @IBOutlet weak var timeLabel: UILabel!
        @IBOutlet weak var recordButton: UIButton!
        @IBOutlet weak var recordButtonContainer: UIView!
        @IBOutlet weak var playButton: UIButton!
        weak var audioRecorderDelegate: AudioRecorderViewControllerDelegate?
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

        var timeTimer: Timer?
        var milliseconds: Int = 0
        
        var recorder: AVAudioRecorder!
        var player: AVAudioPlayer?
        var VideoPlayer: AVPlayer?
        var PlayController = AVPlayerViewController()
        var outputURL: URL
        var videourl : URL?
        var clip: Int?
        var note: String?
        
        init() {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
            let outputPath = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
            outputURL = URL(fileURLWithPath: outputPath)
            super.init(nibName: "AudioRecorderViewController", bundle: nil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            title = "配音階段 \(clip ?? 000)"
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(AudioRecorderChildViewController.dismiss(_:)))
            edgesForExtendedLayout = UIRectEdge()
            
            saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(AudioRecorderChildViewController.saveAudio(_:)))
            saveButton.title = "使用此配音"
            navigationItem.rightBarButtonItem = saveButton
            saveButton.isEnabled = false
            
            let settings = [AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC as UInt32), AVSampleRateKey: NSNumber(value: 44100 as Int), AVNumberOfChannelsKey: NSNumber(value: 2 as Int)]
            try! recorder = AVAudioRecorder(url: outputURL, settings: settings)
            recorder.delegate = self
            recorder.prepareToRecord()
            
            recordButton.layer.cornerRadius = 4
            recordButtonContainer.layer.cornerRadius = 40
            recordButtonContainer.layer.borderColor = UIColor.white.cgColor
            recordButtonContainer.layer.borderWidth = 3
            
            let videoFrame = CGRect(x: 44, y: 60, width: 681, height: 480)
            let imageview = UIImageView(frame: videoFrame)
            let asset = AVURLAsset(url: videourl!, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
//            imgGenerator.appliesPreferredTrackTransform = false
    
            do {
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                imageview.image = UIImage(cgImage: cgImage)
        
            } catch let error {
                print("*** Error generating thumbnail: \(error)")
            }

            imageview.contentMode = .scaleAspectFit
            self.view.addSubview(imageview)

        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
                try AVAudioSession.sharedInstance().setActive(true)
            }
            catch let error as NSError {
                NSLog("Error: \(error)")
            }
            NotificationCenter.default.addObserver(self, selector: #selector(AudioRecorderChildViewController.stopRecording(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            NotificationCenter.default.removeObserver(self)
        }
        
        func dismiss(_ sender: AnyObject) {
            cleanup()
            let alertController = UIAlertController(title: "請注意", message: "不會保存配音內容\n你將返回上一頁", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title:"取消",style: .cancel, handler: { (action) -> Void in
                lognote("b\(String(describing: self.clip))d", google_userid, "\(Index)")
            })
            let defaultAction = UIAlertAction(title: "確定", style: .default, handler: { (action) -> Void in
                lognote("b\(String(describing: self.clip))t", google_userid, "\(Index)")
                self.audioRecorderDelegate?.audioRecorderViewControllerDismissed(withFileURL: nil,clip: 0)
            })
            alertController.addAction(defaultAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        func saveAudio(_ sender: AnyObject) {
            merge(videourl!, outputURL)
        }
        
        func playvideo(){
            VideoPlayer = AVPlayer(url: videourl!)
            PlayController = AVPlayerViewController()
            PlayController.player = VideoPlayer
            self.addChildViewController(PlayController)
            let videoFrame = CGRect(x: 44, y: 26, width: 681, height: 534)
            PlayController.showsPlaybackControls = false
            PlayController.view.frame = videoFrame
            self.view.addSubview(PlayController.view)
            VideoPlayer?.volume = 0.0
            VideoPlayer?.play()
        }
        
        func stopvideo(){
            if let videoplay = VideoPlayer {
                videoplay.pause()
                VideoPlayer = nil
            }
        }
        @IBAction func helper(_ sender: Any) {
            let myAlert: UIAlertController = UIAlertController(title:"小提示",message: self.note ,preferredStyle: .alert)
            let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:nil)
            myAlert.addAction(action)
            lognote("ae\(String(describing: self.clip))",google_userid,"\(Index)")
            self.present(myAlert, animated: true, completion: nil)
        }
        
        @IBAction func toggleRecord(_ sender: AnyObject) {
            lognote("ra\(String(describing: clip))", google_userid, "\(Index)")
            timeTimer?.invalidate()

            if recorder.isRecording {
                recorder.stop()
                stopvideo()
            } else {
                runTimer()
                recorder.deleteRecording()
                
                let Asset = AVAsset(url: videourl!)
                let durationtime = CMTimeGetSeconds((Asset.duration))
                recorder.record(forDuration: durationtime)
                playvideo()
            }
            updateControls()
        }
        
        func stopRecording(_ sender: AnyObject) {
            if recorder.isRecording {
                toggleRecord(sender)
            }
        }
        
        func cleanup() {
            timeTimer?.invalidate()
            if recorder.isRecording {
                recorder.stop()
                recorder.deleteRecording()
            }
            if let player = player {
                player.stop()
                self.player = nil
            }
        }
        
        func runTimer(){
            //顯示影片秒數
            let Asset = AVAsset(url: videourl!)
            let durationtime = CMTimeGetSeconds((Asset.duration))
            milliseconds = Int(durationtime) * 60
            let milli = (milliseconds % 60) + 39
            let sec = (milliseconds / 60) % 60
            let min = milliseconds / 3600
            timeLabel.text = NSString(format: "%02d:%02d.%02d", min, sec, milli) as String
            
            timeTimer = Timer.scheduledTimer(timeInterval: 0.0167, target: self, selector: #selector(AudioRecorderChildViewController.updateTimeLabel(_:)), userInfo: nil, repeats: true)
        }
        
        @IBAction func play(_ sender: AnyObject) {
            lognote("pr\(String(describing: clip))", google_userid, "\(Index)")

            if let player = player {
                player.stop()
                stopvideo()
                self.player = nil
                updateControls()
                return
            }
            
            do {
                try player = AVAudioPlayer(contentsOf: outputURL)
            }
            catch let error as NSError {
                NSLog("error: \(error)")
            }
            runTimer()
            player?.delegate = self
            player?.play()
            playvideo()

            updateControls()
        }
        
        func updateControls() {
            
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.recordButton.transform = self.recorder.isRecording ? CGAffineTransform(scaleX: 0.5, y: 0.5) : CGAffineTransform(scaleX: 1, y: 1)
            })
            
            if let _ = player {
                playButton.setImage(#imageLiteral(resourceName: "stop"), for: UIControlState())
                recordButton.isEnabled = false
                recordButtonContainer.alpha = 0.25

            } else {
                playButton.setImage(#imageLiteral(resourceName: "play"), for: UIControlState())
                recordButton.isEnabled = true
                recordButtonContainer.alpha = 1
            }
            
            playButton.isEnabled = !recorder.isRecording
            playButton.alpha = recorder.isRecording ? 0.25 : 1
            saveButton.isEnabled = !recorder.isRecording
            
        }
        
        // MARK: Time Label
        
        func updateTimeLabel(_ timer: Timer) {
            if timeLabel.text != "00:00.00"{
                milliseconds -= 1
                let milli = (milliseconds % 60) + 39
                let sec = (milliseconds / 60) % 60
                let min = milliseconds / 3600
                timeLabel.text = NSString(format: "%02d:%02d.%02d", min, sec, milli) as String
            }else{
                timeTimer?.invalidate()
            }
        }
        
        
        // MARK: Playback Delegate
        
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            self.player = nil
            updateControls()
        }
        
        func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
            updateControls()
        }
        
        func deleteFile(_ filePath:URL) {
            
            guard FileManager.default.fileExists(atPath: filePath.path) else { return }
            
            do {
                try    FileManager.default.removeItem(atPath: filePath.path)
                //            print("remove video from \(filePath)")
            } catch {
                fatalError("Unable to delete file: \(error) : \(#function).")
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
            
            var scaleToFitRatio = assetTrack.naturalSize.width / assetTrack.naturalSize.width
            if assetInfo.isPortrait {
                scaleToFitRatio = assetTrack.naturalSize.height / assetTrack.naturalSize.height
                let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
                instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: 0)),at: kCMTimeZero)
            } else {
                let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
                var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: 0))
                if (assetTrack.naturalSize.width > assetTrack.naturalSize.height){
                    concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: 0))
                }else{
                    concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: 0))
                }
                if assetInfo.orientation == .down {
                    let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                    let yFix = assetTrack.naturalSize.height
                    let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
                    concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
                }
                instruction.setTransform(concat, at: kCMTimeZero)
            }
            
            return instruction
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
        
        func merge(_ videourl: URL, _ audiourl: URL){
            startActivityIndicator()
            let mixComposition : AVMutableComposition = AVMutableComposition()
//            var mutableCompositionVideoTrack : [AVMutableCompositionTrack] = []
//            var mutableCompositionAudioTrack : [AVMutableCompositionTrack] = []
            let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
            var allVideoInstruction = [AVMutableVideoCompositionLayerInstruction]()
            //start merge
            
            let aVideoAsset : AVAsset = AVAsset(url: videourl)
            let aAudioAsset : AVAsset = AVAsset(url: audiourl)
            
//            mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid))
//            mutableCompositionAudioTrack.append( mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid))
            
//            let aVideoAssetTrack : AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
//            let aAudioAssetTrack : AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaTypeAudio)[0]
            
            let videoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
            do {
                try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAsset.duration), of: aVideoAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: kCMTimeZero)
                try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAsset.duration),//CMTimeAdd(firstAsset.duration, secondAsset.duration)),
                    of: (aAudioAsset.tracks(withMediaType: AVMediaTypeAudio)[0]) ,
                    at: kCMTimeZero)
                let currentInstruction: AVMutableVideoCompositionLayerInstruction = videoCompositionInstructionForTrack(videoTrack, asset: aVideoAsset)
                currentInstruction.setOpacity(0.0, at: aVideoAsset.duration)
                allVideoInstruction.append(currentInstruction)
            } catch _ {
                print("Failed to load Audio track")
            }
            
//            do{
//                try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: kCMTimeZero)
////                try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: kCMTimeZero)
//                try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: kCMTimeZero)
//
//            }catch{
//                
//            }
            
            totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, aVideoAsset.duration )
            totalVideoCompositionInstruction.layerInstructions = allVideoInstruction
            
            let mutableVideoComposition : AVMutableVideoComposition = AVMutableVideoComposition()
            mutableVideoComposition.instructions = [totalVideoCompositionInstruction]
            mutableVideoComposition.frameDuration = CMTimeMake(1, 30)
            
//            mutableVideoComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//            let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            let assetTrack = aVideoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
            let transform = assetTrack.preferredTransform
            let assetInfo = orientationFromTransform(transform)
            if assetInfo.isPortrait{
                mutableVideoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
            }else{
                mutableVideoComposition.renderSize = CGSize(width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.height)
            }

            
            //        playerItem = AVPlayerItem(asset: mixComposition)
            //        player = AVPlayer(playerItem: playerItem!)
            //
            //
            //        AVPlayerVC.player = player
            
            
            
            //find your video on this URl
//            let savePathUrl : URL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/newVideo.mp4")
            // 4 - Get path
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let filename = UUID().uuidString + ".mov"
            let savePath = (documentDirectory as NSString).appendingPathComponent(filename)
            deleteFile(URL(string: savePath)!)
            let savePathUrl = URL(fileURLWithPath: savePath)
            
            let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
            assetExport.outputFileType = AVFileTypeQuickTimeMovie
            assetExport.outputURL = savePathUrl as URL
            assetExport.shouldOptimizeForNetworkUse = true
            assetExport.videoComposition = mutableVideoComposition
            
            assetExport.exportAsynchronously { () -> Void in
                switch assetExport.status {
                    
                case AVAssetExportSessionStatus.completed:
                    PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: savePathUrl as URL)}, completionHandler: {saved, error in
                        if saved {
                            self.stopActivityIndicator()
                            let alertController = UIAlertController(title: "儲存完成", message: "新的配音影片已儲存在相簿中", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "確定", style: .default, handler:{ (action) -> Void in
                                lognote("c\(String(describing: self.clip))r", google_userid, "\(Index)")
                                (self.audioRecorderDelegate?.audioRecorderViewControllerDismissed(withFileURL: savePathUrl,clip: self.clip!))!
                            })
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                            self.cleanup()
                        }
                    })
                    
                case  AVAssetExportSessionStatus.failed:
                    let alertController = UIAlertController(title: "影片輸出失敗，請重新操作一次", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "確定", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    print("failed \(String(describing: assetExport.error))")
                case AVAssetExportSessionStatus.cancelled:
                    print("cancelled \(String(describing: assetExport.error))")
                default:
                    print("complete")
                }
            }

        }
        
    }
    
}

