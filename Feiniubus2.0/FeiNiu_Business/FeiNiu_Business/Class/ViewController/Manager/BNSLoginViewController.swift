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

    @IBOutlet weak var inputName: LoginInputView!
    @IBOutlet weak var inputPwd: LoginInputView!
    @IBOutlet weak var btnSaveName: UIButton!
    
    
    override func viewDidLoad() {
        
        UrlMaps.shareInstance.initMaps([0: KServerAddr + UNI_Login])
        
        super.viewDidLoad()
        self.initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initUI() {
        inputName.setLeftImageNormal(UIImage(named: "tel@icon"), imageHigh: UIImage(named: "tel@icon"))
        inputName.placeholder = "请输入登录帐号"
        inputPwd.setLeftImageNormal(UIImage(named: "code@icon"), imageHigh: UIImage(named: "code@icon"))
        inputPwd.placeholder = "请输入登录密码"
    }
    
    
    //MARK: - button action
    @IBAction func btnSaveNameClick(sender: AnyObject) {
        let selected = btnSaveName.selected;
        btnSaveName.selected = !selected
        
        if selected {
            btnSaveName.setImage(UIImage(named: "check_n"), forState:.Normal)
        }
        else {
            btnSaveName.setImage(UIImage(named: "check_s"), forState: .Normal)
        }
    }
    @IBAction func btnForgetPwdClick(sender: AnyObject) {
        self.performSegueWithIdentifier("toForget", sender: nil)
    }
    @IBAction func btnLoginClick(sender: AnyObject) {
        NetInterfaceManager.shareInstance.sendRequstWithType(Int(EmRequestType_Login.rawValue)) { (params) in
            params.method = .EMRequstMethod_POST
            params.data = ["username":"18081003937",
                           "password":"987654",
                           "grant_type":"password",
                           "client_id":"0791b17234b14946bf8c6e5406e0bf9e",
                           "client_secret":"33_4gOkGBiZgUwhQUdUVxi-QCIqPkQMYvcYZ3e3ao4s",
                           "registration_id":"E87DB0BA1F76428",
                           "terminal_type":"ios"]
        }
    }
    @IBAction func btnBusinessRegisterClick(sender: AnyObject) {
        self.performSegueWithIdentifier("toRegister", sender: nil)
    }
}
