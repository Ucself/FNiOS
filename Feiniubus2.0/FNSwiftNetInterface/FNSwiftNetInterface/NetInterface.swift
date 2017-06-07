//
//  NetInterface.swift
//  FNNetInterface
//
//  Created by lbj@feiniubus.com on 16/8/22.
//  Copyright © 2016年 FN. All rights reserved.
//

import UIKit
import Alamofire

open class NetInterface: NSObject {
    //单例 
    open static let shareInstance = NetInterface().passCertificate()
    fileprivate override init() { super.init() }
    //httpHeader鉴权字典
    open var httpHeader: [String:String] = [:]
    //设置鉴权字符串
    open func setAuthorization(_ httpHeader:[String:String]) {
        self.httpHeader = httpHeader;
    }

    //MARK: Request
    //普通数据提交
    open func httpRequest(_ requstMethod:EMRequstMethod,
                            strUrl:String,
                            body :[String: AnyObject]?,
                            successBlock:@escaping ((String) ->Void),
                            failedBlock:@escaping ((String, NSError) ->Void)) ->Void {
        var  alamofireRequestMethod:HTTPMethod = HTTPMethod.get
        var encodingType:ParameterEncoding = URLEncoding.default
        httpHeader.removeValue(forKey: "Content-Type")
        switch requstMethod {
        case .emRequstMethod_GET:
            alamofireRequestMethod = HTTPMethod.get
            encodingType = URLEncoding.default
        case .emRequstMethod_POST:
            alamofireRequestMethod = HTTPMethod.post
            encodingType = JSONEncoding.default
        case .emRequstMethod_PUT:
            alamofireRequestMethod = HTTPMethod.put
            encodingType = JSONEncoding.default
        case .emRequstMethod_DELETE:
            alamofireRequestMethod = HTTPMethod.delete
            encodingType = JSONEncoding.default
        }
        
        let requestObj:DataRequest = Alamofire.request(strUrl, method: alamofireRequestMethod, parameters: body, encoding: encodingType, headers: httpHeader)
        //处理响应数据
        self.responseOperation(requestObj, successBlock: successBlock, failedBlock: failedBlock)
    }
    //From提交
    open func httpFormRequest(_ requstMethod:EMRequstMethod,
                            strUrl:String,
                            body :[String: AnyObject]?,
                            successBlock:@escaping ((String) ->Void),
                            failedBlock:@escaping ((String, NSError) ->Void)) ->Void {
        let alamofireRequestMethod:HTTPMethod = HTTPMethod.post
        httpHeader["Content-Type"] = "application/x-www-form-urlencoded"
        let requestObj:DataRequest = Alamofire.request(strUrl, method: alamofireRequestMethod, parameters: body, encoding: JSONEncoding.default, headers: httpHeader)
        //处理响应数据
        self.responseOperation(requestObj, successBlock: successBlock, failedBlock: failedBlock)
    }
    
    //MARK: Private
    //处理响应数据
    fileprivate func responseOperation(_ requestObj:DataRequest,
                                   successBlock:@escaping ((String) ->Void),
                                   failedBlock:@escaping ((String, NSError) ->Void)) ->Void{
        print("-----> \(requestObj.debugDescription)\n")
        //数据返回
        requestObj.validate(statusCode: 200..<300)
            .responseData { (response) in
                let responseData = response.data
                //let responseString:String = NSString(data: responseData!, encoding: NSUTF8StringEncoding)! as String
                let responseString:String = NSString(data: responseData!, encoding: String.Encoding.utf8.rawValue)! as String
                switch response.result {
                case .success:
                    successBlock(responseString)
                    print("-----> success:\(responseString)\n")
                case .failure(let error):
                    failedBlock(responseString, error as NSError)
                    print("-----> error:\(error)\n")
                }
        }
    }
    
    //绕过证书
    fileprivate func passCertificate() -> Self  {
        let manager = SessionManager.default
        manager.delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    credential = manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            return (disposition, credential)
        }
        
        return self;
    }
}



















