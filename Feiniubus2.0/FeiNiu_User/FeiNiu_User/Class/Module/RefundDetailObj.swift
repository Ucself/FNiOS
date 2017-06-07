//
//  RefundDetailObj.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/11/30.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class RefundLog: NSObject {
    //订单状态
    var order_state:String?
    //状态操作时间
    var time:String?
}

class RefundDetailObj: NSObject {
    //订单id
    var order_id:String?
    //退款状态
    var order_state:String?
    //起点名称
    var starting:String?
    //终点名称
    var destination:String?
    //用车时间 YYYY-MM-DD HH:MM:SS
    var use_time:String?
    //退款原因
    var reason:String?
    //退款原因备注
    var reason_remark:String?
    //	退款ID
    var refund_id:String?
    //支付平台
    var payment_chanel:String?
    //退款日志信息
    var refund_log:[RefundLog]?
    
    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["refund_log": RefundLog.self];
    }
}

class TicketRefundDetailObj: NSObject {
    //订单id
    var ticket_id:String?
    //退款状态
    var order_state:String?
    //起点名称
    var on_station_name:String?
    //终点名称
    var off_station_name:String?
    //用车时间 YYYY-MM-DD HH:MM:SS
    var ticket_date:String?
    //退款原因
    var reason:String?
    //退款原因备注
    var reason_remark:String?
    //	退款ID
    var charge_id:String?
    //支付平台
    var payment_chanel:String?
    //退款日志信息
    var refund_log:[RefundLog]?
    
    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["refund_log": RefundLog.self];
    }
}
