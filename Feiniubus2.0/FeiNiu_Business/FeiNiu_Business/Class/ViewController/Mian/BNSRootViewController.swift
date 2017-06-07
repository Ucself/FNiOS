//
//  BNSRootViewController.swift
//  FeiNiu_Business
//
//  Created by lbj@feiniubus.com on 16/9/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class BNSRootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.showLaunchImage();
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.goNext()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: ------
    func goNext() -> Void {
        let locVer:String? = UserPreferences.sharedInstance().getAppVersion()
        let curVer:String? = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
        
        if locVer == curVer {
            self.performSegueWithIdentifier("gotomain", sender: nil)
        }
        else{
            UserPreferences.sharedInstance().setAppVersion(curVer)
            self.performSegueWithIdentifier("toguide", sender: nil)
        }
        
    }
    
    func showLaunchImage() -> Void {
//        let viewSize = self.view.bounds.size
//        let viewOrientation = "Portrait"    //横屏请设置成 @"Landscape"
//        var launchImage:String?
//        
//        let imagesDict = NSBundle.mainBundle().infoDictionary!["UILaunchImages"] as? Array
//        for dict in imagesDict {
//            let imageSize = CGSizeFromString(ke)
//            
//        }
        
    }
}
