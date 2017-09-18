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
    }
    
    @IBAction func StageTwo(_ sender: Any) {
        orignal()
        if HelpfultextView.isHidden == true {
         HelpfultextView.isHidden = false
        }
        Helpfultext.text = "能夠確實回答問題\n的「資料」\n稱為「證據」。"
        stagetwo.setImage(#imageLiteral(resourceName: "circle2_1"), for: UIControlState())
    }
    
    @IBAction func StageThree(_ sender: Any) {
        orignal()
        if HelpfultextView.isHidden == true {
            HelpfultextView.isHidden = false
        }
        Helpfultext.text = "分析、比較「證據」\n便能得出可能的解釋。"
        stagethree.setImage(#imageLiteral(resourceName: "circle3_1"), for: UIControlState())
    }
    
    @IBAction func StageFour(_ sender: Any) {
        orignal()
        if HelpfultextView.isHidden == true {
            HelpfultextView.isHidden = false
        }
        Helpfultext.text = "最終解釋應\n符合科學、邏輯\n的標準。"
        stagefour.setImage(#imageLiteral(resourceName: "circle4_1"), for: UIControlState())
    }
    
    @IBAction func StageFive(_ sender: Any) {
        orignal()
        if HelpfultextView.isHidden == true {
            HelpfultextView.isHidden = false
        }
        Helpfultext.text = "積極分享是勇氣，\n願意回饋是美德。"
        stagefive.setImage(#imageLiteral(resourceName: "circle5_1"), for: UIControlState())
    }
    
/*    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_one" {
            segue.destination.popoverPresentationController?.sourceRect = (sender as! UIView).bounds
            segue.destination.popoverPresentationController?.delegate = self
        }
    }*/
    
}
