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

protocol AudioRecorderViewControllerDelegate: class {
    func audioRecorderViewControllerDismissed(withFileURL fileURL: NSURL?)
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
        var outputURL: URL
        var videourl : URL?
        
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
            navigationItem.leftBarButtonItem?.title = "放棄配音"
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
            
            //VideoPlayer = AVPlayer(url: videourl!)
            //let controller = AVPlayerViewController()
            //controller.player = VideoPlayer
            //controller.showsPlaybackControls = false
            //self.addChildViewController(controller)
            //controller.view.frame = videoview.frame
            //self.view.addSubview(controller.view)
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
            audioRecorderDelegate?.audioRecorderViewControllerDismissed(withFileURL: nil)
            //let alert = UIAlertController
        }
        
        func saveAudio(_ sender: AnyObject) {
            cleanup()
            audioRecorderDelegate?.audioRecorderViewControllerDismissed(withFileURL: outputURL as NSURL)
            //mergeaudioandvideo
        }
        
        func playvideo(){
            VideoPlayer = AVPlayer(url: videourl!)
            let controller = AVPlayerViewController()
            controller.player = VideoPlayer
            controller.showsPlaybackControls = false
            self.addChildViewController(controller)
            let videoFrame = CGRect(x: 44, y: 26, width: 681, height: 534)
            controller.view.frame = videoFrame
            self.view.addSubview(controller.view)
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
                milliseconds = 0
                timeLabel.text = "00:00.00"
                timeTimer = Timer.scheduledTimer(timeInterval: 0.0167, target: self, selector: #selector(AudioRecorderChildViewController.updateTimeLabel(_:)), userInfo: nil, repeats: true)
                recorder.deleteRecording()
                recorder.record()
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
        
        @IBAction func play(_ sender: AnyObject) {
            
            if let player = player {
                player.stop()
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
            
            player?.delegate = self
            player?.play()
            
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
                playvideo()

            } else {
                playButton.setImage(#imageLiteral(resourceName: "play"), for: UIControlState())
                recordButton.isEnabled = true
                recordButtonContainer.alpha = 1
                stopvideo()

            }
            
            playButton.isEnabled = !recorder.isRecording
            playButton.alpha = recorder.isRecording ? 0.25 : 1
            saveButton.isEnabled = !recorder.isRecording
            
        }
        
        
        
        
        // MARK: Time Label
        
        func updateTimeLabel(_ timer: Timer) {
            milliseconds += 1
            let milli = (milliseconds % 60) + 39
            let sec = (milliseconds / 60) % 60
            let min = milliseconds / 3600
            timeLabel.text = NSString(format: "%02d:%02d.%02d", min, sec, milli) as String
        }
        
        
        // MARK: Playback Delegate
        
        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            self.player = nil
            updateControls()
        }
        
    }
    
}

