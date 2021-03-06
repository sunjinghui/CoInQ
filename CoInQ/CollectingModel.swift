//
//  CollectingModel.swift
//  CoInQ
//
//  Created by hui on 2017/12/25.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import Alamofire
import AVFoundation

//public func dataFromServer(completion: @escaping (NSDictionary?, Error?) -> ()) {
//    
//    let parameters: Parameters=["google_userid": google_userid,"videoid":Index]
//    Alamofire.request("http://140.122.76.201/CoInQ/v1/getCollectingclips.php", method: .post, parameters: parameters).responseJSON
//        {
//            response in
//            switch response.result {
//            case .success(let videoclips):
//                completion(videoclips as? NSDictionary, nil)
//            case .failure(let error):
//                print(error)
//                completion(nil,error)
//            }
//    }
//    
//}

public func dataFromFile(_ filename: String) -> Data? {
    @objc class TestClass: NSObject { }
    
    let bundle = Bundle(for: TestClass.self)
    if let path = bundle.path(forResource: filename, ofType: "json") {
        return (try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
    return nil
}

class Profile {
    var clips = [Clips]()
    var invite = [Invite]()
    
    init?(data: Data) {
        do {
            if let body = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("body: \(body)")
                if let clip = body["friends"] as? [[String: Any]] {
                    print("clips: \(clip)")
                    self.clips = clip.map { Clips(json: $0) }
                }
                
                if let invite = body["invite"] as? [[String: Any]] {
                    self.invite = invite.map { Invite(json: $0) }
                }
            }
        } catch {
            print("Error deserializing JSON: \(error)")
            return nil
        }
    }
}

class Clips {
    var name: String?
    var pictureUrl: UIImage?
    var time: String?
    
    init(json: [String: Any]) {
        self.name = json["username"] as? String
        self.pictureUrl = UIImage(named: "playvideo")
//        self.pictureUrl = json["videopath"] as? String
        self.time = json["time"] as? String
    }
}

class Invite {
    var name: String?
    var img: String?
    var context: String?
    var time: String?
    
    init(json: [String: Any]) {
        self.name = json["username"] as? String
        self.img = json["videopath"] as? String
        self.context = json["context"] as? String
        self.time = json["time"] as? String
    }
}
