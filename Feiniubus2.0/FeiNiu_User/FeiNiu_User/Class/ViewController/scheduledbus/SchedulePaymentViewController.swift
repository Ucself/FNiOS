//
//  SchedulePaymentViewController.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/11/29.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNPayment



struct payUIDataStruct {
    
    var onStationName:String?           //上车点
    var offStationName:String?          //下车点
    var useDate:Array<Any>?                  //乘车时间
    var tickCount:Int = 0             //票数
    var unitPrice:Int = 0          //单价
    var commuteObj:CommuteObj?           //班线信息
    var coupon:CouponObj?       //优惠卷信息
    var paymentCountdown:Int = 120  //支付倒计时
    var id:String?
    var price:Int = 0           //订单总价
    var promotion_price:Int = 0           //优惠后价格
    var discount:Int = 0        //优惠价格
    
}

class SchedulePaymentViewController: UserBaseUIViewController {
    
    @IBOutlet weak var labelOrig: UILabel!
    @IBOutlet weak var labelDest: UILabel!
    @IBOutlet weak var labelLine: UILabel!
    
    
    @IBOutlet weak var lableStart: UILabel!
    @IBOutlet weak var lableEnd: UILabel!
    @IBOutlet weak var labelSite: UILabel!
    
    
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelTicketCount: UILabel!
    @IBOutlet weak var labelUnitPrice: UILabel!
    @IBOutlet weak var labelTotalPrice: UILabel!
    @IBOutlet weak var labelCouponAmount: UILabel!
    @IBOutlet weak var btnPayUnion: UIButton!
    @IBOutlet weak var btnPayAli: UIButton!
    @IBOutlet weak var btnPayWechat: UIButton!
    @IBOutlet weak var btnCoupon: UIButton!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var btnConfirmPay: UIButton!
    
    
    @IBOutlet weak var imagPayAli: UIImageView!
    @IBOutlet weak var imagPayWechat: UIImageView!
    @IBOutlet weak var imagPayUnion: UIImageView!
    @IBOutlet weak var imagCoupon: UIImageView!
    //数据
    var orderInfor:payUIDataStruct = payUIDataStruct.init()
    var orderId:String?
    var strIds:String?
    var lineId:String?     //线路id
    
    //支付方式
    var payType:PayType = .Wechat
    
    var timer:Timer?
    var appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var timerIntervarl = 90
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fd_interactivePopDisabled = true;

        self.initUI()
        
