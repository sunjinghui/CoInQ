//
//  SelectVideoUpload_Five_Six.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import MobileCoreServices
import MediaPlayer
import CoreData

class SelectVideoUpload_Five_Six : UIViewController{
    
    var loadingAssetOne = false
    var AssetFive:URL!
    var AssetSix: URL!
    var VideoNameArray = [VideoTaskInfo]()
    var managedObjextContext: NSManagedObjectContext!
    
    @IBOutlet weak var fivecomplete: UIImageView!
    @IBOutlet weak var sixcomplete: UIImageView!
    
    @IBAction func ExplainFive(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小解釋",message:"便條紙是一個適合用來\n分類與比較證據的小工具喔！",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func ExplainSix(_ sender: Any) {
        let myAlert: UIAlertController = UIAlertController(title:"小解釋",message:"文字、聲音、影片都是適合紀錄可能原因的方式。",preferredStyle: .alert)
        let action = UIAlertAction(title:"知道了",style: UIAlertActionStyle.default,handler:{action in print("done")})
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fivecomplete.isHidden = true
        sixcomplete.isHidden = true
        managedObjextContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        loadData()
    }
    
    func loadData() {
        let videotaskRequest: NSFetchRequest<VideoTaskInfo> = VideoTaskInfo.fetchRequest()
        do {
            VideoNameArray = try managedObjextContext.fetch(videotaskRequest)
            
            if (VideoNameArray[Index].videofive) != nil {
                print("video5 is not empty")
                self.AssetFive = URL(string: VideoNameArray[Index].videofive!)
                fivecomplete.isHidden = false
            }
            
            if (VideoNameArray[Index].videosix) != nil{
                print("video6 is not empty")
                self.AssetSix = URL(string: VideoNameArray[Index].videosix!)
                sixcomplete.isHidden = false
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
    
    @IBAction func loadAssetFive(_ sender: AnyObject) {
        
        if savedPhotosAvailable() {
            loadingAssetOne = true
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
    
    
    @IBAction func loadAssetSix(_ sender: AnyObject) {
        if savedPhotosAvailable() {
            loadingAssetOne = false
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
}


// MARK: - UIImagePickerControllerDelegate
extension SelectVideoUpload_Five_Six : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        if mediaType == kUTTypeMovie {
            let avAsset = info[UIImagePickerControllerMediaURL] as! URL
            var message = ""
            if loadingAssetOne {
                message = "故事版5 影片已匯入成功！"
                AssetFive = avAsset
                fivecomplete.isHidden = false
                VideoNameArray[Index].videofive = AssetFive?.absoluteString

            } else {
                message = "故事版6 影片已匯入成功！"
                AssetSix = avAsset
                sixcomplete.isHidden = false
                VideoNameArray[Index].videosix = AssetSix?.absoluteString

            }
            let alert = UIAlertController(title: "太棒了", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
            //Store videopath in userdefault
            //let userdefault = UserDefaults.standard
            //userdefault.set(AssetFive, forKey: "VideoFive")
            //userdefault.set(AssetSix, forKey: "VideoSix")
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension SelectVideoUpload_Five_Six : UINavigationControllerDelegate {
}

