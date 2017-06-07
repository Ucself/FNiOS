//
//  ShuttleModule.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/11/16.
//  Copyright © 2016年 tianbo. All rights reserved.
//
// 接送业务数据类

import UIKit


public enum ShuttleCategory:String {
    case AirportPickup = "AirportPickup"            //接机
    case AirportSend   = "AirportSend"              //送机
    case TrainPickup   = "TrainStationPickup"       //接火车
    case TrainSend     = "TrainStationSend"         //送火车
    case BusPickup     = "BusStationPickup"         //接汽车
    case BusSend       = "BusStationSend"           //送汽车
    
    public var titles: Array<String> {
        switch self {
        case .AirportPickup, .AirportSend:
            return ["接机", "送机"]
        case .TrainPickup, .TrainSend:
            return ["接火车", "送火车"]
        case .BusPickup, .BusSend:
            return ["接汽车", "送汽车"]
        }
    }
    
    public func toInt() -> Int {
        switch self {
        case .AirportPickup:
            return 1
        case .AirportSend:
            return 2
        case .TrainPickup:
            return 3
        case .TrainSend:
            return 4
        case .BusPickup:
            return 5
        case .BusSend:
            return 6
        }
    }
}

public enum UseCarType:String {
    case CarPool       = "CarPool"           //拼车
    case Chartered     = "Charter"           //包车
}

public enum BusinessType:String {
    case Dedicated     = "Dedicated"         //接送机
    case Transfer      = "Transfer"          //中转车
    
    public func toString() -> String {
        switch self {
        case .Dedicated:
            return "Station"
        case .Transfer:
            return "Transfer"
        }
    }
}

//public struct StLocation {
//    var latitude:Double?
//    var longitude:Double?
//    var name:String?
//    
//    init(longitude:Double?,  latitude:Double?, name:String?) {
//        self.longitude = longitude
//        self.latitude  = latitude
//        self.name = name
//    }
//}
//
//public struct StFlight {
//    var flight_number:NSString?     //航班号
//    var flight_time:NSString?         //起飞或落地时间
//    var flight_date:NSString?       //航班日期 全时间
//    var start_city:NSString?    //出发城市
//    var end_city:NSString?        //到达城市
//    
//    init(flight_number:NSString?,
//         flight_time:NSString?,
//         flight_date:NSString?,
//         start_city:NSString?,
//         end_city:NSString?)
//    {
//        self.flight_number = flight_number
//        self.flight_time = flight_time
//        self.flight_date = flight_date
//        self.start_city = start_city
//        self.end_city = end_city
//    }
//}

open class ShuttleModule: NSObject {
    

    var phone:String?                    //电话
    var use_time:Date?                   //用车时间
    var person_number:Int = 1            //乘车人数
    var start_place:FNLocation?          //起点位置
    var end_place:FNLocation?            //终点位置
    var flight:FlightInforObj?           //航班信息
    var adcode:String?                   //区域代码
    var source:String = "PG"             //来源
    var mileage:Double = 0               //里程
    var comment:String?                  //乘客备注
    var contact_name:String?             //联系人名字
    var call_for_others:Int = 0          //是否为他们叫车
    var use_car_type:UseCarType = .CarPool                //用车类型
    var order_type:ShuttleCategory = .AirportPickup       //订单接送类型
    var business_type:BusinessType = .Dedicated           //业务类型
    var station_id:String?           //车站id
    var substation_id:String?           //子站点id
    var dateSelectMethod:Int = 0     //0代表普通时间，1代表航班到达后时间
    var dep_station:Array = [StationObj]()   //航站楼到达或者出发信息
    
    //返回下单字典
    open func toOrderDictionary() -> NSDictionary {
        
        return ["people_number":   person_number,
                "starting":        start_place?.name! as Any,
                "s_latitude":      start_place?.latitude as Any,
                "s_longitude":     start_place?.longitude as Any,
                "destination":     end_place?.name as Any,
                "d_latitude":      end_place?.latitude as Any,
                "d_longitude":     end_place?.longitude as Any,
                "remark":          comment as Any,
                "adcode":          adcode as Any,
                "mileage":         mileage,
                
                "flight_number":   flight?.flight_number as Any,
                "dep_full_time":   flight?.dep_full_time as Any,
                "arr_full_time":   flight?.arr_full_time as Any,
                "fcategory":       flight?.fcategory as Any,
                "flight_dep_code": flight?.flight_dep_code as Any,
                "flight_arr_code": flight?.flight_arr_code as Any,
                "car_type":        use_car_type.rawValue,
                "order_type":      order_type.rawValue,
                "use_time":        DateUtils.formatDate(use_time, format: "yyyy-MM-dd HH:mm:ss"),
                "order_source":    source,
                "contact_phone":   phone as Any,
                "contact_name":    contact_name as Any,
                "station_id" :     station_id as Any,
                "substation_id":   substation_id as Any]
        
    }
    
    //返回计算价格字典
    open func toPriceDictionary() -> NSDictionary {
        let dict:NSDictionary =  ["adcode":       adcode as Any,
                               "people_number":   person_number,
                               "car_type":        use_car_type.rawValue,
                               "order_type":      order_type.rawValue,
                               //"business_type":   business_type.rawValue,
                               "use_time":        DateUtils.formatDate(use_time, format: "yyyy-MM-dd HH:mm:ss") ,
                               "s_latitude":      start_place?.latitude as Any,
                               "s_longitude":     start_place?.longitude as Any,
                               "d_latitude":      end_place?.latitude as Any,
                               "d_longitude":     end_place?.longitude as Any,
                               "station_id":      station_id as Any]
        return dict
        
    }
}
