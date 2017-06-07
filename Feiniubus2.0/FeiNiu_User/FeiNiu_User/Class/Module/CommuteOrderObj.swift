//
//  CommuteOrderObj.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 17/1/11.
//  Copyright © 2017年 tianbo. All rights reserved.
//

import UIKit

//票的状态
public enum CommuteTicketState:String{
    case Uncheckable = "Uncheckable"        //不可检票
    case Unchecked = "Unchecked"            //未检票
    case Checked = "Checked"                //已检票
    case Unkown = "Unkown"
    
    static public func toString(enumName:String) -> String {
        switch enumName {
        case "Uncheckable":
            return "不可验票"
        case "Unchecked":
            return "未检票"
        case "Checked":
            return "已检票"
        default:
            return "Unkown"
        }
    }
}
//订单状态
public enum CommuteOrderState:String{
    case Unkown = "Unkown"
    case Dispatched = "Dispatched"              //预约成功
    case Waiting = "Waiting"                    //等待上车
    case Transporting = "Transporting"          //接送中
    case Completed = "Completed"                //已完成
    case Evaluated = "Evaluated"                //已评价
    case Cancelled = "Cancelled"                //已取消
    case PendingPay = "PendingPay"              //等待支付
    case Refunding = "Refunding"                //退款中
    case Refunded = "Refunded"                  //退款完成
    case RefundApplying = "RefundApplying"      //退款申请中
    
    static public func toString(enumName:String) -> String {
        switch enumName {
        case "Dispatched":
            return " 预约成功 "
        case "Waiting":
            return " 等待上车 "
        case "Transporting":
            return " 接送中 "
        case "Completed":
            return " 已完成 "
        case "Evaluated":
            return " 已评价 "
        case "Cancelled":
            return " 已取消 "
        case "PendingPay":
            return " 等待支付 "
        case "Refunding":
            return " 退款中 "
        case "Refunded":
            return " 退款完成 "
        case "RefundApplying":
            return " 退款申请中 "
        default:
            return " Unkown "
        }
    }
    //状态新需求
    static public func toStringNew(enumName:String) -> String {
        switch enumName {
        case "Dispatched":
            return " 待出发 "
        case "Waiting":
            return " 已发车 "
        case "Transporting":
            return " 已发车 "
        case "Completed":
            return " 已完成 "
        case "Evaluated":
            return " 已完成 "
        case "Cancelled":
            return " 已退款 "
        case "PendingPay":
            return " 待出发 "
        case "Refunding":
            return " 已退款 "
        case "Refunded":
            return " 已退款 "
        case "RefundApplying":
            return " 已退款 "
        default:
            return " Unkown "
        }
    }
    
    static public func toColor(enumName:String) -> UIColor {
        let UIColor_RBGGreen = UIColorFromRGB(0x2FA820)
        let UIColor_RBGRed = UIColorFromRGB(0xFE6E35)
        let UIColor_RBGOrange = UIColorFromRGB(0xFFA000)
        let UIColor_RBGGray = UIColorFromRGB(0xD0D0D4)
        
        switch enumName {
        case "Dispatched":
            return UIColor_RBGOrange            //"预约成功"
        case "Waiting":
            return UIColor_RBGGreen             //"等待上车"
        case "Transporting":
            return UIColor_RBGGreen             //"接送中"
        case "Completed":
            return UIColor_RBGGray              //"已完成"
        case "Evaluated":
            return UIColor_RBGGray              //"已评价"
        case "Cancelled":
            return UIColor_RBGGray              //"已取消"
        case "PendingPay":
            return UIColor_RBGOrange            //"等待支付"
        case "Refunding":
            return UIColor_RBGGray              //"退款中"
        case "Refunded":
            return UIColor_RBGGray              //"退款完成"
        case "RefundApplying":
            return UIColor_RBGGray              //"退款申请中"
        default:
            return UIColor_RBGGray              //"Unkown"
        }
    }
}

class busInforObj: NSObject {
    var license:String?             //车牌号
    var seats:Int = 0               //座位数
}

class CommuteOrderObj: NSObject {
    
    var id:String?                              //车牌id
    var creator_id:String?                      //乘客id
    var order_id:String?                        //订单号
    var line_id:String?                         //班线id
    var ticket_date:String?                     //车票日期
    var on_station_time:String?                 //上车时间
    var off_station_time:String?                //下车时间
    var on_station_name:String?                 //上车站
    var off_station_name:String?                //下车站
    var on_station_image_uri:String?            //上车站图片
    var off_station_image_uri:String?           //下车站图片
    var on_station_address:String?              //上车站地址
    var off_station_address:String?             //下车站地址
    var start_station_name:String?              //线路起点站
    var destination_station_name:String?        //线路终点站
    var ticket_state:String = "Unkown"          //CommuteTicketState -> 车票状态
    var order_state :String = "Unkown"          //CommuteOrderState -> 订单状态
    var adcode:String?                          //区域代码
    var price:Double = 0                        //票价
    var create_time:String?                     //买票下单时间
    var is_submit_cancel_reason:Bool = false    //是否提交取消原因
    var is_refundable:Bool = false              //是否可退票
    var remark:String = ""                      //班线备注
    
    
    var last_station_id:String?                 //车辆上一个站点ID
    var last_station_site_state:String?         //车辆到达上一个站点状态
    
    var buses:Array<Any>?                       //指派车辆信息集合
    var on_station_infos:Array<Any>?            //线路上车站点集合
    var off_station_infos:Array<Any>?           //线路下车站点集合
    
    //mj解析使用
    override open static func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["on_station_infos": StationInfo.self,"off_station_infos": StationInfo.self,"buses":busInforObj.self];
    }
}
