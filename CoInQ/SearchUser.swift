//
//  SearchUser.swift
//  CoInQ
//
//  Created by hui on 2018/3/7.
//  Copyright © 2018年 NTNUCSCL. All rights reserved.
//

import Foundation
import Alamofire

class SearchUser : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate , UITextFieldDelegate {
    
    var userArray: [Any]?
    var data = [String]()
    var filteredata = [String]()
    var isSearching = false
    var email : String!

    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var tableview : UITableView!
    @IBOutlet weak var searchbar : UISearchBar!
    
    @IBAction func backtoStage(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        tableview.dataSource = self
        searchbar.delegate = self
        searchbar.returnKeyType = UIReturnKeyType.done
        tableview.tableFooterView = UIView(frame: .zero)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getUserInfo), for: UIControlEvents.valueChanged)
        tableview.addSubview(refreshControl)
        
        getUserInfo()
        
//        for vc in (self.navigationController?.viewControllers ?? []) {
//            print(vc)
//        }
    }
    
    func getUserInfo() {
        
        let parameters: Parameters=["google_userid": google_userid]
        Alamofire.request("http://140.122.76.201/CoInQ/v1/getuserinfo.php", method: .post, parameters: parameters).responseJSON
            {
                response in
                
                guard response.result.isSuccess else {
                    let errorMessage = response.result.error?.localizedDescription
                    print("load user info \(errorMessage!)")
                    return
                }
                guard let JSON = response.result.value as? [String: Any] else {
                    print("JSON formate error")
                    return
                }
                // 2.
                let error = JSON["error"] as! Bool
                if error {
                    self.data = []
                    self.tableview.reloadData()
                    self.refreshControl.endRefreshing()

                } else if let userinfo = JSON["table"] as? [Any] {
                    self.userArray = userinfo
                    self.data = []
                    for each in self.userArray!{
                        let email = each as? [String: Any]
                        let text = email?["email"] as? String
                        self.data.append(text!)
                    }
                    
                    self.tableview.reloadData()
                    self.refreshControl.endRefreshing()
                }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredata.count
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alertController = UIAlertController(title:"影片共創邀請",message: nil, preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: {(textField) -> Void in
            textField.delegate = self
            textField.placeholder = "請輸入需要的影片資料特點"
        })

        if isSearching{
            email = self.filteredata[indexPath.row]
        }else{
            email = self.data[indexPath.row]
        }
        let StartVideoTask = UIAlertAction(title:"寄送共創邀請", style: .default, handler:{
            (action) -> Void in
            let Invitetext = alertController.textFields?.first?.text
            if !(Invitetext?.isEmpty)! {
                //UPLOAD VideoTask
                let parameters: Parameters=[
                    "google_userid_FROM": google_userid,
                    "videoid": Index,
                    "email":   self.email.description,
                    "context":    Invitetext!,
                    ]
                
                //Sending http post request
                Alamofire.request("http://140.122.76.201/CoInQ/v1/collaboration.php", method: .post, parameters: parameters).responseJSON
                    {
                        response in
                        if response.result.isSuccess{
                            NotificationCenter.default.post(name: NSNotification.Name("CoStage"), object: nil)
                            self.dismiss(animated: true, completion: nil)
                            //                lognote("nvt", google_userid, Invitetext!)
                        }
                        //                    if let result = response.result.value {
                        //                        let jsonData = result as! NSDictionary
                        //
                        //                        //self.labelMessage.text = jsonData.value(forKey: "message") as! String?
                        //                        print(jsonData.value(forKey: "message") as Any)
                        //                    }
                }
                
            }else{
                let errorAlert = UIAlertController(title:"請注意",message: "儘量描述清楚需要的影片資料\n對影片創作更有幫助", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title:"OK",style: .cancel, handler:{ (action) -> Void in self.present(alertController, animated: true, completion: nil)}))
                self.present(errorAlert, animated: true, completion: nil)
            }
            
        })
        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler: nil)
        
        alertController.addAction(StartVideoTask)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cellsearchuser", for: indexPath) as? TableView_cellsearchuser{
            let text : String!
            
//            guard let userinfo = userArray?[indexPath.row] as? [String: Any] else {
//                print("Get row \(indexPath.row) error")
//                return cell
//            }
            
            if isSearching {
                text = filteredata[indexPath.row]
            }else{
                text = data[indexPath.row]
            }
            
            cell.configureCell(text: text)
            return cell
        }else{
            return UITableViewCell()
        }

//        cell.videoname.text = finalvideo["videoname"] as? String
//        cell.videolength.text = finalvideo["videolength"] as? String
//        let finalvideoURL = finalvideo["finalvideopath"] as? String
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchbar.text == nil || searchbar.text == "" {
            isSearching = false
            view.endEditing(true)
            tableview.reloadData()
        }else{
            isSearching = true
            filteredata = data.filter({ (country) -> Bool in
                let countryText : NSString = country as NSString
                return (countryText.range(of: searchbar.text! , options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
            })
//                $0 == searchbar.text})
            tableview.reloadData()
        }
    }
    
}
