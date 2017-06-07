//
//  Order.swift
//  FeiNiu_Business
//
//  Created by tianbo on 16/9/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class Order: NSObject {
    //字段名称解释
    //https://code.feelbus.cn/Platform/Harrenhal/wikis/stationorderquery
    var id:String?
    var adcode:String?
    var city_name:String?
    var create_time:String?
    var creator_id:String?
    var order_type:String?
    var car_type:String?
    var flight_number:String?
    var flight_time:String?
    var use_time:String?
    var starting:String?
    var destination:String?
    var people_number:Int = 0
    var comment:String?
    var price:Int = 0
    var merchant_id:String?
    var order_state:String?
    var payment_state:String?
    var contacts:[contactsObject]?
    //重写mj_json  的方法
//    internal func objectClassInArray(keyValuesArray: AnyObject!) -> NSDictionary{
//        return [ "contacts" : "contactsObject" ]
//    }
    internal override static func mj_objectClassInArray() -> [AnyHashable: Any]!{
        return [ "contacts" : contactsObject.self ]
    }
    
}

class contactsObject:NSObject  {
    var name:String?
    var phone:String?
    var _description:String?
    var contact_read_state:String?
    var id:NSObject?
    
}