        self.startTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParentViewController {
            self.endTimer()
        }
        
    }
    
    func initUI() {
        
        self.switchPayBtnStatus()
        //界面显示订单信息
        //        self.labelOrig.text = self.orderInfor.commuteObj?.line_departure
        //        self.labelDest.text = self.orderInfor.commuteObj?.line_arrival
        //路线
        let attchLine:NSTextAttachment = NSTextAttachment.init()
        attchLine.image = UIImage.init(named: "icon_line_303030")
        attchLine.bounds = CGRect.init(x: 0, y: 5, width: 19, height: 1)
        let lineString:NSAttributedString = NSAttributedString.init(attachment: attchLine)
        
        let attriLine:NSMutableAttributedString = NSMutableAttributedString.init(string: "\(self.orderInfor.commuteObj!.starting ?? "")\(self.orderInfor.commuteObj!.destination ?? "")")
        attriLine.insert(lineString, at: (self.orderInfor.commuteObj!.starting ?? "").characters.count)
        self.labelLine.attributedText = attriLine
        
        //        self.lableStart.text = "\(self.orderInfor.onStationName!)(上)"
        //        self.lableEnd.text = "\(self.orderInfor.offStationName!)(下)"
        //站点
        let attchSiteLine:NSTextAttachment = NSTextAttachment.init()
        attchSiteLine.image = UIImage.init(named: "icon_line_-828282")
        attchSiteLine.bounds = CGRect.init(x: 0, y: 3, width: 19, height: 1)
        let siteLineString:NSAttributedString = NSAttributedString.init(attachment: attchSiteLine)
        
        let attriSite:NSMutableAttributedString = NSMutableAttributedString.init(string: "\(self.orderInfor.onStationName!)(上)\(self.orderInfor.offStationName!)(下)")
        attriSite.insert(siteLineString, at: ("\(self.orderInfor.onStationName!)(上)").characters.count)
        self.labelSite.attributedText = attriSite
        
        self.labelDate.text = self.dateDisplay(useDate: self.orderInfor.useDate)
        self.labelTicketCount.text = "\(self.orderInfor.tickCount)张"
        
        self.labelUnitPrice.text = NSString.calculatePrice(self.orderInfor.unitPrice)   //单价
        self.labelTotalPrice.text = NSString.calculatePrice(self.orderInfor.price)      //总价
        //重置价格显示
        self.priceDisplayReset()
        
        //支付倒计时
        self.timerIntervarl = self.orderInfor.paymentCountdown
        if let time = DateUtils.timeFormatted(Int32(timerIntervarl)) {
            self.labelTime.text = "支付倒计时 \(time)"
        }
    }
    
    
    //日期显示使用
    func dateDisplay(useDate:Array<Any>?) -> String {
        let displayDateString:String = "乘车日期:"
        //数据转化
        let useDateArray:Array<String> = useDate != nil ? ((useDate as? Array<String>) ?? [String]()) : [String]()
        //字典定义
        var useDateDic:Dictionary<String,Array<String>> = [:]  //定义一个空字典
        for i in 0 ..< useDateArray.count {
            let toDate:Date = DateUtils.date(from: useDateArray[i], format: "yyyy-MM-dd HH:mm:ss")
            let monthName:String = DateUtils.formatDate(toDate, format: "MM")
            let dayName:String = DateUtils.formatDate(toDate, format: "dd")
            if useDateDic[monthName] == nil {
                useDateDic[monthName] = Array.init()
            }
            useDateDic[monthName]?.append(dayName)
        }
        //月整体时间数组
        var monthArray:Array<String> = Array.init()
        for (key,value) in useDateDic {
            monthArray.append("\(key)月\(value.joined(separator: ","))日")
        }
        
        return displayDateString.appending(monthArray.joined(separator: ";"))
    }
    
    func switchPayBtnStatus () {
        switch payType {
        case .Union:
            self.imagPayUnion.image = UIImage.init(named: "icon_round_pressed")
            self.imagPayAli.image = UIImage.init(named: "icon_round")
            self.imagPayWechat.image = UIImage.init(named: "icon_round")
        case .Ali:
            self.imagPayUnion.image = UIImage.init(named: "icon_round")
            self.imagPayAli.image = UIImage.init(named: "icon_round_pressed")
            self.imagPayWechat.image = UIImage.init(named: "icon_round")
        case .Wechat:
            self.imagPayUnion.image = UIImage.init(named: "icon_round")
            self.imagPayAli.image = UIImage.init(named: "icon_round")
            self.imagPayWechat.image = UIImage.init(named: "icon_round_pressed")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: -
    override func navigationViewBackClick() {
        let alertView:UserCustomAlertView = UserCustomAlertView(title: " 确定取消购票吗？", message: "", delegate: self, buttons: ["取消购票", "继续购票"])
        alertView.delegate = self
        alertView.show(in: self.view)
    }
    
    override func userAlertView(_ alertView: UserCustomAlertView!, dismissWithButtonIndex btnIndex: Int) {
        if btnIndex == 0 {
            self.cancelAction()
        }
    }
    
    
    //MARK: - Timer
    func startTimer () {
        //设置可以后台运行
        self.appDelegate.needBgTask = true
        //记时开始
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerFunction), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
        
    }
    
    func endTimer() {
        timer?.invalidate()
        self.appDelegate.needBgTask = false
    }
    
    
    func timerFunction() {
        timerIntervarl = timerIntervarl - 1
        if timerIntervarl == 0 {
            self.endTimer()
            
            self.showTipsView("支付超时，请重新购票")
            self.cancelAction()
        }
        
        if let time = DateUtils.timeFormatted(Int32(timerIntervarl)) {
            self.labelTime.text = "支付倒计时 \(time)"
        }
        
    }

    
    func cancelAction() {
        _ = navigationController?.popViewController(animated:true)
        
        return;
        //请求取消购票
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteOrderCancel.rawValue)) { (params:NetParams?) in
            params?.method = .DELETE
            params?.data = ["id":self.orderId]
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //MARK: - action

    @IBAction func btnPayUnionClick(_ sender: Any) {
        self.payType = .Union
        self.switchPayBtnStatus()
    }
    @IBAction func btnPayAliClick(_ sender: Any) {
        self.payType = .Ali
        self.switchPayBtnStatus()
    }
    @IBAction func btnPayWechatClick(_ sender: Any) {
        self.payType = .Wechat
        self.switchPayBtnStatus()
    }
    
    @IBAction func btnCouponClick(_ sender: Any) {
        
        //取出adcode
        var requestAdcode:String = ""
        if let curCity = CityInfoCache.sharedInstance().commuteCurCity {
            requestAdcode = curCity.adcode ?? ""
        }
        
        var tikects:Array = [Any]()
        for itemString in self.orderInfor.useDate! {
            tikects.append(["quantity" : 1 , "date" : itemString])
        }
        
        let c:CouponsViewController = CouponsViewController.instanceFromStoryboard()
        c.selectedCoupon = self.orderInfor.coupon
        c.couponsParams = ["car_type":"Commute",
                           "order_type":"Commute",
                           "adcode":requestAdcode,
                           "line_id":self.lineId ?? "",
                           "tikects":tikects]
        //回调
        c.selectedCouponsCallback = {[weak self] (coupon:CouponObj?) -> Void in
            guard let strongSelf = self else { return}
            
            if coupon != nil {
                strongSelf.orderInfor.coupon = coupon
                //重置价格显示 服务器计价
                //strongSelf.priceDisplayReset()
                strongSelf.startWait()
                NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteOrderCalc.rawValue)) { (params:NetParams?) in
                    params?.method = .POST
                    params?.data = ["adcode":requestAdcode,
                                    "line_id":strongSelf.lineId ?? "",
                                    "coupon_id":coupon!.id ?? "0",
                                    "tickect_dates":tikects]
                }
            }
        }
        
        self.navigationController?.pushViewController(c, animated: true)
        
    }
    
    func priceDisplayReset(){
        //优惠后价格计算  此处不再计算价格
        var lastPrice = 0
        if self.orderInfor.coupon?.kind == "Fixed" {
            //定额支付现金券  后台的意思是减少一张票
            lastPrice = self.orderInfor.unitPrice * (self.orderInfor.tickCount - 1)
            //优惠卷显示修改
            self.labelCouponAmount.text = "单张车票"
        }
        else{
            //定额优惠现金券
            lastPrice = self.orderInfor.unitPrice * self.orderInfor.tickCount - Int(self.orderInfor.coupon?.value ?? 0)
            //优惠卷显示修改
            self.labelCouponAmount.text = NSString.calculatePrice(Int(self.orderInfor.coupon?.value ?? 0))
        }
        /*//最后价格显示
        if lastPrice <= 0 {
            self.btnConfirmPay.setTitle("确认支付 \(NSString.calculatePrice(1)!)", for: .normal)
        }
        else{
            self.btnConfirmPay.setTitle("确认支付 \(NSString.calculatePrice(lastPrice)!)", for: .normal)
        }*/
        
        self.btnConfirmPay.setTitle("确认支付 \(NSString.calculatePrice(self.orderInfor.promotion_price)!)", for: .normal)
        
    }
    
    @IBAction func btmCommitClick(_ sender: Any) {
        //验证复位
        validateNum = 0
        
        self.startWait()
        //取支付信息
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommutePayment.rawValue)) { (params:NetParams?) in
            
            var paramsDic:Dictionary = ["channel": self.payType.toString(),
                                        "order_class": "PassengerCommute",
                                        "order_id": self.orderId
            ]
            
            if let coupon = self.orderInfor.coupon {
                if coupon.id != nil {
                    paramsDic["coupon_id"] = coupon.id
                }
            }
            
            params?.method = .POST
            params?.data = paramsDic
        }
    }
    
    
    func payment(_ data:NSDictionary?)  {
        if let data = data {
            
            PaymentHelper.instance.pay(self.payType, data: data, controller:self, block: { [weak self] code in
                guard let strongSelf = self else { return}
                
                switch strongSelf.payType {
                case .Ali:
                    if code == .PaySuccess || code == .ErrCodePayProcessing {
                        strongSelf .paymetQuery()
                    }
                    else if code != .ErrCodeUserCancel {
                        strongSelf.showTip("支付失败, 请重新尝试", with: FNTipTypeFailure)
                    }
                case .Wechat:
                    if code == .PaySuccess || code == .ErrCodePayProcessing {
                        strongSelf .paymetQuery()
                    }
                    else if code == .WXNotInstalled {
                        strongSelf.showTip("没有安装微信", with: FNTipTypeFailure)
                    }
                    else if code != .ErrCodeUserCancel {
                        strongSelf.showTip("支付失败, 请重新尝试", with: FNTipTypeFailure)
                    }
                case .Union:
                    if code == .PaySuccess || code == .ErrCodePayProcessing {
                        strongSelf.paymetQuery()
                    }
                }
            })
        }
    }
    
    
    func paymetQuery() {
        self.startWait()
        self.endTimer()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_PaymentQuery.rawValue)) { (params:NetParams?) in
            params?.method = .GET
            params?.data = ["chargeId":self.charge_id];
        }
    }
    
    
    func gotoOrderDetail() {
        
        let controller:ScheduleTicketViewController = ScheduleTicketViewController.instance(withStoryboardName: "ScheduledOrder")
        let controllers:NSMutableArray =  NSMutableArray.init(array: (self.navigationController?.viewControllers)!)
        controllers.removeObjects(in: NSMakeRange(1, controllers.count-1))
        controllers.add(controller)

        
        self.navigationController?.setViewControllers((controllers as NSArray as? [UIViewController])!, animated: true)
    }
    
    
    //MARK: - http handler
    var validateNum:Int = 0
    var charge_id:String?
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        self.stopWait()
        
        guard let result:ResultDataModel = notification.object as? ResultDataModel else {return}
        if result.type == Int32(EmRequestType_CommutePayment.rawValue) {
            if let data:NSDictionary = result.data as? NSDictionary {
                
                self.charge_id = data["charge_id"] as? String
                //调起支付
                self.payment(data["credentials"] as? NSDictionary)
            }
            
        }
        else if result.type == Int32(EmRequestType_PaymentQuery.rawValue) {
            if let data:NSDictionary = result.data as? NSDictionary {
                let succeed:Bool = data["succeed"] as! Bool
                if succeed {
                    //通知支付成功
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: KPaySuccessNotification), object: nil)
                    //支付成功, 跳转订单详情
                    self.gotoOrderDetail()
                }
                else {
                    //失败重新查询一次
                    if self.payType == .Ali || self.payType == .Wechat {
                        if validateNum == 0 {
                            validateNum = 1
                            
                            self.startWait()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                self.paymetQuery()
                            }
                            
                        }
                        else {
                            NSLog("支付查询失败!")
                        }
                        
                    }
                }
            }
        }
        else if result.type == Int32(EmRequestType_CommuteOrderCalc.rawValue) {
            if let data:NSDictionary = result.data as? NSDictionary {
                //订单总价
                if let price = data["price"] {
                    self.orderInfor.price = price as? Int ?? 0
                }
                //优惠后价格
                if let promotion_price = data["promotion_price"] {
                    self.orderInfor.promotion_price = promotion_price as? Int ?? 0
                }
                ////优惠价格
                if let discount = data["discount"] {
                    self.orderInfor.discount = discount as? Int ?? 0
                }
                //刷新界面价格
                self.priceDisplayReset()
            }
        }
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
    }
    
}
