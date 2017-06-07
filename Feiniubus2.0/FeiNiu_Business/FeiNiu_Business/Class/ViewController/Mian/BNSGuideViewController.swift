//
//  BNSGuideViewController.swift
//  FeiNiu_Business
//
//  Created by lbj@feiniubus.com on 16/9/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class BNSGuideViewController: UIViewController,UIScrollViewDelegate {

    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.pageControl.currentPage = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func btnDone(sender: AnyObject) {
        self.performSegueWithIdentifier("tomainview", sender: nil)
    }
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        switch scrollView.contentOffset.x {
        case 0:
            self.pageControl.currentPage = 0
        case self.view.frame.size.width:
            self.pageControl.currentPage = 1
        case self.view.frame.size.width * 2:
            self.pageControl.currentPage = 2
        default:
            self.pageControl.currentPage = 0
        }
    }
}
