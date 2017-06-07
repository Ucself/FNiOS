//
//  OrderDetail.swift
//  FeiNiu_Merchant
//
//  Created by lbj@feiniubus.com on 16/9/19.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class OrderDetail: NSObject {
    //字段解释参照 https://code.feelbus.cn/Platform/Harrenhal/wikis/stationorderdetailquery
    var adcode:String?
    var car_type:String?
    var cars:[carsObject]?
    var city_name:String?
    var comment:String?
    var contacts:[contactsObject]?
    var create_time:String?
    var creator:String?
    var destination:String?
    var dispatchs:[dispatchsObject]?
    var fare = 0
    var flight_number:String?
    var flight_time:String?
    var id:String?
    var merchant_id:String?
    var night_charge = 0
    var order_state:String?
    var order_type:String?
    var people_number = 0
    var price = 0
    var read_state:String?
    var starting:String?
    var use_time:String?
    
    internal override static func mj_objectClassInArray() -> [AnyHashable: Any]!{
        return [ "contacts" : contactsObject.self ,
                 "cars" : carsObject.self,
                 "dispatchs" : dispatchsObject.self]
    }
}

class carsObject: NSObject {
    var amount = 0
    var ferry_car_type_id:String?
    var price:Int = 0
    var seats:Int = 0
    
}

class dispatchsObject: NSObject {
    var bus_id:String?
    var driver_id:String?
    var license:String?
    var name:String?
    var people_number = 0
    var phone:String?
    var seats = 0
}
