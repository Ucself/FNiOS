//
//  BNSPaymentViewController.swift
//  FeiNiu_Business
//
//  Created by lbj@feiniubus.com on 16/9/6.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

enum payType:Int {
    case payTypeAli = 1  //支付宝
    case payTypeWX = 13  //微信
}

class BNSPaymentViewController: BNSUserBaseUIViewController {

    @IBOutlet weak var alipayButton: UIButton!
    @IBOutlet weak var wechatButton: UIButton!
    @IBOutlet weak var payButton: UIButton!
    var payMode:payType = .payTypeAli
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    // MARK: - actions
    
    @IBAction func alipayBackgroudButtonClick(_ sender: AnyObject) {
        self.alipayButton.isSelected = true
        self.wechatButton.isSelected = false
        payMode = .payTypeAli
    }
    
    @IBAction func wechatBackgroundButtonClick(_ sender: AnyObject) {
        self.alipayButton.isSelected = false
        self.wechatButton.isSelected = true
        payMode = .payTypeWX
    }
    
    @IBAction func payButtonClick(_ sender: AnyObject) {
    }
    
    
    
    
    
    
}
