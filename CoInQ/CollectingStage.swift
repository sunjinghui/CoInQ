//
//  CollectingStage.swift
//  CoInQ
//
//  Created by hui on 2017/12/18.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import MediaPlayer
import Alamofire
import MobileCoreServices
import SwiftyJSON

class CollectingStage :  UIViewController//, UITableViewDelegate, UITableViewDataSource {
{
    @IBOutlet weak var tableview : UITableView!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    fileprivate let viewModel = ProfileViewModel()
//    var collection = [Collection()]
//    var clips: [Any]?

//    var invite = ["Paris", "Rome"]
//    var searchable = [Searchable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        tableview.delegate = self
        tableview?.dataSource = viewModel
        tableview?.estimatedRowHeight = 100
        tableview?.rowHeight = UITableViewAutomaticDimension
        tableview.tableFooterView = UIView(frame: .zero)
        tableview?.register(ClipsCell.nib, forCellReuseIdentifier: ClipsCell.identifier)
        tableview?.register(InviteCell.nib, forCellReuseIdentifier: InviteCell.identifier)
//        loaddata()
    }
    
//    func loaddata(){
//        let parameters: Parameters=["google_userid": google_userid,"videoid":Index]
//        Alamofire.request("http://140.122.76.201/CoInQ/v1/getCollectingclips.php", method: .post, parameters: parameters).responseJSON
//            {
//                response in
//                print(response)
//                guard response.result.isSuccess else {
//                    let errorMessage = response.result.error?.localizedDescription
//                    print("\(errorMessage!)")
//                    return
//                }
//                guard let JSON = response.result.value as? [String: Any] else {
//                    print("JSON formate error")
//                    return
//                }
//                // 2.
//                let error = JSON["error"] as! Bool
//                if error {
//                    self.clips = []
//                    self.tableview.reloadData()
//                    
//                } else if let Collecte = JSON["table"] as? [Any] {
//                    self.clips = Collecte
//                    print(self.clips)
//                    var collect = self.clips?[0] as? [String: Any]
//                    var tmp = Collection()
//                    self.collection[tmp.username] = collect?["username"] as? String
//                    self.collection.time = collect?["time"] as? String
//                    self.collection.clips_img = collect?["video_path"] as? String
////                    let username = collect?["username"] as? String
////                    self.username.append(username!)
////                    let videoURL = collect?["video_path"] as? String
////                    self.clipsURL.append(videoURL!)
////                    let time = collect?["time"] as? String
////                    self.time.append(time!)
//                    print(self.collection)
//                    self.tableview.reloadData()
//                }
//        }
//
//    }
    
    func uploadvideo(mp4Path : URL,message: String, clip: Int){
        
        Alamofire.upload(
            //同样采用post表单上传
            multipartFormData: { multipartFormData in
                
                multipartFormData.append(mp4Path, withName: "file")//, fileName: "123456.mp4", mimeType: "video/mp4")
                multipartFormData.append("\(Index)".data(using: String.Encoding.utf8, allowLossyConversion: false)!,withName: "videoid")
                multipartFormData.append(google_userid.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "google_userid")
                multipartFormData.append((mp4Path.absoluteString.data(using: String.Encoding.utf8, allowLossyConversion: false)!),withName: "videopath")
                multipartFormData.append("\(clip)".data(using: String.Encoding.utf8, allowLossyConversion: false)!,withName: "clip")
                //                for (key, val) in parameters {
                //                    multipartFormData.append(val.data(using: String.Encoding.utf8)!, withName: key)
                //                }
                
                //SERVER ADD
        },to: "http://140.122.76.201/CoInQ/v1/uploadvideo.php",
          encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                //json处理
                upload.responseJSON { response in
                    //解包
                    guard let result = response.result.value else { return }
                    //                    print("\(result)")
                    //须导入 swiftyJSON 第三方框架，否则报错
                    let success = JSON(result)["success"].int ?? -1
                    if success == 1 {
                        print("Upload Succes")
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title:"提示",message:message, preferredStyle: .alert)
                        let action2 = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action2)
                        self.present(alert , animated: true , completion: nil)
//                        self.loaddata()
                        lognote("u\(clip)s", google_userid, "\(Index)")
                    }else{
                        print("Upload Failed")
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title:"提示",message:"上傳失敗，請重新上傳", preferredStyle: .alert)
                        let action2 = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(action2)
                        self.present(alert , animated: true , completion: nil)
                        lognote("u\(clip)f", google_userid, "\(Index)")
                    }
                }
                //上传进度
                upload.uploadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                        print("Upload Progress: \(progress.fractionCompleted)")
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
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
        //        mediaUI.videoMaximumDuration = 30.0
        present(mediaUI, animated: true, completion: nil)
        return true
    }
    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    
    @IBAction func Addclips(_ sender: AnyObject) {
        if savedPhotosAvailable() {
            _ = startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return searchable.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        if searchable[indexPath.row].collection.username != nil{
//            // Display User Cell
//            let cell : TableView_cellcollection = tableview.dequeueReusableCell(withIdentifier: "collectioncell", for: indexPath) as! TableView_cellcollection
//
//            cell.username.text = searchable[indexPath.row].collection.username
//            cell.time.text = searchable[indexPath.row].collection.time
            //影片縮圖
//            let imgURL = searchable[indexPath.row].collection.clips_img
//            let videoURL = URL(string: imgURL!)
//            let asset = AVURLAsset(url: videoURL!, options: nil)
//            let imgGenerator = AVAssetImageGenerator(asset: asset)
//            imgGenerator.appliesPreferredTrackTransform = false
//            
//            do {
//                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
//                let thumbnail = UIImage(cgImage: cgImage)
//                
//                cell.thumbnail.image = thumbnail
//                
//            } catch let error {
//                print("*** Error generating thumbnail: \(error)")
//            }

//            return cell
//        }else{
//            // Display Place Cell
//            let cell : TableView_cellinvite = tableview.dequeueReusableCell(withIdentifier: "invitecell", for: indexPath) as! TableView_cellinvite
//            cell.username.text = searchable[indexPath.row].invitaion.username
//            cell.time.text = searchable[indexPath.row].invitaion.time
//            cell.invitedcontext.text = searchable[indexPath.row].invitaion.invitecontext
            //影片縮圖
//            let imgURL = searchable[indexPath.row].invitaion.google_userimg
//            let videoURL = imgURL!
//            let asset = AVURLAsset(url: videoURL, options: nil)
//            let imgGenerator = AVAssetImageGenerator(asset: asset)
//            imgGenerator.appliesPreferredTrackTransform = false
//            
//            do {
//                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
//                let thumbnail = UIImage(cgImage: cgImage)
//                
//                cell.google_userimg.image = thumbnail
//                
//            } catch let error {
//                print("*** Error generating thumbnail: \(error)")
//            }
            
//            return cell
//        }
//    }
//    
//    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
//        return true
//    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if searchable[indexPath.row].user.name != nil{
//            return 123
//        }else{
//            return 92
//        }
//    }
    
//    func populate_array(){
//        self.searchable.removeAll()
//        for (key,value) in collection{
//            var collections = Collection()
//            switch key{
//            case "time":
//                collections.time = value
//            break;
//            case "video_path":
//                collections.clips_img = value
//            break;
//            case "username":
//                collections.username = value
//            break;
//            default:
//                print("\(key): \(value)")
//            }
//            var element = Searchable()
//            element.collection.clips_img = collections.clips_img
//            element.collection.time = collections.time
//            element.collection.username = collections.username
//            self.searchable.append(element)
//            print(element)
//        }
//
//        for each in invite{
//            var invitation = Invite()
//            invitation.username = each
//            var element = Searchable()
//            element.invitaion = invitation
//            self.searchable.append(element)
//        }
//       
//            var invitation = Collection()
//        
//            var element = Searchable()
//            element.collection = invitation
//            self.searchable.append(element)
//        
//        print(searchable)
//        tableview.reloadData()
//    }
//
//    
//    class Collection {
//        var username : String?
//        var time: String?
//        var clips_img: String?
//        init(json: [String: Any]){
//            
//        }
//    }
    
//    class Invite {
//        var username : String?
//        var invitecontext: String?
//        var time: String?
//        var google_userimg: URL?
//    }
//    
//    class Searchable {
//        var invitaion = Invite()
//        var collection = Collection()
//    }

    func startActivityIndicator() {
        let screenSize: CGRect = UIScreen.main.bounds
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0,width: 100,height: 100))
        activityIndicator.frame = CGRect(x: 0,y: 0,width: screenSize.width,height: screenSize.height)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        
        // Change background color and alpha channel here
        activityIndicator.backgroundColor = UIColor.black
        activityIndicator.clipsToBounds = true
        activityIndicator.alpha = 0.5
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
}

extension CollectingStage : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        if mediaType == kUTTypeMovie {
            let avAsset = info[UIImagePickerControllerMediaURL] as! URL
            var message = ""
                message = "影片已匯入成功！"
                self.startActivityIndicator()
            let videoURL = avAsset
            uploadvideo(mp4Path: videoURL,message: message,clip:10)
            
            
        }
    }
}

extension CollectingStage : UINavigationControllerDelegate{
}
