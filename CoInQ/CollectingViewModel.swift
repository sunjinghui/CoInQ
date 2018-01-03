//
//  CollectingViewModel.swift
//  CoInQ
//
//  Created by hui on 2017/12/25.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import UIKit

enum ProfileViewModelItemType {
    case clips
    case invite
}

protocol ProfileViewModelItem {
    var type: ProfileViewModelItemType { get }
    var sectionTitle: String { get }
    var rowCount: Int { get }
}

func jsonToData (_ jsonDic: NSDictionary) -> Data? {
    if(!JSONSerialization.isValidJSONObject(jsonDic)) {
        print("is not a valid json object")
        return nil
    }
    
    let data = try? JSONSerialization.data(withJSONObject: jsonDic, options: [])
    
    return data
}

class ProfileViewModel: NSObject {
    var items = [ProfileViewModelItem]()
    
    override init() {
        super.init()
        dataFromServer(){ responseObject, error in
            guard let data = jsonToData(responseObject!), let profile = Profile(data: data) else {
                return
            }
            
            let invites = profile.invite
            if !invites.isEmpty {
                let InviteItem = ProfileViewModeInviteItem(invites: invites)
                self.items.append(InviteItem)
            }
            
            let clips = profile.clips
            if !clips.isEmpty {
                print("clips is not empty")
                let ClipsItem = ProfileViewModeClipsItem(clip: clips)
                self.items.append(ClipsItem)
            }
        }
    }
}

extension ProfileViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        switch item.type {
        case .clips:
            if let item = item as? ProfileViewModeClipsItem, let cell = tableView.dequeueReusableCell(withIdentifier: ClipsCell.identifier, for: indexPath) as? ClipsCell {
                let video = item.clips[indexPath.row]
                cell.item = video
                return cell
            }
        case .invite:
            if let item = item as? ProfileViewModeInviteItem, let cell = tableView.dequeueReusableCell(withIdentifier: InviteCell.identifier, for: indexPath) as? InviteCell {
                cell.item = item.invites[indexPath.row]
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section].sectionTitle
    }
}

class ProfileViewModeInviteItem: ProfileViewModelItem {
    var type: ProfileViewModelItemType {
        return .invite
    }
    
    var sectionTitle: String {
        return "邀請"
    }
    
    var rowCount: Int {
        return invites.count
    }
    
    var invites: [Invite]
    
    init(invites: [Invite]) {
        self.invites = invites
    }
}

class ProfileViewModeClipsItem: ProfileViewModelItem {
    var type: ProfileViewModelItemType {
        return .clips
    }
    
    var sectionTitle: String {
        return "資料"
    }
    
    var rowCount: Int {
        return clips.count
    }
    
    var clips: [Clips]
    
    init(clip: [Clips]) {
        self.clips = clip
    }
}
