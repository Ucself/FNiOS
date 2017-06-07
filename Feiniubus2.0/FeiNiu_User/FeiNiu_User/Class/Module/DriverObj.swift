//
//  DriverObj.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/11/22.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

open class DriverObj: NSObject {

    var adcode:String?
    //@breif 车ID
    var bus_id:String?
    //司机id
    var driver_id:String?
    //@breif 车牌
    var license:String?
    //头像
    var avatar:String?
    //名字
    var name:String?
    //电话
    var phone:String?
    //司机评分
    var score:Float = 0
    //车辆归属类型（1-自有车辆，2-合作公司）
    var bus_type:String?
    //车辆座位数
    var seats:Int = 0
    //起点纬度
    var latitude:Double = 0
    //起点经度
    var longitude:Double = 0
    
    /**
     * @breif 人数
     */
    var people_number:Int = 0
    
    var business_id:String?
    var task_begin_time:String?
    var task_id:String?

}
