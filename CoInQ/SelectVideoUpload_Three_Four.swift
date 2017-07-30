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
import CoreData

class SelectVideoUpload_Three_Four : UIViewController{
    
    var loadingAssetOne = false
    var AssetThree: URL!
    var AssetFour: URL!
    var VideoNameArray = [VideoTaskInfo]()
    var managedObjextContext: NSManagedObjectContext!
    
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
        managedObjextContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        loadData()
    }
    
    func loadData() {
        let videotaskRequest: NSFetchRequest<VideoTaskInfo> = VideoTaskInfo.fetchRequest()
        do {
            VideoNameArray = try managedObjextContext.fetch(videotaskRequest)
            
            if (VideoNameArray[Index].videothree) != nil {
                print("video3 is not empty")
                self.AssetThree = URL(string: VideoNameArray[Index].videothree!)
                threecomplete.isHidden = false
            }
            
            if (VideoNameArray[Index].videofour) != nil{
                print("video4 is not empty")
                self.AssetFour = URL(string: VideoNameArray[Index].videofour!)
                fourcomplete.isHidden = false
            }
        }catch {
            print("Could not load data from coredb \(error.localizedDescription)")
        }
        
        print(self.VideoNameArray[Index])
        
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
                AssetThree = avAsset
                threecomplete.isHidden = false
                VideoNameArray[Index].videothree = AssetThree?.absoluteString

            } else {
                message = "故事版4 影片已匯入成功！"
                AssetFour = avAsset
                fourcomplete.isHidden = false
                VideoNameArray[Index].videofour = AssetFour?.absoluteString

            }
            let alert = UIAlertController(title: "太棒了", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
            //Store videopath in userdefault
            //let userdefault = UserDefaults.standard
            //userdefault.set(AssetThree, forKey: "VideoThree")
            //userdefault.set(AssetFour, forKey: "VideoFour")
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension SelectVideoUpload_Three_Four : UINavigationControllerDelegate {
}

