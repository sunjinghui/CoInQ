//
//  Helper_VC.swift
//  CoInQ
//
//  Created by hui on 2017/9/7.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation

class Helper_VC: UIViewController {
    
    @IBOutlet weak var HelpfultextView: UIView!
    
    @IBOutlet weak var Helpfultext: UILabel!
    @IBOutlet weak var stageone: UIButton!
    @IBOutlet weak var stagetwo: UIButton!
    @IBOutlet weak var stagethree: UIButton!
    @IBOutlet weak var stagefour: UIButton!
    @IBOutlet weak var stagefive: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lognote("ghp", google_userid, "\(Index)")
        HelpfultextView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func orignal() {
        if stageone.isSelected == false {
            stageone.setImage(#imageLiteral(resourceName: "circle1"), for: UIControlState())
        }
        if stagetwo.isSelected == false {
            stagetwo.setImage(#imageLiteral(resourceName: "circle2"), for: UIControlState())
        }
        if stagethree.isSelected == false {
            stagethree.setImage(#imageLiteral(resourceName: "circle3"), for: UIControlState())
        }
        if stagefour.isSelected == false {
            stagefour.setImage(#imageLiteral(resourceName: "circle4"), for: UIControlState())
        }
        if stagefive.isSelected == false {
            stagefive.setImage(#imageLiteral(resourceName: "circle5"), for: UIControlState())
        }
    }
    
    @IBAction func StageOne(_ sender: Any) {
        orignal()
        if HelpfultextView.isHidden == true {
            HelpfultextView.isHidden = false
        }
        Helpfultext.text = "從界定問題開始"
        stageone.setImage(#imageLiteral(resourceName: "circle1_1"), for: UIControlState())
        lognote("hdp",google_userid,"\(Index)")
    }
    
    @IBAction func StageTwo(_ sender: Any) {
        orignal()
        if HelpfultextView.isHidden == true {
         HelpfultextView.isHidden = false
        }
        Helpfultext.text = "設計實驗\n蒐集「證據」"
        stagetwo.setImage(#imageLiteral(resourceName: "circle2_1"), for: UIControlState())
        lognote("hcd",google_userid,"\(Index)")
    }
    
    @IBAction func StageThree(_ sender: Any) {
        orignal()
        if HelpfultextView.isHidden == true {
            HelpfultextView.isHidden = false
        }
        Helpfultext.text = "分析「證據」\n試著解讀"
        stagethree.setImage(#imageLiteral(resourceName: "circle3_1"), for: UIControlState())
        lognote("hme",google_userid,"\(Index)")
    }
    
    @IBAction func StageFour(_ sender: Any) {
        orignal()
        if HelpfultextView.isHidden == true {
            HelpfultextView.isHidden = false
        }
        Helpfultext.text = "提出科學的\n有邏輯的\n不自相矛盾的解釋"
        stagefour.setImage(#imageLiteral(resourceName: "circle4_1"), for: UIControlState())
        lognote("hee",google_userid,"\(Index)")
    }
    
    @IBAction func StageFive(_ sender: Any) {
        orignal()
        if HelpfultextView.isHidden == true {
            HelpfultextView.isHidden = false
        }
        Helpfultext.text = "與他人分享結果\n激發多新想法\n與新問題"
        stagefive.setImage(#imageLiteral(resourceName: "circle5_1"), for: UIControlState())
        lognote("hsr",google_userid,"\(Index)")
    }
    
/*    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_one" {
            segue.destination.popoverPresentationController?.sourceRect = (sender as! UIView).bounds
            segue.destination.popoverPresentationController?.delegate = self
        }
    }*/
    
}
