//
//  NetParams.swift
//  FNNetInterface
//
//  Created by lbj@feiniubus.com on 16/8/29.
//  Copyright © 2016年 FN. All rights reserved.
//

import UIKit


public enum EMRequstMethod:Int {
    case emRequstMethod_GET = 0, emRequstMethod_POST, emRequstMethod_PUT, emRequstMethod_DELETE
}

open class NetParams: NSObject {
    
    open var method:EMRequstMethod?;  //请求方式
    open var data:AnyObject?;          //请求数据
    public override init() {
        super.init();
        method = .emRequstMethod_GET;
        data = nil;
    }
}
