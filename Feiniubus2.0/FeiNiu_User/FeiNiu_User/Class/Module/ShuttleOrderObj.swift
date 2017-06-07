//
//  ShuttleOrderObj.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/11/22.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

public enum ShuttleOrderState:String {
    case Unkown = ""
    case PendingDispatch = "PendingDispatch" 	//等待派车(app:正在派车)
    case QueuingDispatch = "QueuingDispatch" 	//预约排队（派车失败）
    case Dispatched      = "Dispatched" 	    //预约成功(app:预约成功)
    case Transporting 	 = "Transporting" 	    //接送中 (app:行程中)
    case Completed 	    = "Completed" 	        //已完成(app:已完成 未评价)
    case Evaluated 	    = "Evaluated" 	        //评价已完成(app:已完成 已评价)
    case Waiting 	    = "Waiting" 	        //等待上车 (app:等待上车)
    case PendingPay 	= "PendingPay" 	        //等待支付
    case Refunding 	    = "Refunding" 	        //退款中
    case Refunded 	    = "Refunded" 	        //退款完成
    case RefundApplying = "RefundApplying" 	    //退款申请中(后台还未处理)
    case DriverHasStarted = "DriverHasStarted"  //司机已出发
    case DriverHasArrived = "DriverHasArrived"  //司机已到达
    case PassengerAreNotOnBoard = "PassengerAreNotOnBoard"      //乘客未上车
    case Dispatching     = "Dispatching"        //正在派车(调度端app临时状态)
    case LosslessCancellationOfApplication  = "LosslessCancellationOfApplication"      //无损取消申请
    case LosslessCancellation = "LosslessCancellation"          //无损取消
    case DispatchFail 	= "DispatchFail" 	    //预约失败
    case Cancelled      = "Cancelled" 	        //已经取消
    
    public func toString() -> String {
        switch self {
        case .Unkown:
            return "Unkown"
        case .PendingDispatch:
            return "预约成功"
        case .QueuingDispatch:
            return "预约成功"
        case .Dispatched:
            return "预约成功"
        case .Transporting:
            return "乘客已上车"
        case .Completed:
            return "已完成"
        case .Evaluated:
            return "已完成"
        case .Waiting:
            return "等待接驾"
        case .PendingPay:
            return "等待支付"
        case .Refunding:
            return "已取消"
        case .Refunded:
            return "已取消"
        case .RefundApplying:
            return "已取消"
        case .DispatchFail:
            return "预约失败"
        case .Cancelled:
            return "已取消"
        case .DriverHasStarted:
            return "司机已出发"
        case .DriverHasArrived:
            return "司机已到达"
        case .PassengerAreNotOnBoard:
            return "乘客未上车"
        case .Dispatching:
            return "预约成功"
        case .LosslessCancellationOfApplication:
            return "预约成功"
        case .LosslessCancellation:
            return "无损取消"
        }
    }
    
    public func toColor() -> UIColor {
        let UIColor_RBGGreen = UIColorFromRGB(0x2FA820)
        let UIColor_RBGRed = UIColorFromRGB(0xFE6E35)
        let UIColor_RBGOrange = UIColorFromRGB(0xFFA000)
        let UIColor_RBGGray = UIColorFromRGB(0xD0D0D4)
        
        switch self {
        case .Unkown:
            return UIColor_RBGOrange
        case .PendingDispatch:
            return UIColor_RBGOrange            //预约成功
        case .QueuingDispatch:
            return UIColor_RBGOrange            //预约成功
        case .Dispatched:
            return UIColor_RBGOrange            //预约成功
        case .Transporting:
            return UIColor_RBGGreen             //行程中
        case .Completed:
            return UIColor_RBGGray              //已完成
        case .Evaluated:
            return UIColor_RBGGray              //已完成
        case .Waiting:
            return UIColor_RBGRed               //等待上车
        case .PendingPay:
            return UIColor_RBGRed               //等待支付
        case .Refunding:
            return UIColor_RBGGray              //已取消
        case .Refunded:
            return UIColor_RBGGray              //已取消
        case .RefundApplying:
            return UIColor_RBGGray              //已取消
        case .DispatchFail:
            return UIColor_RBGGray              //预约失败
        case .Cancelled:
            return UIColor_RBGGray              //已取消
        case .DriverHasStarted:
            return UIColor_RBGOrange
        case .DriverHasArrived:
            return UIColor_RBGOrange
        case .PassengerAreNotOnBoard:
            return UIColor_RBGOrange
        case .Dispatching:
            return UIColor_RBGOrange
        case .LosslessCancellationOfApplication:
            return UIColor_RBGGray
        case .LosslessCancellation:
            return UIColor_RBGGray
        }
    }

}

public enum ShuttleOrderType:String {
    case AirportSend         = "AirportSend"        //送机
    case AirportPickup       = "AirportPickup"      //接机
    case BusStationSend      = "BusStationSend"     //送汽车站
    case BusStationPickup    = "BusStationPickup"   //接汽车站
    case TrainStationSend    = "TrainStationSend"   //送火车站
    case TrainStationPickup  = "TrainStationPickup" //接火车站
}


open class ShuttleOrderObj: NSObject {

    //var state:String?                     //1查询到订单 0未查询到订单
    var use_time:String?                    //用车时间 YYYY-MM-DD MM:SS
    var people_number:Int = 0               //人数
    var starting:String?                    //起点名称
    var s_latitude:Double = 0               //起点纬度
    var s_longitude:Double = 0              //起点经度
    var destination:String?                 //终点名称
    var d_latitude:Double = 0               //终点纬度
    var d_longitude:Double = 0              //终点经度
    var adcode:String?                      //城市编码
    var id:String?                          //订单id
    var order_state:String = ""             //订单状态
    //var order_state_key:Int = 0           //订单状态   ShuttleOrderState  MJ解析不了先用Int型
    var car_type:String?                    //用车类型   UseCarType         MJ解析不了先用Int型
    var order_dispatches:NSArray?           //driver collections 	司机信息数组
    var promotion_price:Int = 0             //支付价格
    var is_submit:Bool = false              //是否提交取消原因
    var price:Int = 0                       //总金额
    var create_time:String?                 //创建时间
    //var coupon_amount:Int = 0             //优惠金额
    var payment_price:Int = 0               //退款金额
    var order_appraise:EvaluateObj?         //评价实体 参考评价接口返回
    var reason:String?                      //订单退款原因
    var reason_remark:String?               //订单退款原因备注
    //var is_fixed_price:Bool = true        //是否一口价
    var contact_phone:String?               //联系电话
    var contact_name:String?                //联系人名字
    //var unit_amount:Int = 0               //单价(一口价则为0)
    var bill_details:NSArray?               //帐单详情
    var best_coupon:CouponObj?              //最优优惠券
    var guide_page_url:String?              //航站楼对应的接站位置链接地址
    var phone_configs:NSArray?              //接站或调度人员电话
    var location:String?                    //航站楼对应的接站位置
    var order_type:String = ""                  //订单类型
    var flight_number:String?               //航班号
    var flight_time:String?                 //航班时间
    
    
    
    override open static func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["order_dispatches": DriverObj.self];
    }
    
}



