//
//  RecordAudio_OneTwo.swift
//  CoInQ
//
//  Created by hui on 2017/5/24.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import UIKit
import AVFoundation

class RecordAudio_OneTwo: UIViewController , AVAudioRecorderDelegate {
    
    var audio1: AVAsset?
    var audio2: AVAsset?
    
    var recOne: AVAudioRecorder?

    @IBOutlet weak var storyboard1: UIImageView!
    @IBOutlet weak var storyboard2: UIImageView!
    
    @IBAction func recordOne(_ sender: Any) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        
        let audioUrl = try docsDirect.appendingPathComponent("audioFileName.m4a")
        
        //1. create the session
        let session = AVAudioSession.sharedInstance()
        
        do {
            // 2. configure the session for recording and playback
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try session.setActive(true)
            // 3. set up a high-quality recording session
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            // 4. create the audio recording, and assign ourselves as the delegate
            recOne = try AVAudioRecorder(url: audioFileURL, settings: settings)
            recOne?.delegate = self
            recOne?.record()
        } 
        catch let error {
            print("Failed to record!")
        }
        
    }
    
    @IBAction func recordTwo(_ sender: Any) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
