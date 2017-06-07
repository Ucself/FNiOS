//
//  InviteViewController.swift
//  FeiNiu_User
//
//  Created by tianbo on 2017/3/23.
//  Copyright © 2017年 tianbo. All rights reserved.
//

import UIKit

class InviteViewController: UserBaseUIViewController {
    
    let kShareUrl         =  "target_url"
    let kShareTitle       =  "title"
    let kShareImageUrl    =  "image_url"
    let kShareDescription =  "message"
    let kShareLocImage    =  "locImage"
    let kShareLocDesc     =  "locDesc"
    
    var commuteId:String?
    var controller:UIViewController?
    
    @IBOutlet weak var labelDetail: UILabel!
    
    
    var content:NSDictionary?
    var image:UIImage?

    lazy var shareView:UISharePickerView? = Bundle.main.loadNibNamed("UISharePickerView", owner: nil, options: nil)?.first as? UISharePickerView
    override func viewDidLoad() {
        super.viewDidLoad()

        if commuteId == nil {
            self.stopWait()
            NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_Invite.rawValue)) { (params) in
                
            };
        }
        
    }
    
    deinit {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:  -
    func refreshUI() {
        guard let content = self.content else {
            return
        }
        
        let invite_count:String? = content["invite_count"] as? String
        let coupon_count:String? = content["coupon_count"] as? String
        self.labelDetail.text = "已成功推荐\(invite_count!)人, 累计获得\(coupon_count!)张优惠券"
    }
    
    func showInViewController() {
        self.view.isHidden = true
        self.controller?.addChildViewController(self)
        self.didMove(toParentViewController: self.controller)
        self.viewWillAppear(true)
        
        let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.showShareViewIn((self.controller?.view)!)
        }
        
        if commuteId != nil {
            self.startWait()
            NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteShare.rawValue)) { (params:NetParams?) in
                params?.data = ["id" : self.commuteId ?? ""]
            };
        }
    }
    func removeFromViewcontroller() {
        let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            if self.controller != nil {
                self.removeFromParentViewController()
            }
        }
        
    }
    
    func showShareViewIn(_ view:UIView) {
        shareView?.showInView(view)

        shareView?.selectAction = { [weak self] (type:EmShareType) in
            guard let strongSelf = self else { return}
            
            strongSelf.removeFromViewcontroller()
            switch type {
            case .Action_WxTimeLine:
                if UMSocialManager.default().isInstall(.wechatTimeLine) {
                    strongSelf.shareTo(type: .wechatTimeLine)
                }
                else {
                    strongSelf.showTipsView("未安装微信")
                }
            case .Action_Wx:
                if UMSocialManager.default().isInstall(.wechatSession) {
                    strongSelf.shareTo(type: .wechatSession)
                }
                else {
                    strongSelf.showTipsView("未安装微信")
                }
            case .Action_Sina:
                strongSelf.shareTo(type: .sina)
            case .Action_QQ:
                if UMSocialManager.default().isInstall(.QQ) {
                    strongSelf.shareTo(type: .QQ)
                }
                else {
                    strongSelf.showTipsView("未安装QQ")
                }
            case .Action_Qzone:
                if UMSocialManager.default().isInstall(.qzone) {
                    strongSelf.shareTo(type: .qzone)
                }
                else {
                    strongSelf.showTipsView("未安装Qzone")
                }
            case .Action_Cancel: break
            }
        }
    }
    
    
    //MARK:  -
    func getImage(block:@escaping (_ imge:UIImage? ) -> Void) {
        if self.image != nil {
            block(self.image)
        }
        else {
            
//            if let content = self.content {
//                guard let imageUrl:String = content[kShareImageUrl] as? String else { return }
//                NSLog(imageUrl)
//                
//                self.startWait()
//                SDWebImageManager.shared().loadImage(with: URL(string: imageUrl), options: .retryFailed, progress: {
//                    (receivedSize :Int, ExpectedSize :Int, targetURL:URL?) in
//                    
//                }, completed: { [weak self]
//                    (image : UIImage?, data : Data?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
//                    
//                    guard let strongSelf = self else { return}
//                    if image != nil {
//                        strongSelf.image = image
//                    }
//                    
//                    strongSelf.stopWait()
//                    block(strongSelf.image)
//                })
//            }
            
            self.startWait()
            let queue:OperationQueue = OperationQueue()
            queue.name = "GetShareImageQueue"
            queue.maxConcurrentOperationCount = 1
            queue.addOperation({
                if let content = self.content {
                    guard let url:String = content["image_url"] as? String else { return }
                    
                    if let imageData:Data = try? Data(contentsOf: URL(string: url)!) {
                        self.image = UIImage(data: imageData)
                    }
                    
                    let mainQueue:OperationQueue = OperationQueue.main
                    self.stopWait()
                    mainQueue.addOperation({ 
                        block(self.image)
                    })
                    
                }
            })
        }
    }
    func shareTo(type:UMSocialPlatformType) {
        if self.content == nil {
            self.showTip("暂未获取到分享内容，请稍候再试！", with: FNTipTypeFailure)
        }
        
        self.getImage { (image) in
            let messageObj:UMSocialMessageObject = UMSocialMessageObject()
            let shareObj:UMShareWebpageObject = UMShareWebpageObject.shareObject(withTitle: self.content?[self.kShareTitle] as! String,
                                                                                 descr: self.content?[self.kShareDescription] as! String,
                                                                                 thumImage: image)
            
            shareObj.webpageUrl = self.content?[self.kShareUrl] as! String;
            messageObj.shareObject = shareObj
            
            UMSocialManager.default().share(to: type, messageObject: messageObj, currentViewController: self, completion: { (data, error) in
                if error != nil {
                    NSLog("************Share fail with error \(error)*********");
                }else{
                    NSLog("response data is \(data)");
                }
            })
        }
    }
    
    @IBAction func btnInviteClick(_ sender: Any) {
        self.showShareViewIn(self.view)
    }
    
    @IBAction func btnCouponsClick(_ sender: Any) {
    }
    
    
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        self.stopWait()
        
        guard let result:ResultDataModel = notification.object as? ResultDataModel else { self.stopWait(); return}
        if result.type == Int32(EmRequestType_Invite.rawValue) {
            
            self.content = result.data as? NSDictionary
            
            self.refreshUI()
        }
        else if result.type == Int32(EmRequestType_CommuteShare.rawValue) {
            self.content = result.data as? NSDictionary
        }
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
    }
}
