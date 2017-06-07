//
//  PaymentHelper.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/12/9.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNPayment

public enum PayType:Int {
    case Wechat   = 0
    case Ali      = 1
    case Union    = 2
    
    public func toString() -> String {
        switch self {
        case .Union:
            return "CMBPay_Mobile"
        case .Ali:
            return "Alipay_Mobile"
        case .Wechat:
            return "WxPay_Mobile"
        }
    }
}


@objc protocol PaymentHelperDelegate {
    @objc optional func paymentHelperResultHandler(_ code:PayRetCode)
}


class PaymentHelper: NSObject {
    
    var delegate:PaymentHelperDelegate?
    var controller:UIViewController?
    
    var block:((PayRetCode) -> Void)?
    
    
    static let instance = PaymentHelper()
    private override init() {}
    
//    func pay(_ type:PayType, data:NSDictionary, delegate:PaymentHelperDelegate)  {
//        self.delegate = delegate
//        
//        switch type {
//        case .Ali:
//            self.paymentAli(data)
//        case .Wechat:
//            self.paymentWechat(data)
//        case .Union:
//            self.paymentUnion(data)
//        }
//    }
    
    func pay(_ type:PayType, data:NSDictionary, controller:UIViewController, block: @escaping (PayRetCode) -> Void)  {
        self.block = block
        self.controller = controller
        
        switch type {
        case .Ali:
            self.paymentAli(data)
        case .Wechat:
            self.paymentWechat(data)
        case .Union:
            self.paymentUnion(data)
        }
    }

    
    //支付宝
    func paymentAli (_ data:NSDictionary) {

        FNPaymentManager.instance().pay(with: FNPayType.PayType_Ali, controller: self.controller, order: { (order:FNPayOrder?) in
            let payOrder:FNAliOrder = order as! FNAliOrder
            payOrder.aliDescription = data["data"] as? String
            
            
        }) { (code:PayRetCode) in
            print("支付返回\(code.rawValue)")

            self.finished(code)
        }
    }
    //微信
    func paymentWechat (_ data:NSDictionary) {

        FNPaymentManager.instance().pay(with: FNPayType.PayType_WeChat, controller:controller, order: { (order:FNPayOrder?) in
            let payOrder:FNWeChatOrder = order as! FNWeChatOrder
            payOrder.appid      = data["appid"] as? String
            payOrder.partnerid  = data["partnerid"] as? String
            payOrder.noncestr   = data["noncestr"] as? String
            payOrder.package    = data["packages"] as? String
            payOrder.prepayid   = data["prepayid"] as? String
            payOrder.sign       = data["sign"] as? String
            payOrder.timestamp  = data["timestamp"] as? String
            
        }) { (code:PayRetCode) in
            print("支付返回\(code.rawValue)")

            self.finished(code)
        }
    }
    //银行卡
    func paymentUnion (_ data:NSDictionary) {

        FNPaymentManager.instance().pay(with: FNPayType.PayType_Union, controller: controller, order: { (order:FNPayOrder?) in
            let payOrder:FNUnionOrder = order as! FNUnionOrder
            payOrder.url  = data["url"] as? String
            payOrder.data = data["data"] as? String
            
        }) { (code:PayRetCode) in
            print("支付返回\(code.rawValue)")

            self.finished(code)
        }
    }
    
    func finished(_ code:PayRetCode) {
        if self.block != nil {
            self.block!(code)
        }
        else {
            self.delegate?.paymentHelperResultHandler?(code)
        }
    }
}
