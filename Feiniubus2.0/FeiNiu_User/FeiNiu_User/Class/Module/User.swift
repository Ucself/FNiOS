//
//  User.swift
//  FeiNiu_User
//
//  Created by tianbo on 2017/4/27.
//  Copyright © 2017年 tianbo. All rights reserved.
//

import UIKit

class User: BaseModel {

    var id:String?
    var phone:String?
    var name:String?
    var avatar:String?
//    var base64:String?
    var gender:String?
//    var email:String?
//    var birthday:String?
//    var create_time:String?
//    var register_terminal:String?
//    var last_login_time:String?
//    var disabled:Bool = false
    
//    userType
//    nickName
//    accumulateMileage
//    token
//    couponsAmount
//    phoneType
//    registrationId
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.id = aDecoder.decodeObject(forKey: "id") as! String?
        self.phone = aDecoder.decodeObject(forKey: "phone") as! String?
        self.name = aDecoder.decodeObject(forKey: "name") as! String?
        self.avatar = aDecoder.decodeObject(forKey: "avatar") as! String?
//        if aDecoder.decodeObject(forKey: "base64") != nil {
//            <#code#>
//        }
//        self.base64 = aDecoder.decodeObject(forKey: "base64") as! String?
//        self.gender = aDecoder.decodeObject(forKey: "gender") as! String?
//        self.email = aDecoder.decodeObject(forKey: "email") as! String?
//        self.birthday = aDecoder.decodeObject(forKey: "birthday") as! String?
//        self.create_time = aDecoder.decodeObject(forKey: "create_time") as! String?
//        self.register_terminal = aDecoder.decodeObject(forKey: "register_terminal") as! String?
//        self.last_login_time = aDecoder.decodeObject(forKey: "last_login_time") as! String?
//        self.disabled = aDecoder.decodeBool(forKey: "disabled")
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.phone, forKey: "phone")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.avatar, forKey: "avatar")
//        aCoder.encode(self.base64, forKey: "base64")
//        aCoder.encode(self.gender, forKey: "gender")
//        aCoder.encode(self.email, forKey: "email")
//        aCoder.encode(self.birthday, forKey: "birthday")
//        aCoder.encode(self.create_time, forKey: "create_time")
//        aCoder.encode(self.register_terminal, forKey: "register_terminal")
//        aCoder.encode(self.last_login_time, forKey: "last_login_time")
//        aCoder.encode(self.disabled, forKey: "disabled")
    }
    
}
