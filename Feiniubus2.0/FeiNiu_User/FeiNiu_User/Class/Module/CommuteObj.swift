//
//  CommuteListObj.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 17/1/3.
//  Copyright © 2017年 tianbo. All rights reserved.
//

import UIKit

//通勤车线路状态
public enum CommuteRouteState:String{
    case None = "None"                      //None
    case Bought = "Bought"                  //买过
    case Nearby = "Nearby"                  //附近
}
//通勤车购票状态
public enum CommuteBuyTicketState:String{
    case CanBuy = "CanBuy"                  //可买
    case Bought = "Bought"                  //买过
    case SoldOut = "SoldOut"                //卖完
    case NoSale = "NoSale"                  //未售
    case Conflict = "Conflict"              //冲突
}

//通勤车站点类型
public enum CommuteStationType:String{
    case Start = "Start"                    //出发点
    case On = "On"                          //上车点
    case Off = "Off"                        //下车点
    case Terminal = "Terminal"              //终点
    case None = "None"
}


class StationInfo: NSObject {
    var name:String?                        //站点名称
    var time:String?                        //线路到达时间
    var station_type:String = "None"        //CommuteStationType -> 站点类型
    var is_bought:Bool = false              //是否购买过这个站点
    var image_uri:String?                   //站点图片
    
    var id:String?                          //站点id
    var address:String?                     //详细地址
    var latitude:Double = 0                 //纬度
    var longitude:Double = 0                //经度
    var map_address:String?                 //地图地址
    var is_last_on_station:Int = 0          //是否最后一次买票上车站
    var is_last_off_station:Int = 0         //是否最后一次买票下车站
    //HH:mm:ss 转换 成 HH:mm
    func timeFormat(timeString:String?) -> String {
        
        if timeString == nil || timeString == ""{
            return ""
        }
        
        let timeDate:Date = DateUtils.date(from: timeString, format: "HH:mm:ss")
        return DateUtils.formatDate(timeDate, format: "HH:mm")
    }
}

class TicketInfo: NSObject {
    var date:String?                        //日期
    var ticket_state:String?                //CommuteBuyTicketState -> 余票状态(CanBuy=0,Bought=1,SoldOut=2,NoSale=3,Conflict)
    var price:Int = 0                       //价格
    var activity_price:Int = 0                  //活动价格(等于0的时候用原价)
}



class CommuteObj: NSObject {

    //公共属性
    var id:String?                          //线路id
    var name:String?                        //线路名称
    var price:Int = 0                       //价格
    var discount:Int = 0                    //折扣
    var promotion_price:Int = 0             //优惠后金额
    var is_activity_price:Bool = false       //是否为活动价
    var route_state:String = "None"         //CommuteRouteState -> 路线状态 (None,Bought,Nearby)
    var starting:String?                    //起点名称
    var destination:String?                 //终点名称
    var line_departure_time:String?         //起点发车时间
    var line_arrival_time:String?           //终点到达时间
    var remark:String = ""                  //线路备注
    
    
    //搜索线路属性
    var from:String?                        //用户输入起点
    var to:String?                          //用户输入终点
    var on_station_distance:Double = 0      //距离上车站点距离
    var off_station_distance:Double = 0     //距离下车站点距离
    var on_station:StationInfo?
    var off_station:StationInfo?
    
    //线路详情属性
    var sold_tickets_count:Int = 0          //乘坐人数
    var on_station_infos:Array<Any>?        //线路站点信息
    var off_station_infos:Array<Any>?       //线路站点信息
    
    func routeStateToName() -> String? {
        
        switch CommuteRouteState(rawValue:self.route_state)! {
        case .Bought:
            return "买过"
        case .Nearby:
            return"附近"
        default:
            return nil
        }

    }
    //HH:mm:ss 转换 成 HH:mm
    func timeFormat(timeString:String?) -> String {
        
        if timeString == nil || timeString == ""{
            return ""
        }
        
        let timeDate:Date = DateUtils.date(from: timeString, format: "HH:mm:ss")
        return DateUtils.formatDate(timeDate, format: "HH:mm")
    }
    
    //mj解析使用
    override open static func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["on_station_infos": StationInfo.self,"off_station_infos": StationInfo.self];
    }
}
