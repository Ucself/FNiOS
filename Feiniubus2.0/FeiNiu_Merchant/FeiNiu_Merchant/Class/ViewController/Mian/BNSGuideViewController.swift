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
        self.fd_interactivePopDisabled = true;
        
        self.pageControl.currentPage = 0
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
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
    @IBAction func btnDone(_ sender: AnyObject) {
        //self.performSegueWithIdentifier("tomainview", sender: nil)
        
        let token = AuthorizeCache.sharedInstance().accessToken ?? ""
        if token.isEmpty {
            
            let storyboard = UIStoryboard.init(name: "Manager", bundle: nil)
            let logVC = storyboard.instantiateViewController(withIdentifier: "BNSLoginViewController") as! BNSLoginViewController
            logVC.finishedBlock = {
                
                let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BNSMainViewController")
                self.navigationController?.setViewControllers([mainVC], animated: true)
                
            }
            
            self.navigationController?.pushViewController(logVC, animated: true)
        }
        else {
            self.performSegue(withIdentifier: "tomainview", sender: nil)
        }
    }
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
