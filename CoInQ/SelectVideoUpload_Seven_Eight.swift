//
//  SelectVideoUpload_Seven_Eight.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import MobileCoreServices
import MediaPlayer

class SelectVideoUpload_Seven_Eight : UIViewController{
    
    var loadingAssetOne = false
    var AssetSeven: URL!
    var AssetEight: URL!
    
    @IBOutlet weak var sevencomplete: UIImageView!
    @IBOutlet weak var eightcomplete: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sevencomplete.isHidden = true
        eightcomplete.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ExplainSeven(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小解釋",message:"仔細觀察和紀錄\n科學家使用的科學方法與研究結果吧！",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func ExplainEight(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小解釋",message:"試試看加入科學家提出的科學術語，\n讓我的解釋看起來更專業！",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
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
    
    @IBAction func loadAssetSeven(_ sender: AnyObject) {
        
        if savedPhotosAvailable() {
            loadingAssetOne = true
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
    
    
    @IBAction func loadAssetEight(_ sender: AnyObject) {
        if savedPhotosAvailable() {
            loadingAssetOne = false
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
}


// MARK: - UIImagePickerControllerDelegate
extension SelectVideoUpload_Seven_Eight : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        if mediaType == kUTTypeMovie {
            let avAsset = info[UIImagePickerControllerMediaURL] as! URL
            var message = ""
            if loadingAssetOne {
                message = "故事版7 影片已匯入成功！"
                AssetSeven = avAsset
                sevencomplete.isHidden = false
            } else {
                message = "故事版8 影片已匯入成功！"
                AssetEight = avAsset
                eightcomplete.isHidden = false
            }
            let alert = UIAlertController(title: "太棒了", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
            //Store videopath in userdefault
            let userdefault = UserDefaults.standard
            userdefault.set(AssetSeven, forKey: "VideoSeven")
            userdefault.set(AssetEight, forKey: "VideoEight")
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension SelectVideoUpload_Seven_Eight : UINavigationControllerDelegate {
}

