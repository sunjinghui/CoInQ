//
//  SelectVideoUpload_Three_Four.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import MobileCoreServices
import MediaPlayer
import Alamofire

class SelectVideoUpload_Three_Four : UIViewController{
    
    var loadingAssetOne = false
    
    @IBOutlet weak var threecomplete: UIImageView!
    @IBOutlet weak var fourcomplete: UIImageView!
    
    @IBAction func ExplainThree(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小解釋",message:"心智圖是一個適合用來制定蒐集計畫的好工具。",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func ExplainFour(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小解釋",message:"團結力量大！\n我們可以邀請共創夥伴加入科學探究。",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        threecomplete.isHidden = true
        fourcomplete.isHidden = true
        loaddata()
    }
    
    func loaddata(){
        SelectVideoUpload_One_Two().getvideoinfo("videothree_path", self.threecomplete, "videofour_path", self.fourcomplete)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func savedPhotosAvailable() -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            let alert = UIAlertController(title: "Not Available", message: "No Saved Album found", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func startMediaBrowserFromViewController(_ viewController: UIViewController!, usingDelegate delegate : (UINavigationControllerDelegate & UIImagePickerControllerDelegate)!) -> Bool {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            return false
        }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .savedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
        present(mediaUI, animated: true, completion: nil)
        return true
    }
    
    @IBAction func loadAssetThree(_ sender: AnyObject) {
        
        if savedPhotosAvailable() {
            loadingAssetOne = true
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
    
    
    @IBAction func loadAssetFour(_ sender: AnyObject) {
        if savedPhotosAvailable() {
            loadingAssetOne = false
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
}


// MARK: - UIImagePickerControllerDelegate
extension SelectVideoUpload_Three_Four : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        if mediaType == kUTTypeMovie {
            let avAsset = info[UIImagePickerControllerMediaURL] as! URL
            var message = ""
            if loadingAssetOne {
                message = "故事版3 影片已匯入成功！"
                let videoURL = avAsset
                SelectVideoUpload_One_Two().uploadVideo(mp4Path: videoURL,message: message,clip:3,VC: self,check: self.threecomplete)
                loaddata()
            } else {
                message = "故事版4 影片已匯入成功！"
                let videoURL = avAsset
                SelectVideoUpload_One_Two().uploadVideo(mp4Path: videoURL,message: message,clip:4,VC: self,check: self.fourcomplete)
                loaddata()
            }
            
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension SelectVideoUpload_Three_Four : UINavigationControllerDelegate {
}

