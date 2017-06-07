//
//  FlightInforObj.swift
//  FeiNiu_User
//
//  Created by tianbo on 2017/4/20.
//  Copyright © 2017年 tianbo. All rights reserved.
//


class FlightInforObj: NSObject {
    
    var arr_airport:String?          //到达机场
    var arr_city:String?             //到达城市
    var arr_terminal:String?         //到达航站楼
    var arr_time:String?             //到达时间(例如 16:20)
    var arr_full_time:String?        //到达时间(例如 2016-10-31 16:20)
    
    var dep_airport:String?          //起飞机场
    var dep_city:String?             //起飞城市
    var dep_terminal:String?         //起飞航站楼
    var dep_time:String?             //起飞时间(例如 15:10)
    var dep_full_time:String?        //起飞时间(例如 2016-10-31 15:10)
    
    var flight_number:String?        //搜索航班号
    var flight_dep_code:String?      //航班起飞机场代码
    var flight_arr_code:String?      //航班降落机场代码

    var is_international_flight:Bool = false    //是否国际航班
    
    var air_company_name:String?      //航空公司名称
    var flight_date:String?          //航班日期
    var fcategory:String?            //航班类别
    var act_arr_full_time:String?    //航班实际到达日期
    var act_dep_full_time:String?    //航班实际起飞时间
    
    //本地数据
    var seachDate:String?            //搜索的时间
    var flight_state:String = ""     //航班状态
    var dep_station:NSArray?  //出发机场站点
    var arr_station:NSArray?  //到达机场站点
    
    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["arr_station": StationObj.self,"dep_station": StationObj.self];
    }
}
