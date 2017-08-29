//
//  Helper_pageVC.swift
//  CoInQ
//
//  Created by hui on 2017/8/23.
//  Copyright © 2017年 NTNUCSCL. All rights reserved.
//

import Foundation
import UIKit

class Helper_pageVC: UIPageViewController, UIPageViewControllerDataSource , UIPageViewControllerDelegate{
    
    //所有页面的视图控制器
    private(set) lazy var allViewControllers: [UIViewController] = {
        return [self.getViewController(indentifier: "firstVC"),
                self.getViewController(indentifier: "secondVC"),
                self.getViewController(indentifier: "thirdVC")]
    }()
    
    var willTransitionTo: UIViewController!
    weak var pageDelegate: PageViewControllerDelegate?
    
    //页面加载完毕
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //数据源设置
        self.dataSource = self
        self.delegate = self
        //设置首页
        if let firstViewController = allViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        //页面数量改变，通知委托对象
        pageDelegate?.pageViewController(pageViewController: self, didUpdatePageCount: allViewControllers.count)
    }
    
    //根据indentifier获取Storyboard里的视图控制器
    private func getViewController(indentifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(indentifier)")
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    //获取前一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = allViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard allViewControllers.count > previousIndex else {
            return nil
        }
        
        return allViewControllers[previousIndex]
    }
    
    //获取后一个页面
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = allViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = allViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return allViewControllers[nextIndex]
    }
    
    
    //页面切换完毕
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController],transitionCompleted completed: Bool) {
        if let firstViewController = viewControllers?.first,
            let index = allViewControllers.index(of: firstViewController) {
            //当前页改变，通知委托对象
            pageDelegate?.pageViewController(pageViewController: self, didUpdatePageIndex: index)
        }
    }
}

//自定义视图控制器代理协议
protocol PageViewControllerDelegate: class {
    
    //当页面数量改变时调用
    func pageViewController(pageViewController: Helper_pageVC,
                            didUpdatePageCount count: Int)
    
    //当前页索引改变时调用
    func pageViewController(pageViewController: Helper_pageVC,
                            didUpdatePageIndex index: Int)


}
