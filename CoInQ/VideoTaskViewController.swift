//
//  VideoTask.swift
//  CoInQ
//
//  Created by hui on 2017/5/12.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import CoreData

class VideoTaskViewController:UITabBarController{

//    var VideoNameArray = [VideoTaskInfo]()
//    var managedObjextContext: NSManagedObjectContext!

    @IBAction func GoBack(){
        lognote("bhp", google_userid, "\(Index)")
            _ = self.navigationController?.popViewController(animated: true)
    }
    
//    func isURLempty(_ key: String) -> Bool{
//        return UserDefaults.standard.object(forKey: key) != nil
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if UserDefaults.standard.string(forKey: "VideotaskTitle") != nil{
//            self.title = UserDefaults.standard.string(forKey: "VideotaskTitle")
//        }
        
        //UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 20)], for: .normal)
        
//        managedObjextContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        
//        loadData()
    }
    
//    func loadData() {
//        let videotaskRequest: NSFetchRequest<VideoTaskInfo> = VideoTaskInfo.fetchRequest()
//        do {
//            VideoNameArray = try managedObjextContext.fetch(videotaskRequest)
//            self.title = VideoNameArray[Index].videoname
//
//        }catch {
//            print("Could not load data from coredb \(error.localizedDescription)")
//        }
//    }

}
