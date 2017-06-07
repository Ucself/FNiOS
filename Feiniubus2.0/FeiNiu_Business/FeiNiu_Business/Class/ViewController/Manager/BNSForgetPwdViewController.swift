//
//  BNSForgetPwdViewController.swift
//  FeiNiu_Business
//
//  Created by tianbo on 16/9/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class BNSForgetPwdViewController: BNSUserBaseUIViewController {
    
    @IBOutlet weak var imageSetup: UIImageView!
    @IBOutlet weak var inputUserName: LoginInputView!
    @IBOutlet weak var inputPhone: LoginInputView!
    @IBOutlet weak var inputCode: LoginInputView!
    @IBOutlet weak var inputPwd1: LoginInputView!
    @IBOutlet weak var inputPwd2: LoginInputView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        inputUserName?.setLeftImageNormal(UIImage(named: "user@icon"), imageHigh: UIImage(named: "user@icon"))
        inputPhone?.setLeftImageNormal(UIImage(named: "tel@icon"), imageHigh: UIImage(named: "tel@icon"))
        inputCode?.setLeftImageNormal(UIImage(named: "code@icon"), imageHigh: UIImage(named: "code@icon"))
        inputPwd1?.setLeftImageNormal(UIImage(named: "password@icon"), imageHigh: UIImage(named: "password@icon"))
        inputPwd2?.setLeftImageNormal(UIImage(named: "passwordagain@icon-0"), imageHigh: UIImage(named: "passwordagain@icon-0"))
        
        inputUserName.placeholder = "请输入用户名";
        inputPhone.placeholder = "请输入手机号";
        inputCode.placeholder = "请输入短信验证码";
        inputPwd1.placeholder = "请输入新密码";
        inputPwd2.placeholder = "请再次确认新密码";
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
    
    @IBAction func v1NextClick(sender: AnyObject) {
    }

    @IBAction func v2BackClick(sender: AnyObject) {
    }

    @IBAction func v2NextClick(sender: AnyObject) {
    }

    @IBAction func v3BackClick(sender: AnyObject) {
    }
    @IBAction func v4NextClick(sender: AnyObject) {
    }
}
