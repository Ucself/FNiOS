//
//  ScheduleBuyViewController.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/11/29.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class ScheduleBuyViewController: UserBaseUIViewController, ScheduleCalendarViewDelegate {
    
    @IBOutlet weak var calendarView: ScheduleCalendarView!
    @IBOutlet weak var labelMonth: UILabel!
    
    @IBOutlet weak var labelPrice: UILabel! //优惠后价
    @IBOutlet weak var labelOriginalPrice: UILineLabel! //原价
    @IBOutlet weak var labelCount: UILabel! //折扣价
    @IBOutlet weak var priceCenterY: NSLayoutConstraint!
    
    @IBOutlet weak var btnBuy: UIButton!
    @IBOutlet weak var startText: UITextField!
    @IBOutlet weak var endText: UITextField!
    
    let pickerView:CustomPickerView = CustomPickerView.init(frame:CGRect.init(x: 0, y: 0, width: deviceWidth, height: deviceHeight),
                                                                 dataSourceArray: [],
                                                                 useType: 0)
    //请求需要的数据
    var onStationSelectedIndex:Int32 = -1
    var offStationSelectedIndex:Int32 = -1
    var ticketDate:Array = [Any]()
    //控件需要的数据
    var id:String?  //路线id
    var commuteObj:CommuteObj?  //路线信息
    var onStationInfor:NSMutableArray = NSMutableArray.init()  //上车点信息
    var offStationInfor:NSMutableArray = NSMutableArray.init()  //下车点信息
    var ticketInfo:NSArray = NSArray.init()  //余票信息
    
    
    var price:Int = 0           //下单全部原价
    var activityPrice:Int = 0   //下单全部活动价
    
    let dateFormatter:DateFormatter = DateFormatter()
    
    //MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendarView.delegate = self
        self.labelMonth.text = DateUtils.formatDate(Date(), format: "yyyy年MM月")
        self.requestSiteAndTicket()
        
        //显示数据
        if AuthorizeCache.sharedInstance().accessToken == nil ||
            AuthorizeCache.sharedInstance().accessToken == ""{
            self.labelCount.text = "登录后查看优惠价格"
        }
        else{
            self.labelCount.text = "共选择0张车票"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if needRefresh {
            needRefresh = false
            self.requestCouponBest(self.calendarView.getSelectItems())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initStationInfo(_ stationInfor: NSArray?) {
        if let array = stationInfor {
            self.onStationInfor.removeAllObjects();
            self.offStationInfor.removeAllObjects();
            
            for item  in array {
                let itemStationInfo:StationInfo = item as! StationInfo
                
                switch CommuteStationType(rawValue: itemStationInfo.station_type)! {
                case .Start,.On:
                    self.onStationInfor.add(item)
                    
                case .Off,.Terminal:
                    self.offStationInfor.add(item)
                default:
                    break
                }
                
                //后台传的默认显示站点和搜索过来的默认显示站点
                if commuteObj?.on_station?.name == nil && itemStationInfo.is_last_on_station == 1 {
                    commuteObj?.on_station = itemStationInfo
                }
                if commuteObj?.off_station?.name == nil && itemStationInfo.is_last_off_station == 1 {
                    commuteObj?.off_station = itemStationInfo
                }
            }
        }
        
        //默认显示站点信息
        if  commuteObj?.on_station?.name != nil && self.onStationInfor.count > 0{
            //上车点
            for item in 0..<self.onStationInfor.count {
                let stationInfo:StationInfo? = self.onStationInfor[item] as? StationInfo
                if stationInfo?.name == commuteObj?.on_station?.name {
                    self.startText.text = stationInfo?.name
                    self.onStationSelectedIndex = Int32(item)
                }
            }
        }
        if  commuteObj?.off_station?.name != nil && self.offStationInfor.count > 0{
            //下车点
            for item in 0..<self.offStationInfor.count {
                let stationInfo:StationInfo? = self.offStationInfor[item] as? StationInfo
                if stationInfo?.name == commuteObj?.off_station?.name {
                    self.endText.text = stationInfo?.name
                    self.offStationSelectedIndex = Int32(item)
                }
            }
        }
    }
    
    //MARK: - request
    //取车票
    func requestSiteAndTicket() {
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteTicket.rawValue), params: {(param:NetParams?) -> Void in
            
            //是否登录
            var islogin = "true"
            if AuthorizeCache.sharedInstance().accessToken == nil  ||
                AuthorizeCache.sharedInstance().accessToken == ""{
                islogin = "false"
            }
            
            param?.method = EMRequstMethod.GET
            param?.data = ["id" : self.id ?? "",
                           "islogin":islogin]
        })
    }
    //提交订单
    func requestOrderPost() {
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteOrderPost.rawValue), params: {(param:NetParams?) -> Void in
        
        let onStation:StationInfo? = self.onStationInfor[Int(self.onStationSelectedIndex)] as? StationInfo
        let offStation:StationInfo? = self.offStationInfor[Int(self.offStationSelectedIndex)] as? StationInfo
        
        //参数
        let onStationName = onStation?.name ?? ""
        let offStationName = offStation?.name ?? ""
        let onStationId = onStation?.id ?? ""
        let offStationId = offStation?.id ?? ""
            
        var commuteAdcode = ""
        if let commuteCurCity =  CityInfoCache.sharedInstance().commuteCurCity {
            commuteAdcode = commuteCurCity.adcode ?? ""
        }
        
        //tickets 数组新结构
        var tikects:Array = [Any]()
        for itemString in self.ticketDate {
            tikects.append(["quantity" : 1 , "date" : itemString])
        }
            
        param?.method = EMRequstMethod.POST
        param?.data = [ "line_id" : self.id ?? "",
                        "on_station" : onStationName,
                        "off_station": offStationName,
                        "on_station_id" : onStationId,
                        "off_station_id" : offStationId,
                        "phone": UserPreferences.sharedInstance().getUserInfo().phone,
                        "order_source": "PG",
                        "ticket_date": tikects,
                        "adcode":commuteAdcode]
            
        })
    }
    //计算价格
    func requestCouponBest(_ items: [Any]!) {
        
        var tikects:Array = [Any]()
        if items.count != 0 {
            for item in items {
                let ticket:TicketInfo = item as! TicketInfo
                tikects.append(["quantity" : 1 , "date" : ticket.date ?? ""])
            }
        }
        
        var commuteAdcode = ""
        if let commuteCurCity =  CityInfoCache.sharedInstance().commuteCurCity {
            commuteAdcode = commuteCurCity.adcode ?? ""
        }
        
        //登录后请求服务器获取优惠信息
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CouponBest.rawValue), params: {(param:NetParams?) -> Void in
            param?.method = EMRequstMethod.POST
            param?.data = ["btype" : "Commute",
                           "adcode" : commuteAdcode,
                           "quantity" : items.count,
                           "line_id" : self.commuteObj?.id ?? "",
                           "tikects" : tikects]
        })
    }
    
    
    
    //MARK: - action

    @IBAction func endStationClick(_ sender: Any) {
        var sourceArray:Array = [Any]()
        for item in self.offStationInfor {
            if let itemStationInfo = item as? StationInfo {
                sourceArray.append(itemStationInfo.name ?? "")
            }
        }
        if sourceArray.count <= 0 {
            self.showTip("无下车点可选", with: FNTipTypeFailure)
            return
        }
        //序列化控件需要的数据
        pickerView.updateDataSource(sourceArray, useType: 2)
        pickerView.show(in: KWINDOW)
        pickerView.clickCompleteIndex = {(index:Int32,useType:Int32) in
            if useType == 2 {
                self.offStationSelectedIndex = index
                let stationInfo:StationInfo? = self.offStationInfor[Int(index)] as? StationInfo
                self.endText.text = stationInfo?.name
            }
        }
    }

    @IBAction func startStationClick(_ sender: Any) { 
        
        var sourceArray:Array = [Any]()
        for item in self.onStationInfor {
            if let itemStationInfo = item as? StationInfo {
                sourceArray.append(itemStationInfo.name ?? "")
            }
        }
        if sourceArray.count <= 0 {
            self.showTip("无上车点可选", with: FNTipTypeFailure)
            return
        }
        //序列化控件需要的数据
        pickerView.updateDataSource(sourceArray, useType: 1)
        pickerView.show(in: KWINDOW)
        pickerView.clickCompleteIndex = {(index:Int32,useType:Int32) in
            if useType == 1 {
                self.onStationSelectedIndex = index
                let stationInfo:StationInfo? = self.onStationInfor[Int(index)] as? StationInfo
                self.startText.text = stationInfo?.name
            }
        }

    }

    @IBAction func descriptionClick(_ sender: Any) {
    }
    
    
    var commitFlag = false
    @IBAction func btnBuyClick(_ sender: Any) {

        self.ticketDate = self.calendarView.getSelectDays()
        
        //验证数据
        if self.ticketDate.count == 0 {
            self.showTip("请选择购票时间", with: FNTipTypeFailure)
            return
        }
        if self.onStationSelectedIndex == -1 {
            self.showTip("请选择上车点", with: FNTipTypeFailure)
            return
        }
        if self.offStationSelectedIndex == -1 {
            self.showTip("请选择下车车点", with: FNTipTypeFailure)
            return
        }
        
        
        if AuthorizeCache.sharedInstance().accessToken == nil ||
            AuthorizeCache.sharedInstance().accessToken == "" ||
            UserPreferences.sharedInstance().getUserInfo() == nil{
            
            commitFlag = true
            self.toLoginViewController()
            return
        }
        
        self.requestOrderPost()

    }

    func calendarViewSelectItems(_ items: [Any]!) {
        //价格计算 默认设置
        price = 0
        activityPrice = 0
        //是否有活动价
        var isActivityPrice:Bool = false
        
        //计算原价和活动价
        if items.count != 0 {
            for item in items {
                let ticket:TicketInfo = item as! TicketInfo
                price = price + ticket.price
                activityPrice = ticket.activity_price > 0 ? activityPrice + ticket.activity_price : activityPrice + ticket.price
                //是否有活动价
                if ticket.activity_price > 0  {
                    isActivityPrice = true
                }
            }
            
        }
        //界面显示
        //未选中车票
        if items.count == 0{
            self.labelCount.text = "共选择0张车票"
            self.labelPrice.text = NSString.calculatePrice(0)
            self.labelOriginalPrice.text = ""
        }
        //有活动价
        else if isActivityPrice {
            self.labelCount.text = "共选择\(self.calendarView.getSelectDays().count)张车票，活动立减\(NSString.calculatePriceNO(price - activityPrice)!)元"
            self.labelPrice.text = NSString.calculatePrice(activityPrice)
            self.labelOriginalPrice.text = NSString.calculatePrice(price)
        }
        //没活动价，未登录
        else if AuthorizeCache.sharedInstance().accessToken == nil  ||
            AuthorizeCache.sharedInstance().accessToken == "" {
            self.activityPrice = 0  //没有活动价还原为0
            self.labelCount.text = "登录后查看优惠价格"
            self.labelPrice.text = NSString.calculatePrice(price)
            self.labelOriginalPrice.text = ""
        }
        else {
            self.requestCouponBest(items)
            self.activityPrice = 0  //没有活动价还原为0
        }
        
    }
    
    @IBAction func btnBuyExplanationClick(_ sender: Any) {
        let webViewController:WebContentViewController = WebContentViewController.instance(withStoryboardName: "Me")
        webViewController.vcTitle = "购票说明"
        webViewController.urlString = HTMLTicketExplainn
        self.navigationController?.pushViewController(webViewController, animated: true)
    }

    //MARK: - http handle
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        self.stopWait()
        
        guard let result:ResultDataModel = notification.object as? ResultDataModel else { self.stopWait(); return}
        if result.type == Int32(EmRequestType_CommuteTicket.rawValue) {

            if let returnDic:Dictionary = result.data as? [String:Any] {
                //票价信息
                if let ticket = returnDic["ticket_info"], !(ticket is NSNull) {
                    self.ticketInfo = TicketInfo.mj_objectArray(withKeyValuesArray: ticket)
                    self.calendarView.arTickets = self.ticketInfo as? [Any];
                }
                
                //设置运营日期
                if self.ticketInfo.count != 0{
                    guard let first = self.ticketInfo.firstObject as? TicketInfo else {return}
                    
                    let date = DateUtils.date(from: first.date, format: "yyyy-MM-dd HH:mm:ss")
                    self.labelMonth.text  = DateUtils.formatDate(date, format: "yyyy年MM月")
                }

                
                //站点信息
                if let station = returnDic["station_info"], !(station is NSNull) {
                    let stationInfor:NSMutableArray? = StationInfo.mj_objectArray(withKeyValuesArray: station)
                    self.initStationInfo(stationInfor)
                }
            }
        }
        else if result.type == Int32(EmRequestType_CommuteOrderPost.rawValue) {

            if let returnDic:Dictionary = result.data as? [String:Any] {
                
                let onStation:StationInfo? = self.onStationInfor[Int(self.onStationSelectedIndex)] as? StationInfo
                let offStation:StationInfo? = self.offStationInfor[Int(self.offStationSelectedIndex)] as? StationInfo
                //支付页面
                let controller:SchedulePaymentViewController = SchedulePaymentViewController.instance(withStoryboardName: "ScheduledBus")
                
                var strIds:String = ""
                if let arIds = returnDic["ticket_id"] as? NSArray {
                    for item in arIds.enumerated() {
                        let Id:String = item.element as! String
                        strIds += Id
                        if item.offset != arIds.count-1 {
                            strIds += ","
                        }
                    }
                }
                
                controller.orderId = returnDic["id"] as! String?
                controller.strIds = strIds
                controller.lineId = self.id
                controller.orderInfor.onStationName = onStation?.name
                controller.orderInfor.offStationName = offStation?.name
                controller.orderInfor.useDate = self.ticketDate
                controller.orderInfor.tickCount = Int(self.ticketDate.count)
                controller.orderInfor.commuteObj = self.commuteObj
                if self.ticketInfo.count > 0 {
                    let tempTicketInfo:TicketInfo? = self.ticketInfo[0] as? TicketInfo
                    controller.orderInfor.unitPrice = tempTicketInfo?.price ?? 0
                }
                //优惠卷
                if let couponDetail = returnDic["coupon_detail"] {
                    let coupon:CouponObj =  CouponObj.mj_object(withKeyValues: couponDetail)
                    controller.orderInfor.coupon = coupon
                }
                //倒计时
                if let paymentCountdown = returnDic["wait_pay_time"] {
                    controller.orderInfor.paymentCountdown = paymentCountdown as? Int ?? 0
                }
                //订单总价 有活动价显示活动价，没有活动价显示原价
//                if let price = returnDic["price"] {
//                    controller.orderInfor.price = price as? Int ?? 0
//                }
                if activityPrice > 0 {
                    controller.orderInfor.price = activityPrice
                }
                else{
                    controller.orderInfor.price = price
                }
                //优惠后价格
                if let promotion_price = returnDic["promotion_price"] {
                    controller.orderInfor.promotion_price = promotion_price as? Int ?? 0
                }
                ////优惠价格
                if let discount = returnDic["discount"] {
                    controller.orderInfor.discount = discount as? Int ?? 0
                }
                
                self.navigationController?.pushViewController(controller, animated: true)
                
            }
        }
        else if result.type == Int32(EmRequestType_CouponBest.rawValue) {
            
            if let returnDic:Dictionary = result.data as? [String:Any] {
                //原价
                let price:Int = (returnDic["price"] as? Int) ?? 0
                //折扣
                let discount:Int = (returnDic["discount"] as? Int) ?? 0
                //优惠价
                let promotion_price:Int = (returnDic["promotion_price"] as? Int) ?? 0
                
                if discount > 0 {
                    //有优惠
                    self.labelCount.text = "共选择\(self.calendarView.getSelectDays().count)张车票，已用优惠劵抵扣\(NSString.calculatePriceNO(discount)!)元"
                    self.labelPrice.text = NSString.calculatePrice(promotion_price)
                    self.labelOriginalPrice.text = NSString.calculatePrice(price)
                }
                else {
                    //无优惠
                    self.labelCount.text = "共选择\(self.calendarView.getSelectDays().count)张车票"
                    self.labelPrice.text = NSString.calculatePrice(price)
                    self.labelOriginalPrice.text = ""
                }
            }
        }
        
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
    }
    
    var needRefresh = false
    override func loginSuccessHandler() {
        needRefresh = true
        
        if commitFlag {
            commitFlag = false
            self.btnBuyClick("")
        }
    }
}
