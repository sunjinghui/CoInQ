//
//  RecordAudio_Merge.swift
//  CoInQ
//
//  Created by hui on 2017/5/13.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation

class RecordAudio : UIViewController{


    @IBOutlet weak var SegmentedControl: UISegmentedControl!

    @IBOutlet weak var viewDefineQuestion: UIView!
    @IBOutlet weak var viewCollectData: UIView!
    @IBOutlet weak var viewExplanation: UIView!
    @IBOutlet weak var viewEvaluation: UIView!
    @IBOutlet weak var viewShare: UIView!
    
    @IBAction func SegmentedControlSelect(_ sender: UISegmentedControl) {
        switch SegmentedControl.selectedSegmentIndex{
        case 0:
            viewDefineQuestion.isHidden = false
            viewCollectData.isHidden = true
            viewExplanation.isHidden = true
            viewEvaluation.isHidden = true
            viewShare.isHidden = true
            
        case 1:
            viewDefineQuestion.isHidden = true
            viewCollectData.isHidden = false
            viewExplanation.isHidden = true
            viewEvaluation.isHidden = true
            viewShare.isHidden = true
            
        case 2:
            viewDefineQuestion.isHidden = true
            viewCollectData.isHidden = true
            viewExplanation.isHidden = false
            viewEvaluation.isHidden = true
            viewShare.isHidden = true
            
        case 3:
            viewDefineQuestion.isHidden = true
            viewCollectData.isHidden = true
            viewExplanation.isHidden = true
            viewEvaluation.isHidden = false
            viewShare.isHidden = true
            
        case 4:
            viewDefineQuestion.isHidden = true
            viewCollectData.isHidden = true
            viewExplanation.isHidden = true
            viewEvaluation.isHidden = true
            viewShare.isHidden = false
            
        default:
            break;
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewDefineQuestion.isHidden = false
        viewCollectData.isHidden = true
        viewExplanation.isHidden = true
        viewEvaluation.isHidden = true
        viewShare.isHidden = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
} //end of the class
