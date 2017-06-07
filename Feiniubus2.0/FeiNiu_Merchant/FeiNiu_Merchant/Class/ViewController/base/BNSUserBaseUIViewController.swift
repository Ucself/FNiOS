//
//  BNSUserBaseUIViewController.swift
//  FeiNiu_Business
//
//  Created by tianbo on 16/9/6.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNUIView
import FNSwiftNetInterface

class BNSUserBaseUIViewController: BaseUIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor  = UIColor_Background;        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginSuccessNotification", name: KLoginSuccessNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

    // MARK: - Features
    internal class func instanceFromStoryboard() -> Self {
        return self.init()
    }

    internal func navigateionViewBack() {
        self.pop()
    }
    
    internal func navigateionViewRight() {
        
    }
    
    
    override func stopWait() {
        WaitView.sharedInstance().stop()
    }
    
    override func startWait() {
        WaitView.sharedInstance().start()
    }
    
    internal func showTips(_ tipMsg:String, type:FNTipType) {
        self.showTips(tipMsg, type: type, delay: 1.5)
    }
    
    fileprivate func showTips(_ tipMsg:String, type:FNTipType, delay:TimeInterval) {
        
        if type == FNTipTypeNone {
            super.showTipsView(tipMsg)
        }
        else {
            MBProgressHUD.showTip(tipMsg, with: type, withDelay: delay)
        }
    }

    
    // MARK: - http handler
    override func httpRequestFinished(_ notification:Notification){
        
    }
    
    override func httpRequestFailed(_ notification:Notification){
        self.stopWait()
        guard let result = notification.object as? NetResultDataModel else {
            NSLog("result is nil")
            return
        }
        if let massage = result.message {
            self.showTips(massage, type: FNTipTypeFailure)
        }

    }
    
    //MARK: login notification
    internal func loginSuccessHandler() {
        
    }
    
    
    func loginSuccessNotification() {
        self.loginSuccessHandler()
    }

}
