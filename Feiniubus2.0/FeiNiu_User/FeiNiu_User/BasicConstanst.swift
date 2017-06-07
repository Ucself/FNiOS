//
//  BasicConstanst.swift
//  FeiNiu_Business
//
//  Created by tianbo on 16/9/8.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import Foundation
import UIKit


 // MARK: - system relative
let SYSVERSION    = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unkonw"
let BUILDVERSION  = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "unkonw"
let KWINDOW  = UIApplication.shared.keyWindow

let ISIOS7LATER   = (UIDevice.current.systemVersion as NSString).floatValue >= 7
let ISIOS8BEFORE  = (UIDevice.current.systemVersion as NSString).floatValue <  8
let ISIOS9BEFORE  = (UIDevice.current.systemVersion as NSString).floatValue <  9

let deviceWidth   = UIScreen.main.bounds.size.width
let deviceHeight  = UIScreen.main.bounds.size.height
let deviceUUID    = UIDevice.current.identifierForVendor?.uuidString


let NotifyEnterBackGround      = "enterBackGround"
let NotifyBecomeActive         = "becomeActive"


//菜单通知
let KShowMenuNotification       =   "ShowMenuNotification"
let KMenuDidSelectNotification  =   "MenuDidSelectNotification"
//登录成功通知
let KLoginSuccessNotification   =   "LoginSuccessNotification"
//退录登录通知
let KLogoutNotification         =   "LogoutNotification"
//订单状态更新通知
let KOrderRefreshNotification   =   "OrderRefreshNotification"

 // MARK: - common colors
let UIColor_DefGreen    = UIColorFromRGB(0x24aa59)
let UIColor_DefOrange   = UIColorFromRGB(0xfe6e35)
let UIColor_Background  = UIColorFromRGB(0xf9f9fd)

// MARK: - text colors
let UITextColor_Black        = UIColorFromRGB(0x303030)
let UITextColor_DarkGray     = UIColorFromRGB(0x828282)
let UITextColor_LightGray    = UIColorFromRGB(0xbbbbbb)
let UINavigationBKColor      = UIColorFromRGB(0xf4f4f8)
let UITranslucentBKColor     = UIColor.init(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5)

func UIColorFromRGB(_ hexRGB:UInt) -> UIColor {
    return UIColor(red: ((CGFloat)((hexRGB & 0xFF0000) >> 16))/255.0,
                   green: ((CGFloat)((hexRGB & 0xFF00) >> 8))/255.0,
                   blue: ((CGFloat)(hexRGB & 0xFF))/255.0,
                   alpha: 1.0)
}


