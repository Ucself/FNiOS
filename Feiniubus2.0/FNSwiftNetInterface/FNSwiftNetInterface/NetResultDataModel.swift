//
//  ResultDataModel.swift
//  FNNetInterface
//
//  Created by lbj@feiniubus.com on 16/8/30.
//  Copyright © 2016年 FN. All rights reserved.
//

import UIKit
import Alamofire

public enum EMResultCode:Int{
    case emCode_Success    = 1            //成功
    case emCode_Unkown     = 100          //未知
    case emCode_ParamError = 101          //参数不正确
    case emCode_AuthError  = 102          //鉴权失败
    case emCode_SysError   = 103          //系统资源不足
    case emCode_RefreshTokenError   = 400 //刷新token失败
    case emCode_TokenOverdue   = 401      //token过期
    
}

open class NetResultDataModel: NSObject {
    //请求接口类型
    open var type:Int = -1
    //返回码
    open var code:Int = -1
    //消息内容
    open var message:String?
    //响应数据
    open var data:AnyObject?
    
    //MARK: serialization
    //成功处理
    open static func initWithDictionary(_ dict:AnyObject?, reqestType:Int) -> NetResultDataModel{
        let resultDataModelObject:NetResultDataModel = NetResultDataModel();
        if (dict == nil) {
            return resultDataModelObject
        }
        
        //code
        if let code = (dict!["code"] as? Int)  {
            resultDataModelObject.code = code
        }
        else {
            resultDataModelObject.code = EMResultCode.emCode_Success.rawValue
        }
        //data  所有返回数据都为数据，没有data里面装数据的说法
        //        if let data = (dict!["data"] as? NSObject) {
        //            resultDataModelObject.data = data
        //        }
        //        else {
        //            resultDataModelObject.data = dict
        //        }
        resultDataModelObject.data = dict
        resultDataModelObject.message = dict!["message"] as? String ?? ""
        resultDataModelObject.type = reqestType
        
        if resultDataModelObject.code != EMResultCode.emCode_Success.rawValue {
            resultDataModelObject.message = "授权失败, 请重新登录"
        }
        
        return resultDataModelObject;
    }
    //失败处理
    open static func initWithErrorInfo(_ dict:AnyObject?, error:NSError?, reqestType:Int) -> NetResultDataModel{
        let resultDataModelObject:NetResultDataModel = NetResultDataModel();
        resultDataModelObject.type = reqestType
        resultDataModelObject.code = error!.code
        //AF返回的AF错误对象
        if let tempAFError = (error as! Error) as? AFError {
            resultDataModelObject.code = tempAFError.responseCode!
            if dict is NSArray {
                var allMessage:String = ""
                for item in (dict as! [AnyObject]) {
                    allMessage += item["error_description"] as? String ?? "unknow"
                }
                resultDataModelObject.message = allMessage
            }
            else if dict is NSDictionary{
                resultDataModelObject.message = dict!["error_description"] as? String ?? "unknow"
            }
            else{
                resultDataModelObject.message = "亲，数据获取失败，请重试!"
            }
        }
        else{
            switch resultDataModelObject.code {
            case NSURLErrorNotConnectedToInternet:
                resultDataModelObject.message = "亲，你的网络不给力，请检查网络!"
            default:
                resultDataModelObject.message = "亲，数据获取失败，请重试!"
            }
        }
        return resultDataModelObject;
    }
    
}


















