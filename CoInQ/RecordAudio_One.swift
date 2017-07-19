//
//  RecordAudio_OneTwo.swift
//  CoInQ
//
//  Created by hui on 2017/5/24.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class RecordAudio_One: UIViewController , AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet weak var videoPreviewLayer: UIImageView!
    @IBOutlet weak var ButttonRecord: UIButton!
    @IBOutlet weak var ButtonPlay: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var switchOutput: UILabel!
    @IBOutlet weak var UseRecordSwitch: UISwitch!
    
    var soundRecorder : AVAudioRecorder!
    var SoundPlayer : AVAudioPlayer!
    
    var timeTimer: Timer?
    var progressCounter: Float = 0.00
    var videolength: Double = 0
    var progressViewTimer: Timer?
    var milliseconds: Int = 0
    
    var AudioFileName = "sound.m4a"
    
    var firstAsset: AVAsset? = AVAsset(url:UserDefaults.standard.url(forKey: "VideoOne")!)
    var Player: AVPlayer?
    
    let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0) as Float),
                          AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC) as Int32),
                          AVNumberOfChannelsKey : NSNumber(value: 1 as Int32),
                          AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue) as Int32)]
    
    @IBAction func UseRecordSwitch(_ sender: UISwitch) {
        
        if sender.isOn {
            switchOutput.text = "使用這個配音"
            StoreRecordPathInUserdefault()
        }else{
            switchOutput.text = "不使用此配音"
            UserDefaults.standard.set(false, forKey: "UseRecordOne")
        }
        print(UserDefaults.standard.bool(forKey: "UseRecordOne"))
    }
    
    @IBAction func BackToSelectVideoNine(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        
        setupRecorder()

        //影片縮圖
        let asset = AVURLAsset(url: UserDefaults.standard.url(forKey: "VideoOne")!, options: nil)
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
        if UserDefaults.standard.object(forKey: "RecordOne") == nil {
            ButtonPlay.isHidden = true
            switchOutput.isHidden = true
            UseRecordSwitch.isHidden = true
        }
    }
    
    @IBAction func Explain(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小解釋",message:"我可以說明\n這個自然現象中特別值得注意的重點。",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func play(){
            Player = AVPlayer(url: UserDefaults.standard.url(forKey: "VideoOne")!)
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
            let durationtime = CMTimeGetSeconds((firstAsset?.duration)!)
            soundRecorder.record(forDuration: durationtime)
            
            showTimeLabel()
            timeTimer = Timer.scheduledTimer(timeInterval: 0.0167, target: self, selector: #selector(RecordAudio_One.updateTimeLabel(_:)), userInfo: nil, repeats: true)
            progressCounter = 0.0
            if progressViewTimer != nil {
                progressViewTimer?.invalidate()
            }
            progressViewTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(RecordAudio_One.updateProgressView(_:)), userInfo: nil, repeats: true)
            sender.setTitle("Stop", for: UIControlState())
            sender.setImage(#imageLiteral(resourceName: "stop"), for: UIControlState())
            ButtonPlay.isEnabled = false
            play()
            showTimeLabel()
        }
        
        StoreRecordPathInUserdefault()

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
            progressViewTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(RecordAudio_One.updateProgressView(_:)), userInfo: nil, repeats: true)
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
        
        do {
            try SoundPlayer = AVAudioPlayer(contentsOf: directoryURL()!)
            SoundPlayer.delegate = self
            SoundPlayer.prepareToPlay()
            SoundPlayer.volume = 1.0
        } catch {
            print("Error playing")
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
        let soundURL = documentDirectory.appendingPathComponent("sound.m4a")
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
        let progressportion = Float(1/CMTimeGetSeconds((firstAsset?.duration)!))
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
        let durationtime = CMTimeGetSeconds((firstAsset?.duration)!)
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
    }
    
    func StoreRecordPathInUserdefault() {
        let userdefault = UserDefaults.standard
        userdefault.set(directoryURL(), forKey: "RecordOne")
        userdefault.set(true, forKey: "UseRecordOne")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
