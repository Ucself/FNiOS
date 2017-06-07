//
//  NetInitialize.swift
//  FeiNiu_User
//
//  Created by tianbo on 2017/4/19.
//  Copyright © 2017年 tianbo. All rights reserved.
//

import UIKit
//import FNNetInterface

class NetInitialize: NSObject {

    func initNetInterface() {
        UrlMaps.sharedInstance().resetUrlMaps([EmRequestType_Login as! AnyHashable:UNI_Login])
    }
}
