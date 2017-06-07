//
//  CityObj.swift
//  FeiNiu_User
//
//  Created by tianbo on 2017/4/27.
//  Copyright © 2017年 tianbo. All rights reserved.
//

import UIKit

class CityObj: BaseModel {
    var adcode:String?         //城市代码
    var city_name:String?      //城市名称
    var company_name:String?   //公司名称
    var disabled:String?       //是否禁用
    var province_code:String?  //开通城市所对应的省级CODE
    var province_name:String?  //开通城市所对应的省级名称
    var site_level:Int = 0           //站点等级
    var tag:Int = 0                  //标签
    var central_latitude:Double = 0.0  //纬度
    var central_longitude:Double = 0.0 //经度
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.adcode = aDecoder.decodeObject(forKey: "adcode") as! String?
        self.city_name = aDecoder.decodeObject(forKey: "city_name") as! String?
        self.company_name = aDecoder.decodeObject(forKey: "company_name") as! String?
        self.disabled = aDecoder.decodeObject(forKey: "disabled") as! String?
        self.province_code = aDecoder.decodeObject(forKey: "province_code") as! String?
        self.province_name = aDecoder.decodeObject(forKey: "province_name") as! String?
//        self.site_level = aDecoder.decodeInteger(forKey: "site_level")
//        self.tag = aDecoder.decodeInteger(forKey: "tag")
//        self.central_latitude = aDecoder.decodeDouble(forKey: "central_latitude")
//        self.central_longitude = aDecoder.decodeDouble(forKey: "central_longitude")
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.adcode, forKey: "adcode")
        aCoder.encode(self.city_name, forKey: "city_name")
        aCoder.encode(self.company_name, forKey: "company_name")
        aCoder.encode(self.disabled, forKey: "disabled")
        aCoder.encode(self.province_code, forKey: "province_code")
        aCoder.encode(self.province_name, forKey: "province_name")
        aCoder.encode(self.site_level, forKey: "site_level")
        aCoder.encode(self.tag, forKey: "tag")
        aCoder.encode(self.central_latitude, forKey: "central_latitude")
        aCoder.encode(self.central_longitude, forKey: "central_longitude")
    }
}



class StationObj: BaseModel {
    var station_id:String?       //站点id
    var id:String?               //id
    var name:String?             //名称
    var address:String?          //地址
    var longitude:Double = 0.0        //经度
    var latitude:Double = 0.0         //纬度
    var type:Int = 0                //类型 (机场 1 火车站2 汽车站3)
    var adcode:String?
    var standard_code:String?
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.station_id = aDecoder.decodeObject(forKey: "station_id") as! String?
        self.name = aDecoder.decodeObject(forKey: "name") as! String?
        self.address = aDecoder.decodeObject(forKey: "address") as! String?
//        self.longitude = aDecoder.decodeDouble(forKey: "longitude")
//        self.latitude = aDecoder.decodeDouble(forKey: "latitude")
//        self.type = aDecoder.decodeInteger(forKey: "type")
//        self.adcode = aDecoder.decodeObject(forKey: "adcode") as! String?
//        self.standard_code = aDecoder.decodeObject(forKey: "standard_code") as! String?
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.station_id, forKey: "station_id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.address, forKey: "address")
        aCoder.encode(self.longitude, forKey: "longitude")
        aCoder.encode(self.latitude, forKey: "latitude")
        aCoder.encode(self.type, forKey: "type")
        aCoder.encode(self.adcode, forKey: "adcode")
        aCoder.encode(self.standard_code, forKey: "standard_code")
    }
}



class CoordinateObj: BaseModel {
    var longitude:Double = 0.0        //经度
    var latitude:Double = 0.0         //纬度
    var sort:Int = 0                  //排序
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
//        self.longitude = aDecoder.decodeDouble(forKey: "longitude")
//        self.latitude = aDecoder.decodeDouble(forKey: "latitude")
//        self.sort = aDecoder.decodeInteger(forKey: "sort")
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.longitude, forKey: "longitude")
        aCoder.encode(self.latitude, forKey: "latitude")
        aCoder.encode(self.sort, forKey: "sort")
    }
}


class FenceObj: BaseModel {
    var name:String?             //名称
    var id:String?               //id
    var business_module:String?  //业务类型
    var adcode:String?           //区域代码
    var priority:Int = 0         //优先级
    var disabled:Bool = false         //是否禁用
    var fences:Array<CoordinateObj>?           //围栏数据
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.name = aDecoder.decodeObject(forKey: "name") as! String?
        self.id = aDecoder.decodeObject(forKey: "id") as! String?
        self.business_module = aDecoder.decodeObject(forKey: "business_module") as! String?
        self.adcode = aDecoder.decodeObject(forKey: "adcode") as! String?
//        self.priority = aDecoder.decodeInteger(forKey: "priority")
//        self.disabled = aDecoder.decodeBool(forKey: "disabled")
//        self.fences = aDecoder.decodeObject(forKey: "fences") as! Array<CoordinateObj>?

    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.business_module, forKey: "business_module")
        aCoder.encode(self.adcode, forKey: "adcode")
        aCoder.encode(self.priority, forKey: "priority")
        aCoder.encode(self.disabled, forKey: "disabled")
        aCoder.encode(self.fences, forKey: "fences")
    }
}
