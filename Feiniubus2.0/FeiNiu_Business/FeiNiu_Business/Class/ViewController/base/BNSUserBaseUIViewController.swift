//
//  BNSUserBaseUIViewController.swift
//  FeiNiu_Business
//
//  Created by tianbo on 16/9/6.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNUIView

class BNSUserBaseUIViewController: BaseUIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginSuccessNotification", name: KLoginSuccessNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

    // MARK: - Features
    internal class func instanceFromStoryboard() -> Self {
        return self.init()
    }

    internal func navigateionViewBack() {
        self.popViewController()
    }
    
    internal func navigateionViewRight() {
        
    }
    
    
    override func stopWait() {
        WaitView.sharedInstance().stop()
    }
    
    override func startWait() {
        WaitView.sharedInstance().start()
    }
    
    private func showTips(tipMsg:String, type:FNTipType) {
        self.showTips(tipMsg, type: type, delay: 1.5)
    }
    
    private func showTips(tipMsg:String, type:FNTipType, delay:NSTimeInterval) {
        
        if type == FNTipTypeNone {
            super.showTipsView(tipMsg)
        }
        else {
            MBProgressHUD.showTip(tipMsg, withType: type, withDelay: delay)
        }
    }

    
    // MARK: - http handler
    override func httpRequestFinished(notification:NSNotification){
        self.stopWait()
    }
    
    override func httpRequestFailed(notification:NSNotification){
        self.stopWait()

        guard let result = notification.object as? ResultDataModel else {
            NSLog("result is nil")
            return
        }
    
        //获取用户信息不提示
        let type = EMRequestType.EmRequestType_GetUserInfo
        if type.rawValue == result.type.hashValue {
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
