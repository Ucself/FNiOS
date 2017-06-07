//
//  BNSForgetPwdViewController.swift
//  FeiNiu_Business
//
//  Created by tianbo on 16/9/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNUIView
import FNSwiftNetInterface

class BNSForgetPwdViewController: BNSUserBaseUIViewController {
    
    @IBOutlet weak var inputPhone: BNSLoginInputView!
    @IBOutlet weak var inputCode: BNSLoginInputView!
    @IBOutlet weak var inputPwd1: BNSLoginInputView!
    @IBOutlet weak var inputPwd2: BNSLoginInputView!
    @IBOutlet weak var successView: UIView!

    var offset:CGFloat = 0
    var userId:String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        inputPhone?.setLeftImage(UIImage(named: "tel@icon"), high: UIImage(named: "tel@icon"))
        inputCode?.setLeftImage(UIImage(named: "code@icon"), high: UIImage(named: "code@icon"))
        inputPwd1?.setLeftImage(UIImage(named: "password@icon"), high: UIImage(named: "password@icon"))
        inputPwd2?.setLeftImage(UIImage(named: "passwordagain@icon-0"), high: UIImage(named: "passwordagain@icon-0"))

        inputPhone.placeholder = "请输入手机号";
        inputCode.placeholder = "请输入短信验证码";
        inputPwd1.placeholder = "请输入新密码";
        inputPwd2.placeholder = "请再次确认新密码";
        
        let btnCode:TimerButton = TimerButton(type: .system)//[TimerButton buttonWithType:UIButtonTypeRoundedRect];
        btnCode.setTitle("获取验证码", for: UIControlState())
        btnCode.setTitleColor(UIColor.white, for: UIControlState())
        btnCode.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btnCode.backgroundColor = UIColor_DefOrange
        btnCode.layer.cornerRadius = 5
        btnCode .addTarget(self, action: #selector(btnGetVerifyCode(_:)), for: .touchUpInside)
        
        inputCode.setRightButton(btnCode, width: 100, height: 30)
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
    
    //MARK: - button action
    func btnGetVerifyCode(_ sender:AnyObject) {
        inputPhone.resignFirstResponderS()
        inputCode.resignFirstResponderS()
        inputPwd1.resignFirstResponderS()
        inputPwd2.resignFirstResponderS()
        
        
        let text:String = (inputPhone.textField?.text)!
        if text.isEmpty {
            self.showTip("请输入手机号", with: FNTipTypeFailure)
            return;
        }
        
        startWait()
        NetInterfaceManager.shareInstance.sendRequstWithType(EMRequestType.emRequestType_GetPwdVerify.rawValue) { (params) in
            params.data = ["phone": text]  as AnyObject
        }
        
    }
    @IBAction func btnGotoLoginClick(_ sender: AnyObject) {
        pop()
    }
    
    @IBAction func btnCommitClick(_ sender: AnyObject) {
        inputPhone.resignFirstResponderS()
        inputCode.resignFirstResponderS()
        inputPwd1.resignFirstResponderS()
        inputPwd2.resignFirstResponderS()
        
        
        var text:String = (inputPhone.textField?.text)!
        if text.isEmpty {
            self.showTip("请输入手机号", with: FNTipTypeFailure)
            return;
        }
        
        if text.characters.count != 11 {
            self.showTip("请输入正确的手机号", with: FNTipTypeFailure)
            return
        }
        
        text = (inputCode.textField?.text)!
        if text.isEmpty {
            self.showTip("请输入短信验证码", with: FNTipTypeFailure)
            return;
        }
        
        text = (inputPwd1.textField?.text)!
        if text.isEmpty {
            self.showTip("请输入新密码", with: FNTipTypeFailure)
            return;
        }
        
        let text2:String = (inputPwd2.textField?.text)!
        if text2.isEmpty {
            self.showTip("请输入请再次输入新密码", with: FNTipTypeFailure)
            return;
        }
        
        if text != text2 {
            self.showTip("两次输入的密码不一致", with: FNTipTypeFailure)
            return
        }
        
        startWait()
        NetInterfaceManager.shareInstance.sendRequstWithType(EMRequestType.emRequestType_GetPwdExist.rawValue) { (params) in
            params.data = ["phone": self.inputPhone.textField?.text ?? ""] as NSDictionary
        }
        
    }
    
    
    
    //MARK: - http handler
    override func httpRequestFinished(_ notification:Notification){
        super.httpRequestFinished(notification)
        
        let resultData:NetResultDataModel = notification.object as! NetResultDataModel
        switch resultData.type {
        case EMRequestType.emRequestType_GetPwdExist.rawValue:

            NetInterfaceManager.shareInstance.sendRequstWithType(EMRequestType.emRequestType_PostPwdReset.rawValue) { (params) in
                params.method = .emRequstMethod_POST
                params.data = ["user_id": self.userId ?? "",
                               "token"  : (self.inputCode.textField?.text)!,
                               "password" : (self.inputPwd2.textField?.text)!] as NSDictionary
            }
            
        case EMRequestType.emRequestType_GetPwdVerify.rawValue:
            
            let dict = resultData.data as? NSDictionary
            userId = dict!["user_id"] as? String
            showTipsView("验证码已发送")
            stopWait()
            
        case EMRequestType.emRequestType_PostPwdReset.rawValue:
            stopWait()
            successView.isHidden = false
        default:
            break
        }
        
    }
    override func httpRequestFailed(_ notification:Notification){
        super.httpRequestFailed(notification)
    }

}
