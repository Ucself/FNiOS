//
//  BNSMainViewController.swift
//  FeiNiu_Business
//
//  Created by lbj@feiniubus.com on 16/9/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNUIView

class BNSMainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initTabController()
        self.frostedViewController?.rightMargin = 90
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func initTabController() -> Void {
//        UITabBar.appearance()
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName:UIFont.systemFontOfSize(13)], forState: UIControlState.Normal)
        
        let storyboard = UIStoryboard.init(name: "Order", bundle: nil)
        let order = storyboard.instantiateInitialViewController()
        let managerStoryboard = UIStoryboard.init(name: "Manager", bundle: nil)
        let manager = managerStoryboard.instantiateInitialViewController()
        
        let controllers:[UIViewController]? = [order!,manager!]
        self.setViewControllers(controllers, animated: true)
    }
    
    // MARK: - http request handler
    func httpRequestFinished(notification:NSNotification) -> Void {
        
    }
    func httpRequestFailed(notification:NSNotification) -> Void {
        
    }
}
