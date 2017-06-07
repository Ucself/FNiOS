//
//  UrlMaps.swift
//  FNNetInterface
//
//  Created by lbj@feiniubus.com on 16/8/29.
//  Copyright © 2016年 FN. All rights reserved.
//

import UIKit

open class UrlMaps: NSObject {
    //单例
    open static let shareInstance = UrlMaps()
    fileprivate override init() { super.init() }
    
    fileprivate var urlMaps:NSDictionary?
    open func initMaps(_ dict:NSDictionary) -> Void{
        urlMaps = dict
    }
    
    open func urlWithTypeNew(_ type:Int) -> String {
        return urlMaps![type] as! String
    }
}
