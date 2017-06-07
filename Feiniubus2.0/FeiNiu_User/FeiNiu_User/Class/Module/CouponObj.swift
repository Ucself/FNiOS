//
//  CouponObj.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 2017/4/27.
//  Copyright © 2017年 tianbo. All rights reserved.
//

import UIKit

class CouponObj: NSObject {
    var id:String?                  //优惠券id
    var owner:String?               //乘客id
    var kind:String = ""            //优惠券类型
    var value:Int = 0               //优惠总金额，总折扣
    var name:String?                //优惠券名称，描述
    var state:String = ""           //优惠券状态。状态说明
    var btype:String = ""           //用车类型
    var expire_at:String?           //过期时间
    var is_best:Bool = false        //是否为最优优惠券
    var content:Array<String>?             //使用限制说明
    
    
}

////优惠劵类型
// public enum CouponType:NSString {
//    case Unkown = ""
//    case Cash = "Cash"                  //定额优惠现金券
//    case Discount = "Discount"          //折扣券
//    case Fixed = "Fixed"                //定额支付现金券
//}
////优惠劵使用状态
//public enum CouponState:String {
//    case Unkown = ""
//    case UnUse = "UnUse"                //未使用
//    case Used = "Used"                  //已使用
//    case Expiry = "Expiry"              //已过期
//    case NotStarted = "NotStarted"      //没有达到开始使用日期
//}
//
////业务类型类型
//public enum CUseCarType:String {
//    case Unkown = ""
//    case Carpool = "Carpool"            //拼车
//    case Charter = "Charter"            //包车
//    case Commute = "Commute"            //通勤车
//}
