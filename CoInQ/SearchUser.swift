//
//  SearchUser.swift
//  CoInQ
//
//  Created by hui on 2018/3/7.
//  Copyright © 2018年 NTNUCSCL. All rights reserved.
//

import Foundation
import Alamofire

class SearchUser : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var userArray: [Any]?
    var data = [String]()
    var filteredata = [String]()
    var isSearching = false
    
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
        getUserInfo()
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
                    
                } else if let userinfo = JSON["table"] as? [Any] {
                    self.userArray = userinfo
                    
                    for each in self.userArray!{
                        let email = each as? [String: Any]
                        let text = email?["email"] as? String
                        self.data.append(text!)
                    }
                    
                    self.tableview.reloadData()
                }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredata.count
        }
        return data.count
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
            filteredata = data.filter({$0 == searchbar.text})
            tableview.reloadData()
        }
    }
    
}
