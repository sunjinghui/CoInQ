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
    
    var soundRecorder : AVAudioRecorder!
    var SoundPlayer : AVAudioPlayer!
    
    var timeTimer: Timer?
    var milliseconds: Int = 0
    
    var AudioFileName = "sound.m4a"
    
    
    let recordSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0) as Float),
                          AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC) as Int32),
                          AVNumberOfChannelsKey : NSNumber(value: 1 as Int32),
                          AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue) as Int32)]
    
    
    @IBAction func BackToSelectVideoNine(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        /*let SelectVideoVC = storyboard?.instantiateViewController(withIdentifier: "VideoTaskViewController") as! VideoTaskViewController
        
        present(SelectVideoVC, animated: true, completion: nil)*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        
        setupRecorder()

        
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
    }
    
    @IBAction func Explain(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小解釋",message:"我可以說明\n這個自然現象中特別值得注意的重點。",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func play(){
        let Player = AVPlayer(url: UserDefaults.standard.url(forKey: "VideoOne")!)
        let controller = AVPlayerViewController()
        controller.player = Player
        controller.showsPlaybackControls = false
        self.addChildViewController(controller)
        let videoFrame = CGRect(x: 44, y: 262, width: 681, height: 462)
        controller.view.frame = videoFrame
        self.view.addSubview(controller.view)
        Player.volume = 0.0
        Player.play()
    }
    
    @IBAction func record(_ sender: AnyObject) {
        
        if sender.titleLabel?!.text == "錄音"{
            
            soundRecorder.record()
            sender.setTitle("Stop", for: UIControlState())
            ButtonPlay.isEnabled = false
            play()

        }
        else{
            
            soundRecorder.stop()
            sender.setTitle("錄音", for: UIControlState())
            ButtonPlay.isEnabled = true
        }

        /*let controller = AudioRecorderViewController()
        controller.audioRecorderDelegate = self
        present(controller, animated: true, completion: nil)*/
        
    }
    
    @IBAction func playvideo(_ sender: AnyObject) {
        
        if sender.titleLabel?!.text == "Play" {
            
            ButttonRecord.isEnabled = false
            sender.setTitle("Stop", for: UIControlState())
            
            preparePlayer()
            SoundPlayer.play()
            play()

        }
        else{
            
            SoundPlayer.stop()
            sender.setTitle("Play", for: UIControlState())
            
        }
    }
    
    //HELPERS
    
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
        ButtonPlay.isEnabled = false

        //ask for permission
        if (audioSession.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("granted")
                    
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
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        ButttonRecord.isEnabled = true
        ButtonPlay.setTitle("Play", for: UIControlState())
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
