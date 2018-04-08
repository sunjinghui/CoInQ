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
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.setStatusBarStyle(statusBarStyle, animated: animated)
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
        
        var timeTimer: Timer?
        var milliseconds: Int = 0
        
        var recorder: AVAudioRecorder!
        var player: AVAudioPlayer?
        var VideoPlayer: AVPlayer?
        var PlayController = AVPlayerViewController()
        var outputURL: URL
        var videourl : URL?
        var clip: Int?
        
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
            title = "配音階段"
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
            audioRecorderDelegate?.audioRecorderViewControllerDismissed(withFileURL: nil,clip: 0)
            let alertController = UIAlertController(title: "請注意", message: "不會保存配音內容、你將返回上一頁", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title:"取消",style: .cancel, handler: nil)
            let defaultAction = UIAlertAction(title: "確定", style: .default, handler: nil)
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
        
        @IBAction func toggleRecord(_ sender: AnyObject) {
            
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
        
        func merge(_ videourl: URL, _ audiourl: URL){
            let mixComposition : AVMutableComposition = AVMutableComposition()
            var mutableCompositionVideoTrack : [AVMutableCompositionTrack] = []
            var mutableCompositionAudioTrack : [AVMutableCompositionTrack] = []
            let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
            
            
            //start merge
            
            let aVideoAsset : AVAsset = AVAsset(url: videourl)
            let aAudioAsset : AVAsset = AVAsset(url: audiourl)
            
            mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid))
            mutableCompositionAudioTrack.append( mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid))
            
            let aVideoAssetTrack : AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaTypeVideo)[0]
            let aAudioAssetTrack : AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaTypeAudio)[0]
            
            
            
            do{
                try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: kCMTimeZero)
//                try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: kCMTimeZero)
                try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: kCMTimeZero)
                
            }catch{
                
            }
            
            totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,aVideoAssetTrack.timeRange.duration )
            
            let mutableVideoComposition : AVMutableVideoComposition = AVMutableVideoComposition()
            mutableVideoComposition.frameDuration = CMTimeMake(1, 30)
            
            mutableVideoComposition.renderSize = aVideoAssetTrack.naturalSize
            
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
            
            assetExport.exportAsynchronously { () -> Void in
                switch assetExport.status {
                    
                case AVAssetExportSessionStatus.completed:
                    PHPhotoLibrary.shared().performChanges({PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: savePathUrl as URL)}, completionHandler: {saved, error in
                        if saved {
                            print("success")
                            let alertController = UIAlertController(title: "儲存完成", message: "新的配音影片已儲存在相簿中", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "確定", style: .default, handler:{ (action) -> Void in
                            (self.audioRecorderDelegate?.audioRecorderViewControllerDismissed(withFileURL: savePathUrl,clip: self.clip!))!
                            })
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                            self.cleanup()
                        }
                    })
                    
                case  AVAssetExportSessionStatus.failed:
                    let alertController = UIAlertController(title: "合併失敗，請重新操作一次", message: nil, preferredStyle: .alert)
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

