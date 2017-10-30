//
//  RecordAudio_Six.swift
//  CoInQ
//
//  Created by hui on 2017/7/30.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Alamofire
import SwiftyJSON


class RecordAudio_Six: UIViewController , AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
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
    
    var AudioFileName = UUID().uuidString + ".m4a"
    var AudioURL: URL?
    var videourl : URL?

    var Asset: AVAsset?
    var Player: AVPlayer?
    
    let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0) as Float),
                          AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC) as Int32),
                          AVNumberOfChannelsKey : NSNumber(value: 1 as Int32),
                          AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue) as Int32)]
    
    @IBAction func UseRecordSwitch(_ sender: UISwitch) {
        
        if sender.isOn {
            switchOutput.text = "使用這個配音"
            UserDefaults.standard.set(true, forKey: "userecordsix")
        }else{
            switchOutput.text = "不使用此配音"
            UserDefaults.standard.set(true, forKey: "userecordsix")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecorder()
        getaudio()
        videourl = RecordAudio_One().getvideo("videosix_path")
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
            UserDefaults.standard.set(false, forKey: "userecordsix")
    }
    
    func getaudio(){
        let parameters: Parameters=["videoid": Index,"num": 6]
        
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
                // 2.
                if let audioinfo = JSON["audiopath"] as? String {
                    let audiopath = audioinfo
                    if !(audiopath.isEmpty) {
                        let url = URL(string: audiopath)
                        if FileManager.default.fileExists(atPath: (url?.path)!) {
                            print("FILE 6 FOUND")
                            self.ButtonPlay.isHidden = false
                            self.switchOutput.isHidden = false
                            self.UseRecordSwitch.isHidden = false
                            self.AudioURL = URL(string: audiopath)
                            UserDefaults.standard.set(self.AudioURL!, forKey: "recordsix")
                            self.UseRecordSwitch.isOn = false
                        } else {
                            //self.donloadVideo(url: url!)
                            print("FILE 6 NOT FOUND")
                            
                        }
                    }
                }
        }
        
    }
    
    @IBAction func Explain(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小提示",message:"說說看\n我採用了文字、圖表、聲音、影片\n的哪些特性來呈現\n我認為可能的解釋。",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        lognote("ae6",google_userid,"\(Index)")
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
                StoreRecord(directoryURL()!,"userecordsix",clip: 6)
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
        updataudiourl()
    }
    
    @IBAction func playvideo(_ sender: AnyObject) {
        lognote("pr6", google_userid, "\(Index)")

        if sender.titleLabel?!.text == "Stop" {
            SoundPlayer.stop()
            stopPlayer()
            print("stop")
            sender.setTitle("Play", for: UIControlState())
            sender.setImage(#imageLiteral(resourceName: "play"), for: UIControlState())
            ButttonRecord.isEnabled = true
            if progressViewTimer != nil {
                progressViewTimer?.invalidate()
            }
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
    
    func updataudiourl(){
        let parameters: Parameters=["videoid": Index,"num": 6]
        
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
                // 2.
                if let audioinfo = JSON["audiopath"] as? String {
                    //                    audioArray = audioinfo
                    let audiopath = audioinfo
                    
                    if !(audiopath.isEmpty) {
                        let url = URL(string: audiopath)
                        if FileManager.default.fileExists(atPath: (url?.path)!) {
                            self.AudioURL = URL(string: audiopath)
                        }
                    }
                }
        }
        
    }
    
    func preparePlayer(){
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
            timeTimer?.invalidate()
            StoreRecord(directoryURL()!,"userecordsix",clip: 6)
            UserDefaults.standard.set(directoryURL()!, forKey: "recordsix")
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
    }
    
    func StoreRecord(_ audiourl: URL,_ userecord: String,clip: Int) {
        UserDefaults.standard.set(true, forKey: userecord)
        lognote("ra\(clip)", google_userid, "\(Index)")
        Alamofire.upload(
            //同样采用post表单上传
            multipartFormData: { multipartFormData in
                
                multipartFormData.append(audiourl, withName: "file")//, fileName: self.AudioFileName, mimeType: "audio/m4a")
                multipartFormData.append("\(Index)".data(using: String.Encoding.utf8, allowLossyConversion: false)!,withName: "videoid")
                multipartFormData.append(google_userid.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "google_userid")
                multipartFormData.append((audiourl.absoluteString.data(using: String.Encoding.utf8, allowLossyConversion: false)!),withName: "audiopath")
                multipartFormData.append("\(clip)".data(using: String.Encoding.utf8, allowLossyConversion: false)!,withName: "clip")
                //                for (key, val) in parameters {
                //                    multipartFormData.append(val.data(using: String.Encoding.utf8)!, withName: key)
                //                }
                
                //SERVER ADD
        },to: "http://140.122.76.201/CoInQ/v1/uploadaudio.php",
          encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                //json处理
                upload.responseJSON { response in
                    //解包
                    guard let result = response.result.value else { return }
                    let success = JSON(result)["success"].int ?? -1
                    if success == 1 {
                        print("Upload Succes")
                        self.ButtonPlay.isEnabled = true
                        self.ButtonPlay.isHidden = false
                        self.ButttonRecord.setTitle("錄音", for: UIControlState())
                        self.ButttonRecord.setImage(#imageLiteral(resourceName: "record"), for: UIControlState())
                        UserDefaults.standard.set(audiourl, forKey: "recordsix")
                        self.showSwitch()
                    }else{
                        print("Upload Failed")
                    }
                }
                
            case .failure(let encodingError):
                print(encodingError)
            }
        })
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
