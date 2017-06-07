//
//  AuthenticationLogic.swift
//  FeiNiu_Merchant
//
//  Created by lbj@feiniubus.com on 16/9/12.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNSwiftNetInterface

class AuthenticationLogic: NSObject {
    //单例
    static let shareInstance = AuthenticationLogic()
    fileprivate override init() { super.init() }
    
    var viewController:UIViewController?
    var isrefresh:Bool = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addUserData(_ viewController:UIViewController) -> Void {
        self.viewController = viewController
        NotificationCenter.default.addObserver(self, selector: #selector(httpRequestFinished), name: NSNotification.Name(rawValue: KNotification_RequestFinished), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(httpRequestFailed), name: NSNotification.Name(rawValue: KNotification_RequestFailed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authorizeNotification), name: NSNotification.Name(rawValue: KNotification_AuthenticationFail), object: nil)
    }
    
    func toLoginViewController() -> Void {
        let rootViewController:UIViewController = self.viewController!
        let storyboard = UIStoryboard.init(name: "Manager", bundle: nil)
        let logVC = storyboard.instantiateViewController(withIdentifier: "BNSLoginViewController") as! BNSLoginViewController
        logVC.finishedBlock = {
            logVC.dismiss(animated: true, completion: {
            })
        }
        
        let navVC:UINavigationController = UINavigationController.init(rootViewController: logVC)
        rootViewController.present(navVC, animated: true) {
            
        }
    }
    
    //MARK: notification
    func httpRequestFinished(_ notification:Notification) -> Void {
        let result:NetResultDataModel = notification.object as! NetResultDataModel
        if result.type ==  EMRequestType.emRequestType_PostTokenRefresh.rawValue{
            isrefresh = false;
            if let dicData = result.data as? NSDictionary {
                AuthorizeCache.sharedInstance().accessToken = dicData["access_token"] as? String
                AuthorizeCache.sharedInstance().refreshToken = dicData["refresh_token"] as? String
                AuthorizeCache.sharedInstance().userId = dicData["user_id"] as? String
                AuthorizeCache.sharedInstance().userName = dicData["user_name"] as? String
                //设置鉴权信息
                var  newAuthorizeHead:[String : String] = NetInterfaceManager.shareInstance.getAuthorization()
                newAuthorizeHead["Authorization"] = "Bearer " + AuthorizeCache.sharedInstance().accessToken
                NetInterfaceManager.shareInstance.setAuthorization(newAuthorizeHead)
            }
            NetInterfaceManager.shareInstance.reloadRecordData()
        }
        
    }
    
    func httpRequestFailed(_ notification:Notification) -> Void {
        let result:NetResultDataModel = notification.object as! NetResultDataModel
        if result.code == EMResultCode.emCode_RefreshTokenError.rawValue &&
           result.type ==  EMRequestType.emRequestType_PostTokenRefresh.rawValue{
            isrefresh = false;
            AuthorizeCache.sharedInstance().clean()
            self.toLoginViewController()
        }
    }
    
    func authorizeNotification(_ notification:Notification) -> Void {
        print("<--begin refresh token-->")
        //在刷新直接返回
        if isrefresh {
            return;
        }
        //没在刷新泽刷新
        isrefresh = true
        
        let result:NetResultDataModel = notification.object as! NetResultDataModel
        guard result.code == EMResultCode.emCode_TokenOverdue.rawValue &&
              result.type != EMRequestType.emRequestType_PostTokenRefresh.rawValue else{
                isrefresh = false
                return
        }
        //没有刷新token
        let token = AuthorizeCache.sharedInstance().refreshToken ?? ""
        if  token.isEmpty {
            self.toLoginViewController()
            return
        }
        
        NetInterfaceManager.shareInstance.sendRequstWithType(EMRequestType.emRequestType_PostTokenRefresh.rawValue) { (params) in
            params.method = EMRequstMethod.emRequstMethod_POST
            params.data = ["grant_type":"refresh_token",
                           "client_id":KClient_id,
                           "client_secret":KClient_secret,
                           "refresh_token":AuthorizeCache.sharedInstance().refreshToken ?? ""] as AnyObject
        }
        
    }
}








