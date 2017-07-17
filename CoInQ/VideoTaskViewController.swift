//
//  VideoTask.swift
//  CoInQ
//
//  Created by hui on 2017/5/12.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation

class VideoTaskViewController:UITabBarController{

    var videoname = VideoTaskInfo()
    var VideoNameArray = [VideoTaskInfo]()
    
    @IBAction func GoBack(){
            _ = self.navigationController?.popViewController(animated: true)
    }
    
    func isURLempty(_ key: String) -> Bool{
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func clearUD(){
        if isURLempty("VideoOne") || isURLempty("VideoTwo") || isURLempty("VideoThree") || isURLempty("VideoFour") || isURLempty("VideoFive") || isURLempty("VideoSix") || isURLempty("VideoSeven") || isURLempty("VideoEight") || isURLempty("VideoNine") {
            UserDefaults.standard.removeObject(forKey: "VideoOne")
            UserDefaults.standard.removeObject(forKey: "VideoTwo")
            UserDefaults.standard.removeObject(forKey: "VideoThree")
            UserDefaults.standard.removeObject(forKey: "VideoFour")
            UserDefaults.standard.removeObject(forKey: "VideoFive")
            UserDefaults.standard.removeObject(forKey: "VideoSix")
            UserDefaults.standard.removeObject(forKey: "VideoSeven")
            UserDefaults.standard.removeObject(forKey: "VideoEight")
            UserDefaults.standard.removeObject(forKey: "VideoNine")

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("array \(VideoNameArray)")
        print(videoname)
        if VideoNameArray.endIndex == 0 {
            print("Userdefault\(Index)")
            self.title = UserDefaults.standard.string(forKey: "VideoTaskName")
        }else{
            print("Got in Index \(Index)")
            let videotaskarray = VideoNameArray[Index]
            self.title = videotaskarray.VideoName
        }
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 20)], for: .normal)
        //clearUD()
        
    }

}
