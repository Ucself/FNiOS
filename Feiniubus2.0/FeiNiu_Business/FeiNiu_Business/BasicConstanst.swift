//
//  BasicConstanst.swift
//  FeiNiu_Business
//
//  Created by tianbo on 16/9/8.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import Foundation



 // MARK: - system relative
let SYSVERSION    = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString")
let BUILDVERSION  = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion")

let ISIOS7LATER   = (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 7
let ISIOS8BEFORE  = (UIDevice.currentDevice().systemVersion as NSString).floatValue <  8

let deviceWidth   = UIScreen.mainScreen().bounds.size.width
let deviceHeight  = UIScreen.mainScreen().bounds.size.height
let deviceUUID    = UIDevice.currentDevice().identifierForVendor?.UUIDString


let NotifyEnterBackGround  = "enterBackGround"
let NotifyBecomeActive    = "becomeActive"


 // MARK: - common colors
let UIColor_DefGreen    = UIColor(hex: 0x24aa59)
let UIColor_DefOrange   = UIColor(hex: 0xfe6e35)
let UIColor_Background  = UIColor(hex: 0xf0f0f0)

// MARK: - text colors
let UITextColor_Black        = UIColor(hex: 0x4d4d4d)
let UITextColor_DarkGray     = UIColor(hex: 0x828282)
let UITextColor_LightGray    = UIColor(hex: 0xbbbbbb)


func UIColorFromRGB(hexRGB:UInt) -> UIColor {
    return UIColor(red: ((CGFloat)((hexRGB & 0xFF0000) >> 16))/255.0,
                   green: ((CGFloat)((hexRGB & 0xFF00) >> 8))/255.0,
                   blue: ((CGFloat)(hexRGB & 0xFF))/255.0,
                   alpha: 1.0)
}