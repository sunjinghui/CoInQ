//
//  Helper_page.swift
//  CoInQ
//
//  Created by hui on 2017/8/29.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import UIKit

class Helper_page: UIViewController, PageViewControllerDelegate {
    
    //页控件
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //场景切换
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageViewController = segue.destination as? Helper_pageVC {
            //设置委托（当页面数量、索引改变时当前视图控制器能触发页控件的改变）
            pageViewController.pageDelegate = self
        }
    }
    
    //当页面数量改变时调用
    func pageViewController(pageViewController: Helper_pageVC,
                            didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    //当前页索引改变时调用
    func pageViewController(pageViewController: Helper_pageVC,
                            didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
