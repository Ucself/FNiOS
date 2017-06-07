//
//  NetInterfaceManager.swift
//  FNNetInterface
//
//  Created by lbj@feiniubus.com on 16/8/25.
//  Copyright © 2016年 FN. All rights reserved.
//

import UIKit

public let KNotification_RequestFinished:String = "HttpRequestFinishedNoitfication"
public let KNotification_RequestFailed:String = "HttpRequestFailedNoitfication"
public let KNotification_AuthenticationFail:String =  "AuthenticationLogicFailNoitfication"



open class NetInterfaceManager: NSObject {
    
    //单例
    open static let shareInstance = NetInterfaceManager()
    fileprivate override init() { super.init() }
    
    fileprivate var recordUrl:String?
    fileprivate var recordBody:NSDictionary?
    fileprivate var recordRequestType:Int = 0
    fileprivate var recordRequestMothed:EMRequstMethod = .emRequstMethod_GET
    fileprivate var controllerId:String?
    
    open func setAuthorization(_ httpHeader:[String:String]) -> Void{
        NetInterface.shareInstance.setAuthorization(httpHeader)
    }
    
    open func getAuthorization() ->[String:String]{
        return NetInterface.shareInstance.httpHeader;
    }
    
    //MARK: Request
    open func sendRequstWithType(_ type:Int,block:((_ params:NetParams)->Void)) -> Void{
        
        let params:NetParams = NetParams.init()
        block(params);
//        guard let url:String? = UrlMaps.shareInstance.urlWithTypeNew(type) else {return}
        let url:String? = UrlMaps.shareInstance.urlWithTypeNew(type)
        
        let bodyDic:NSDictionary? = params.data as? NSDictionary
        NetInterface.shareInstance.httpRequest(params.method!, strUrl:url!, body:bodyDic as? [String:AnyObject], successBlock: { (msg) in
            self.successHander(msg, reqestType: type)
            }, failedBlock: { (msg, error) in
                self.failedHander(msg, error: error, reqestType: type)
        })
        
        
    }
    
    open func sendFormRequstWithType(_ type:Int, block:((_ params:NetParams)->Void)) -> Void{
        
        let params:NetParams = NetParams.init()
        block(params);
//        guard let url:String? = UrlMaps.shareInstance.urlWithTypeNew(type) else {return}
        let url:String? = UrlMaps.shareInstance.urlWithTypeNew(type)
        
        let bodyDic:NSDictionary? = params.data as? NSDictionary
        NetInterface.shareInstance.httpFormRequest(EMRequstMethod.emRequstMethod_POST, strUrl:url!, body:bodyDic as? [String:AnyObject], successBlock: { (msg) in
                self.successHander(msg, reqestType: type)
            }, failedBlock: { (msg, error) in
                self.failedHander(msg, error: error, reqestType: type)
            })
    
    }
    //MARK: Private
    //返回成功处理
    fileprivate func successHander(_ msg:String, reqestType:Int) ->Void{
        let data:Data = msg.data(using: String.Encoding.utf8)!
        var dict:AnyObject?
        if data.count > 0 {
            do{
                dict = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as AnyObject
            }
            catch{
                dict = nil
            }
        }
        
        let result:NetResultDataModel = NetResultDataModel.initWithDictionary(dict!, reqestType: reqestType)
        if result.code == EMResultCode.emCode_Success.rawValue {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: KNotification_RequestFinished), object: result)
            }
        }
        else{
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name(rawValue: KNotification_RequestFailed), object: result)
            }
        }
    
    }
    //返回失败处理
    fileprivate func failedHander(_ msg:String, error:NSError, reqestType:Int) ->Void{
        let data:Data = msg.data(using: String.Encoding.utf8)!
        var dict:AnyObject?
        if data.count > 0 {
            do{
                dict = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as AnyObject
            }
            catch{
                dict = nil
            }
        }
        
        
        DispatchQueue.main.async {
            let result:NetResultDataModel = NetResultDataModel.initWithErrorInfo(dict, error: error, reqestType: reqestType)
            if result.code == EMResultCode.emCode_TokenOverdue.rawValue{
                NotificationCenter.default.post(name: Notification.Name(rawValue: KNotification_AuthenticationFail), object: result)
            }
            else{
                NotificationCenter.default.post(name: Notification.Name(rawValue: KNotification_RequestFailed), object: result)
            }
        }
        
    }
    
    
    //MARK: recod
    fileprivate func recodRequest(_ strUrl:String, body:NSDictionary, requestType:Int, mothed:EMRequstMethod){
        //记录一次请求数据
        recordUrl           = strUrl;
        recordBody          = body;
        recordRequestType   = requestType;
        recordRequestMothed = mothed;
    }
    
    open func reloadRecordData()->Void{
        if (recordUrl != nil && recordBody != nil) {
            NetInterface.shareInstance.httpFormRequest(recordRequestMothed, strUrl:recordUrl!, body:recordBody! as! [String : AnyObject], successBlock: { (msg) in
                    self.successHander(msg, reqestType:self.recordRequestType)
                }, failedBlock: { (msg, error) in
                    self.failedHander(msg, error: error, reqestType:self.recordRequestType)
            })
        }
    }
    
    open func setReqControllerId(_ cId:String) -> Void{
        controllerId = cId;
    }
    
    open func getReqControllerId()->String{
        return controllerId!;
    }
}











