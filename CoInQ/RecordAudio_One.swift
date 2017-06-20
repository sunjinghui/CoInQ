//
//  RecordAudio_OneTwo.swift
//  CoInQ
//
//  Created by hui on 2017/5/24.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import UIKit
import AVFoundation

class RecordAudio_One: UIViewController , AudioRecorderViewControllerDelegate {
    
    @IBOutlet weak var videoPreviewLayer: UIView!
    
    var player: AVPlayer!
    var avpController = AVPlayerViewController!()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let moviePath = UserDefaults.standard.url(forKey: "VideoOne")
        if let path = moviePath{
            let url = URL.fileURLWithPath(path)
            let item = AVPlayerItem(URL: url)
            self.player = AVPlayer(playerItem: item)
            self.avpController = AVPlayerViewController()
            self.avpController.player = self.player
            avpController.view.frame = videoPreviewLayer.frame
            self.addChildViewController(avpController)
            self.view.addSubview(avpController.view)
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func RecordeOne(_ sender: AnyObject) {
        
        let controller = AudioRecorderViewController()
        controller.audioRecorderDelegate = self
        present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func RecordeTwo(_ sender: AnyObject) {
        
        let controller = AudioRecorderViewController()
        controller.audioRecorderDelegate = self
        present(controller, animated: true, completion: nil)
        
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
