//
//  SelectVideoUpload_1&2.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import MobileCoreServices
import MediaPlayer

class SelectVideoUpload_One_Two : UIViewController{
    
    var loadingAssetOne = false
    var firstAsset: URL!
    var secondAsset: URL!
    
    @IBOutlet weak var firstcomplete: UIImageView!
    @IBOutlet weak var secondcomplete: UIImageView!
    
    @IBAction func ExplainOne(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小解釋",message:"圖片與影片是記錄「自然現象」最佳的工具喔！",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func ExplainTwo(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小解釋",message:"例如：\n天空為什麼會出現彩虹？\n天空中的彩虹是如何形成的？",preferredStyle: .alert)
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
    
    
    @IBAction func loadAssetOne(_ sender: AnyObject) {
        
        if savedPhotosAvailable() {
            loadingAssetOne = true
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
    
    
    @IBAction func loadAssetTwo(_ sender: AnyObject) {
        if savedPhotosAvailable() {
            loadingAssetOne = false
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstcomplete.isHidden = true
        secondcomplete.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


// MARK: - UIImagePickerControllerDelegate
extension SelectVideoUpload_One_Two : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        if mediaType == kUTTypeMovie {
            let avAsset = info[UIImagePickerControllerMediaURL] as! URL
            var message = ""
            if loadingAssetOne {
                message = "故事版1 影片已匯入成功！"
                firstAsset = avAsset
                firstcomplete.isHidden = false
            } else {
                message = "故事版2 影片已匯入成功！"
                secondAsset = avAsset
                secondcomplete.isHidden = false
            }
            let alert = UIAlertController(title: "太棒了", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
            //Store videopath in userdefault
            let userdefault = UserDefaults.standard
            userdefault.set(firstAsset, forKey: "VideoOne")
            userdefault.set(secondAsset, forKey: "VideoTwo")
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension SelectVideoUpload_One_Two : UINavigationControllerDelegate {
}
