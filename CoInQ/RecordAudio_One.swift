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

class RecordAudio_One: UIViewController , AudioRecorderViewControllerDelegate {
    
    @IBOutlet weak var videoPreviewLayer: UIImageView!
    
    
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
    
    @IBAction func record(_ sender: Any) {
        
        let Player = AVPlayer(url: UserDefaults.standard.url(forKey: "VideoOne")!)
        let controller = AVPlayerViewController()
        controller.player = Player
        controller.showsPlaybackControls = false
        self.addChildViewController(controller)
        let videoFrame = CGRect(x: 44, y: 262, width: 681, height: 462)
        controller.view.frame = videoFrame
        self.view.addSubview(controller.view)
        Player.play()
        /*let controller = AudioRecorderViewController()
        controller.audioRecorderDelegate = self
        present(controller, animated: true, completion: nil)*/
        
    }
    
    @IBAction func playvideo(_ sender: Any) {
    }
    
    func audioRecorderViewControllerDismissed(withFileURL fileURL: URL?) {
        print(fileURL!)
        // do something with fileURL
        dismiss(animated: true, completion: nil)
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
