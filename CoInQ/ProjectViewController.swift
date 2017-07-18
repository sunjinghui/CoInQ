//
//  ProjectViewController.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import CoreData

var Index = 0

class ProjectViewController : UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var VideoNameTableView: UITableView!
    
    var VideoNameArray = [VideoTaskInfo]()
    var managedObjextContext: NSManagedObjectContext!
    
    // Table View Data Source
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("ArrayCount\(VideoNameArray.count)")
        return max(VideoNameArray.count,1)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: TableView_cellvideotask
    
        if VideoNameArray.count == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "nocellvideotask", for: indexPath) as! TableView_cellvideotask
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "cellvideotask", for: indexPath) as! TableView_cellvideotask
            let VideoNamearray = VideoNameArray[indexPath.row]
            cell.VideoName.text = VideoNamearray.videoname
            cell.Date.text = VideoNamearray.creatdate
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){


        if editingStyle == .delete && (VideoNameArray.count - 1) == 0 {
            VideoNameArray.remove(at: indexPath.row)
            tableView.reloadData()
        }else if editingStyle == .delete {
            managedObjextContext.delete(VideoNameArray[indexPath.row])
            VideoNameArray.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
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
    }
    
    
    @IBAction func AddVideoTask(_ sender: Any) {
        
        let videotaskitem = VideoTaskInfo(context: managedObjextContext)
        
        let alertController = UIAlertController(title:"探究影片名稱",message: nil, preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: {(textField) -> Void in
            textField.delegate = self
            textField.placeholder = "請輸入影片名稱"
        })
        
        // set the date
        let date = Date()
        let formater = DateFormatter()
        formater.dateFormat = "yyyy/MM/dd"
        let dateresult = formater.string(from: date)
        
        let StartVideoTask = UIAlertAction(title:"開始製作影片", style: .default, handler:{
            (action) -> Void in
            let VideoName = alertController.textFields?.first
            
            

            if VideoName?.text != ""{
                
                if self.VideoNameArray.count == 1 {
                    self.VideoNameTableView.reloadData()
                    self.performSegue(withIdentifier: "startvideotask", sender: self)

                }else{

                    videotaskitem.videoname = VideoName?.text
                    videotaskitem.creatdate = dateresult
                    
                    do {
                        try self.managedObjextContext.save()
                        self.loadData()
                    }catch {
                        print("Could not save data \(error.localizedDescription)")
                    }
                    
                    /*self.VideoNameTableView.beginUpdates()
                    self.VideoNameTableView.insertRows(at: [IndexPath(row: self.VideoNameArray.count, section: 0)], with: .automatic)
                    self.VideoNameTableView.endUpdates()*/
                    self.performSegue(withIdentifier: "startvideotask", sender: self)
                }
                print(self.VideoNameArray)
            }else{
                let errorAlert = UIAlertController(title:"請注意",message: "不能沒有探究影片名稱", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title:"OK",style: .cancel, handler:{ (action) -> Void in self.present(alertController, animated: true, completion: nil)}))
                self.present(errorAlert, animated: true, completion: nil)
            }

        })
        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)

        alertController.addAction(StartVideoTask)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)

    }
}
