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
        Helpfultext.text = "科學探究皆從\n一個問題開始。"
        stageone.setImage(#imageLiteral(resourceName: "circle1_1"), for: UIControlState())
        lognote("hdp",google_userid,"\(Index)")
    }
    
    @IBAction func StageTwo(_ sender: Any) {
        orignal()
        if HelpfultextView.isHidden == true {
         HelpfultextView.isHidden = false
        }
        Helpfultext.text = "蒐集能夠確實回答問題的「資料」\n這「資料」也就是 「證據」。"
        stagetwo.setImage(#imageLiteral(resourceName: "circle2_1"), for: UIControlState())
        lognote("hcd",google_userid,"\(Index)")
    }
    
    @IBAction func StageThree(_ sender: Any) {
        orignal()
        if HelpfultextView.isHidden == true {
            HelpfultextView.isHidden = false
        }
        Helpfultext.text = "分析「證據」便能得出可能的解釋。"
        stagethree.setImage(#imageLiteral(resourceName: "circle3_1"), for: UIControlState())
        lognote("hme",google_userid,"\(Index)")
    }
    
    @IBAction func StageFour(_ sender: Any) {
        orignal()
        if HelpfultextView.isHidden == true {
            HelpfultextView.isHidden = false
        }
        Helpfultext.text = "最終的解釋應該是\n科學的、有邏輯的。"
        stagefour.setImage(#imageLiteral(resourceName: "circle4_1"), for: UIControlState())
        lognote("hee",google_userid,"\(Index)")
    }
    
    @IBAction func StageFive(_ sender: Any) {
        orignal()
        if HelpfultextView.isHidden == true {
            HelpfultextView.isHidden = false
        }
        Helpfultext.text = "與他人分享我的解釋\n會激發更多新想法與新問題。"
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
