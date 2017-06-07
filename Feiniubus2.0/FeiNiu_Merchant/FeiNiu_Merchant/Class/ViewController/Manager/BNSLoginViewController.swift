//
//  LoginViewController.swift
//  FeiNiu_Business
//
//  Created by tianbo on 16/9/5.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNSwiftNetInterface

class BNSLoginViewController: BNSUserBaseUIViewController {

    @IBOutlet weak var inputName: BNSLoginInputView!
    @IBOutlet weak var inputPwd: BNSLoginInputView!
    @IBOutlet weak var btnSaveName: UIButton!
    
    var finishedBlock:(Void) -> Void = {}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.fd_interactivePopDisabled = true;
        self.initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func initUI() {
        inputName.setLeftImage(UIImage(named: "tel@icon"), high: UIImage(named: "tel@icon"))
        inputName.placeholder = "请输入登录帐号"
        inputPwd.setLeftImage(UIImage(named: "code@icon"), high: UIImage(named: "code@icon"))
        inputPwd.placeholder = "请输入登录密码"
        inputPwd.secureEntry = true
        
//        self.inputName.textField!.text ＝ "18581854887"
//        self.inputPwd.textField?.text = "000000"
    }
    
    
    //MARK: - button action
    @IBAction func btnSaveNameClick(_ sender: AnyObject) {
        inputName.resignFirstResponderS()
        inputPwd.resignFirstResponderS()
        
        let selected = btnSaveName.isSelected;
        btnSaveName.isSelected = !selected
        
        if selected {
            btnSaveName.setImage(UIImage(named: "check_n"), for:UIControlState())
        }
        else {
            btnSaveName.setImage(UIImage(named: "check_s"), for: UIControlState())
        }
    }
    @IBAction func btnForgetPwdClick(_ sender: AnyObject) {
        inputName.resignFirstResponderS()
        inputPwd.resignFirstResponderS()
        
        self.performSegue(withIdentifier: "toForget", sender: nil)
    }
    
    @IBAction func btnLoginClick(_ sender: AnyObject) {
        inputName.resignFirstResponderS()
        inputPwd.resignFirstResponderS()
        
        
        let account:String = (self.inputName.textField?.text)!
        if account.isEmpty {
            showTipsView("请输入帐号")
            return;
        }
        
        let pwd:String = (self.inputPwd.textField?.text)!
        if pwd.isEmpty {
            showTipsView("请输入密码")
            return;
        }
        
        self.startWait()
        //登录请求
        NetInterfaceManager.shareInstance.sendRequstWithType(EMRequestType.emRequestType_PostLogin.rawValue) { (params) in
            params.method = EMRequstMethod.emRequstMethod_POST
            params.data = ["username" : account,
                           "password" : pwd,
                           "grant_type" : "password",
                           "client_id" : KClient_id,
                           "client_secret" : KClient_secret,
                           "registration_id" : deviceUUID ?? "",
                           "terminal_type" : "ios"] as NSDictionary
        }
    }
    @IBAction func btnBusinessRegisterClick(_ sender: AnyObject) {
        inputName.resignFirstResponderS()
        inputPwd.resignFirstResponderS()
        self.performSegue(withIdentifier: "toRegister", sender: nil)
    }
    
    //MARK: - http handler
    override func httpRequestFinished(_ notification:Notification){
        super.httpRequestFinished(notification)
        let resultData:NetResultDataModel = notification.object as! NetResultDataModel
        switch resultData.type {
        case EMRequestType.emRequestType_PostLogin.rawValue:
            self.stopWait()
            if let dicData = resultData.data as? NSDictionary {
                AuthorizeCache.sharedInstance().accessToken = dicData["access_token"] as? String
                AuthorizeCache.sharedInstance().refreshToken = dicData["refresh_token"] as? String
                AuthorizeCache.sharedInstance().userId = dicData["user_id"] as? String
                AuthorizeCache.sharedInstance().userName = dicData["user_name"] as? String
                //设置鉴权信息
                var  newAuthorizeHead:[String : String] = NetInterfaceManager.shareInstance.getAuthorization()
                newAuthorizeHead["Authorization"] = "Bearer " + AuthorizeCache.sharedInstance().accessToken
                NetInterfaceManager.shareInstance.setAuthorization(newAuthorizeHead)
            }
            self.showTipsView("登录成功")
            
            
            let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.finishedBlock();
                NotificationCenter.default.post(name: Notification.Name(rawValue: KLoginSuccessNotification), object: nil)
            }
            
//            //消失回调
//            self.dismissViewControllerAnimated(true, completion: { 
//                NSNotificationCenter.defaultCenter().postNotificationName(KLoginSuccessNotification, object: nil)
//            })
            
        default:
            break
        }
        
    }
    override func httpRequestFailed(_ notification:Notification){
        super.httpRequestFailed(notification)
    }
}
