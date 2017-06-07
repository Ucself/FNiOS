//
//  EvaluateObj.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/11/22.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class EvaluateObj: NSObject {
    var order_id:String? 	        //订单id
    var is_comment:Bool = false 	//是否已评价
    var order_dispatches:NSArray? 	        //driver 实体参照订单详情接口driver实体
    var price:Int = 0 	    //总金额
    var payment_price:Int = 0      //支付价格
    var appraises:String?          //评价标签
    var appraise_keys:String?      //评价标签
    var content:String?            //评价内容
    var score:Int = 0              //评分
    
    //通勤评价字断
    var ticket_id:String?   //行程id
    
    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["order_dispatches": DriverObj.self];
    }
}
