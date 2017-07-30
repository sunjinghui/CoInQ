//
//  CompeleteViewController.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import CoreData

class CompeleteViewController : UIViewController{//, UITableViewDelegate, UITableViewDataSource{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var VideoNameTableView: UITableView!
    @IBOutlet weak var TableEmpty: UIView!
    
    
/*    var VideoNameArray = [VideoTaskInfo]()
    var managedObjextContext: NSManagedObjectContext!
    
    // Table View Data Source
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VideoNameArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: TableView_cellvideotask
        
        cell = tableView.dequeueReusableCell(withIdentifier: "cellvideotask", for: indexPath) as! TableView_cellvideotask
        let VideoNamearray = VideoNameArray[indexPath.row]
        cell.VideoName.text = VideoNamearray.videoname
        cell.Date.text = VideoNamearray.creatdate
        
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        
        if editingStyle == .delete {
            
            let deleteAlert = UIAlertController(title:"確定要刪除影片嗎？",message: "刪除影片任務後無法復原！", preferredStyle: .alert)
            deleteAlert.addAction(UIAlertAction(title:"確定",style: .default, handler:{ (action) -> Void in
                self.managedObjextContext.delete(self.VideoNameArray[indexPath.row])
                self.VideoNameArray.remove(at: indexPath.row)
                self.loadData()
            }))
            let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
            deleteAlert.addAction(cancelAction)
            self.present(deleteAlert, animated: true, completion: nil)
            
            /*tableView.beginUpdates()
             tableView.deleteRows(at: [indexPath], with: .automatic)
             tableView.endUpdates()*/
            
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Index = indexPath.row
        self.performSegue(withIdentifier: "startvideotask", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AddButton.layer.cornerRadius = 8
        VideoNameTableView.tableFooterView = UIView(frame: .zero)
        
        managedObjextContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        loadData()
    }
    
    func loadData() {
        let videotaskRequest: NSFetchRequest<VideoTaskInfo> = VideoTaskInfo.fetchRequest()
        do {
            VideoNameArray = try managedObjextContext.fetch(videotaskRequest)
            self.VideoNameTableView.reloadData()
        }catch {
            print("Could not load data from coredb \(error.localizedDescription)")
        }
        if VideoNameArray.count == 0 {
            VideoNameTableView.backgroundView = TableEmpty
        }else{
            VideoNameTableView.backgroundView = nil
        }
        
    }*/

}
