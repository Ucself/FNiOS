//
//  ShuttleBusOrderStatusViewController.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/10/11.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

struct UseLocation {
    //起点
    var start:CLLocationCoordinate2D?
    //终点
    var end:CLLocationCoordinate2D?
    //驾驶员地点有几个
    var drivers:[CLLocationCoordinate2D]?
    //默认显示的驾驶员
    var displayDriver:Int = 0
    
    init() {
        self.start = CLLocationCoordinate2D.init()
        self.end = CLLocationCoordinate2D.init()
        self.drivers = [CLLocationCoordinate2D]()
    }
}

class PointAnnotation: MAPointAnnotation {
    var image:UIImage?
}

class ShuttleBusOrderStatusViewController: UserBaseUIViewController, MAMapViewDelegate, AMapSearchDelegate,UIScrollViewDelegate{
    
    var refreshDelegate:ShuttleOrderListDelegate?
    
    //MARK: 地图变量
    var mapView:MAMapView!
    var mapSearch:AMapSearchAPI!
    var route: AMapRoute?   //路径规划回调
    
    //MARK: 数据变量
    var orderId:String?                 //订单id
    var order:ShuttleOrderObj?          //订单详情
    var useLocation:UseLocation?        //位置
    let repeatSeconds:Double = 10
    
    //
    var isToEvaluation = false
    
    //标注数据
    let s_annotation:PointAnnotation = PointAnnotation()    //起点
    let e_annotation:PointAnnotation = PointAnnotation()    //终点
    let d_annotation:PointAnnotation = PointAnnotation()    //车位置
    
    //MARK: 界面控件
    @IBOutlet weak var parentMapView: UIView!
    @IBOutlet weak var naviView: UINavigationView!
    
    //信息
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbPersonNum: UILabel!
    @IBOutlet weak var lbStart: UILabel!
    @IBOutlet weak var lbEnd: UILabel!
    @IBOutlet weak var driverScrollView: UIScrollView!
    @IBOutlet weak var lbFlightNum: UILabel!
    
    @IBOutlet weak var btnLookLocation: UIButton!
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var tipViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var labelTip: UILabel!
    @IBOutlet weak var lableTipRightCons: NSLayoutConstraint!
    

    //Timer 对象
//    let timer:Timer = Timer.init(timeInterval: self.repeatSeconds, repeats: true, block: {(timeer:Timer) -> Void in
//        
//    })
    var timer:Timer?
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.initMap()
        self.getOrderDetail(waitSymbol: true)
        //启动定时获取
        self.startTimer()
        //注册推送通知
        NotificationCenter.default.addObserver(self, selector: #selector(orderStatusNotification(notification:)), name: NSNotification.Name(rawValue: FNPushType_ShttleWaiting), object: nil)   //等待上车
        NotificationCenter.default.addObserver(self, selector: #selector(orderStatusNotification(notification:)), name: NSNotification.Name(rawValue: FNPushType_ShttleOngoing), object: nil)   //行程开始
        NotificationCenter.default.addObserver(self, selector: #selector(orderStatusNotification(notification:)), name: NSNotification.Name(rawValue: FNPushType_ShttleArrived), object: nil)   //行程结束

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //结束定时
        self.endTimer()
    }
    
    deinit {
        self.endTimer()
    }
    
    override func navigationViewRightClick() {
        //取消订单
        guard let order = self.order else { return }
        let refund:String = String(format: "退款金额:%.2f元",Float(order.promotion_price/100))
        let alertView:UserCustomAlertView = UserCustomAlertView(title: "确定取消用车吗？", message: refund, delegate: self, buttons: ["取消用车","继续用车"])
        alertView.delegate = self
        alertView.show(in: self.view)
        
        self.endTimer()
    }
    //MARK: ----
    func initUI()  {
        infoView.isHidden = true;
        //设置scrollView 属性
        self.driverScrollView.contentSize = CGSize.init(width: deviceWidth, height: 65)
        self.driverScrollView.showsVerticalScrollIndicator = false
        self.driverScrollView.showsHorizontalScrollIndicator = false
        self.driverScrollView.isPagingEnabled = true
        self.driverScrollView.delegate = self
    }
    
    
    func initMap() -> Void {
        
        mapSearch = AMapSearchAPI()
        mapSearch.delegate = self
        
        //对地图进行加载
        mapView = MAMapView.init()
        parentMapView.addSubview(mapView)
        mapView.delegate = self
        //mapView.showsUserLocation = true
        mapView.isRotateEnabled = false
        mapView.showsScale = false
        mapView.showsCompass = false
        mapView.userTrackingMode = MAUserTrackingMode.none
        mapView.zoomLevel = 15
//        mapView.snp.makeConstraints { (make) in
//            make.edges.equalTo(parentMapView)
//        }
        mapView.mas_makeConstraints { (maker) in
            maker!.edges.equalTo()(self.parentMapView)
        }
    }

    func getOrderDetail(waitSymbol:Bool) {
        
        if waitSymbol {
            self.startWait()
        }
        
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_OrderDetail.rawValue)) { (params:NetParams?) in
            params?.method = .GET
            params?.data = ["id": self.orderId!]
        }
    }
    //跳转到评价页面
    func gotoEvaluationViewController(){
       
        if isToEvaluation {
            return
        }
        isToEvaluation = true
        
        //终止定时器
        self.endTimer()
        //跳转评价页面
        let evaluationViewController:ShuttleBusOrderEvaluationViewController = ShuttleBusOrderEvaluationViewController.instance(withStoryboardName: "ShuttleBusOrder")
        evaluationViewController.orderId = self.orderId;
        
        let controllers:NSMutableArray =  NSMutableArray.init(array: (self.navigationController?.viewControllers)!)
        controllers.removeLastObject()
        controllers.add(evaluationViewController)
        
        self.navigationController?.setViewControllers((controllers as NSArray as? [UIViewController])!, animated: true)
    }
    
    //MARK: Timer
    func startTimer()  {
        //结束上一次
        self.endTimer()
        //重新开始
        self.timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    }
    func endTimer(){
        self.timer?.invalidate()
    }
    //时间处理
    func handleTimer() {
        //重新获取数据
        self.getOrderDetail(waitSymbol: false)
        print("handleTimer()")
    }
    
    //MARK: ----
    func refreshUI() {
        guard let order = self.order else { return }
        
        let status:ShuttleOrderState? = ShuttleOrderState(rawValue: order.order_state)
        let orderType:ShuttleOrderType = ShuttleOrderType(rawValue: order.order_type)!
        
        naviView.title = status?.toString()
        //行程
        self.lbDate.text = order.use_time
        self.lbStart.text = order.starting
        self.lbEnd.text = order.destination
        self.lbPersonNum.text = String(format: "%d人拼车(¥%.2f)", order.people_number, Float(order.price)/100.0)
        
        if orderType == .AirportPickup {
            self.lbDate.text = DateUtils.formatDate(DateUtils.string(toDate: order.use_time), format: "yyyy-MM-dd") 
            self.lbFlightNum.text = order.flight_number ?? ""
        }
        
        //接送机驾驶员信息
        
        if status == .PendingDispatch || status == .QueuingDispatch{
            
            //未分配车辆状态
//            if status == .PendingDispatch || status == .QueuingDispatch {
            self.driverScrollView.contentSize = CGSize.init(width: Int(deviceWidth), height: 65)
            for view:UIView in self.driverScrollView.subviews {
                //先移除
                view.removeFromSuperview()
            }
            
            let driverInforHead:ShuttleBusDriverInforHeadView = Bundle.main.loadNibNamed("ShuttleBusDriverInforHeadView", owner: nil, options: nil)?[0] as! ShuttleBusDriverInforHeadView
            self.driverScrollView.addSubview(driverInforHead)
            driverInforHead.mas_makeConstraints({ (maker) in
                maker!.left.equalTo()(self.driverScrollView)
                maker!.top.equalTo()(self.driverScrollView)
                maker!.width.equalTo()(deviceWidth)
                maker!.height.equalTo()(65)
            })
            
            //设置司机界面显示
            driverInforHead.headImageView.image = UIImage.init(named: "icon_driver")
            driverInforHead.driverNameLabel.text = "飞牛巴士调度人员"
            
            //driverInforHead.scoreLabel.isHidden = true
            driverInforHead.ratingBar.isHidden = true
            driverInforHead.sortingDriverLabel.isHidden = true
            driverInforHead.scoreBgImage.isHidden = true
            
            driverInforHead.carInfor.textColor = UITextColor_DarkGray
            driverInforHead.carInfor.font = UIFont.systemFont(ofSize: 13)
            
            if let phone:String = order.phone_configs?.firstObject as! String? {
                driverInforHead.phoneNum = phone
            }
            if deviceWidth <= 320.0 {
                driverInforHead.phoneRightCons.constant = -10
            }
            else{
                driverInforHead.phoneRightCons.constant = 10
            }
            
            self.tipView.isHidden = false
            //order.location = "下飞机后前往乘车点找到工作人员验票下飞机后前往乘车点找到工作人员验票点"

            var location:String = order.location ?? ""
            if orderType == .AirportPickup {
                driverInforHead.carInfor.text = "下飞机后前往乘车点找到工作人员验票"
                driverInforHead.labelHint.isHidden = false
                
                self.btnLookLocation.isHidden = false
 
                let attributedString:NSMutableAttributedString = NSMutableAttributedString.init(string: location)
                let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.init()
                paragraphStyle.lineSpacing = 2.5
                attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, location.characters.count))
                
                self.labelTip.attributedText = attributedString
                
                let height:CGFloat = self.labelTip.text?.height(with: UIFont.systemFont(ofSize: 13), constrainedToWidth: self.labelTip.frame.size.width, lineSpacing:2.5) ?? 0
                
                self.tipViewHeightCons.constant = height + 20
            }
            else {
                driverInforHead.carInfor.text = "有任何疑问可拨打24小时服务电话"
                
                self.btnLookLocation.isHidden = true
                self.lableTipRightCons.constant = 62
                self.tipView.layoutIfNeeded()
                
                location = "最晚将在出发前2小时为您安排车辆，司机将在\"用车时间前15分钟-用车时间后15分钟\"接您，为避免耽误其他乘客行程，司机到达后最多等待10分钟，请提前做好上车准备。"
                
                let attributedString:NSMutableAttributedString = NSMutableAttributedString.init(string: location)
                let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.init()
                paragraphStyle.lineSpacing = 2.5
                attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, location.characters.count))
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor_DefOrange, range: NSMakeRange(21, 21))
                
                self.labelTip.attributedText = attributedString
                
                let height:CGFloat = self.labelTip.text?.height(with: UIFont.systemFont(ofSize: 13), constrainedToWidth: self.labelTip.frame.size.width, lineSpacing:2.5) ?? 0
                
                self.tipViewHeightCons.constant = height + 22
            }

        }
        else {   //其它接送驾驶员信息
            self.tipView.isHidden = true
            
            self.driverScrollView.contentSize = CGSize.init(width: Int(deviceWidth) * (order.order_dispatches?.count)!, height: 65)
            for view:UIView in self.driverScrollView.subviews {
                //先移除
                view.removeFromSuperview()
            }
            var itemCount:Int = 0
            for item:DriverObj in order.order_dispatches as! [DriverObj] {
                let driverInforHead:ShuttleBusDriverInforHeadView = Bundle.main.loadNibNamed("ShuttleBusDriverInforHeadView", owner: nil, options: nil)?[0] as! ShuttleBusDriverInforHeadView
                self.driverScrollView.addSubview(driverInforHead)
                driverInforHead.mas_makeConstraints({ (maker) in
                    maker!.left.equalTo()(self.driverScrollView)?.setOffset(CGFloat(itemCount * Int(deviceWidth)))
                    maker!.top.equalTo()(self.driverScrollView)
                    maker!.width.equalTo()(deviceWidth)
                    maker!.height.equalTo()(65)
                })
                
                //设置司机界面显示
                driverInforHead.carInfor.textColor = UITextColor_Black
                driverInforHead.carInfor.font = UIFont.systemFont(ofSize: 14)
                driverInforHead.scoreLabel.isHidden = false
                driverInforHead.ratingBar.isHidden = false
                driverInforHead.sortingDriverLabel.isHidden = false
                driverInforHead.scoreBgImage.isHidden = false
                driverInforHead.labelHint.isHidden = true
                
                
                driverInforHead.headImageView.setImageWith(URL.init(string: (item.avatar ?? "")), placeholderImage: UIImage.init(named: "icon_driver"))
                driverInforHead.driverNameLabel.text = item.name
                driverInforHead.scoreLabel.text = String(format:" %.1f",item.score)
                driverInforHead.ratingBar.setRating(item.score)
                driverInforHead.ratingBar.isIndicator = true
                if item.seats == 0 {
                    driverInforHead.carInfor.text = "\(item.license ?? "") (\(item.people_number)人)"
                }
                else{
                    driverInforHead.carInfor.text = "\(item.license ?? "") (\(item.people_number)人/\(item.seats)座)"
                }
                if deviceWidth <= 320.0 {
                    driverInforHead.phoneRightCons.constant = 42-20
                }
                else{
                    driverInforHead.phoneRightCons.constant = 42
                }
                driverInforHead.phoneNum = item.phone
                driverInforHead.sortingDriverLabel.text = "\(itemCount+1)/\((order.order_dispatches?.count)!)"
                driverInforHead.sortingDriverLabel.attributedText = NSString.hintString(withIntactString: driverInforHead.sortingDriverLabel.text,
                                                                                        hintString: "\(itemCount+1)",
                    intactColor: UITextColor_LightGray,
                    hintColor: UIColorFromRGB(0xFE6E35)) as! NSAttributedString?
                
                //最后加一
                itemCount += 1
            }
            
            if orderType == .AirportSend{
                if status == .Dispatched {    //派车后状态
                    self.tipView.isHidden = false
                    self.btnLookLocation.isHidden = true
                    self.lableTipRightCons.constant = 62
                    self.tipView.layoutIfNeeded()
                    
                    let tip = "司机将在\"用车时间前15分钟-用车时间后15分钟\"接您，为避免耽误其他乘客行程，司机到达后最多等待10分钟，请提前做好上车准备。"
                    
                    let attributedString:NSMutableAttributedString = NSMutableAttributedString.init(string: tip)
                    let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.init()
                    paragraphStyle.lineSpacing = 4.5
                    attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, tip.characters.count))
                    attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor_DefOrange, range: NSMakeRange(4, 21))
                    
                    self.labelTip.attributedText = attributedString
                    
                    let height:CGFloat = self.labelTip.text?.height(with: UIFont.systemFont(ofSize: 13), constrainedToWidth: self.labelTip.frame.size.width, lineSpacing:4.5) ?? 0
                    
                    self.tipViewHeightCons.constant = height + 22
                }
                else if status == .Waiting {    //等待状态
                    self.btnLookLocation.isHidden = false
                    self.tipView.isHidden = false
                    self.labelTip.attributedText = nil
                    self.tipView.backgroundColor = UIColor.clear
                }
            }
           
        }
    }
    
    //添加标注
    func initAnnotation() {
        guard let order = self.order else { return }
        //先移除
        self.mapView.removeAnnotations(self.mapView.annotations)
        //配制标记点数据
        s_annotation.coordinate = (self.useLocation?.start)!
        s_annotation.title = order.starting
        s_annotation.image = UIImage(named: "icon_ride-start")
        
        
        e_annotation.coordinate = (self.useLocation?.end)!;
        e_annotation.title = order.destination
        e_annotation.image = UIImage(named: "icon_ride-end")
        var array = [s_annotation, e_annotation]
        //配置车辆位置
        let orderState:ShuttleOrderState = ShuttleOrderState(rawValue: order.order_state)!
        switch orderState {
        case ShuttleOrderState.Transporting,ShuttleOrderState.Waiting:
            if (self.useLocation?.drivers?.count)! > (self.useLocation?.displayDriver)! {
                
                let displayIndex:Int = (self.useLocation?.displayDriver)!
                
                d_annotation.coordinate = (self.useLocation?.drivers?[displayIndex])!;
                d_annotation.title = order.destination
                d_annotation.image = UIImage(named: "icon_car_feiniu")
                array = [s_annotation, e_annotation, d_annotation]
            }
        default:
            break
        }
        
        self.mapView.addAnnotations(array)
        //self.mapView.showAnnotations(array, edgePadding: UIEdgeInsetsMake(200, 50, 90, 50), animated: true)
    }
    //路径规划
    func searchRoutePlanning() {
        let request = AMapDrivingRouteSearchRequest()
        request.requireExtension = true
        
        request.origin = AMapGeoPoint.location(withLatitude: CGFloat((self.useLocation?.start?.latitude)!),
                                               longitude: CGFloat((self.useLocation?.start?.longitude)!))
        request.destination = AMapGeoPoint.location(withLatitude: CGFloat((self.useLocation?.end?.latitude)!),
                                                    longitude: CGFloat((self.useLocation?.end?.longitude)!))
        
        self.mapSearch.aMapDrivingRouteSearch(request)
    }
    /* 展示当前路线方案. */
    func presentCurrentCourse() {
        
        let pstart = AMapGeoPoint.location(withLatitude: CGFloat((self.useLocation?.start?.latitude)!),
                                           longitude: CGFloat((self.useLocation?.start?.longitude)!))
        let pend = AMapGeoPoint.location(withLatitude: CGFloat((self.useLocation?.end?.latitude)!),
                                         longitude: CGFloat((self.useLocation?.end?.longitude)!))
        
        let naviRoute:MANaviRoute = MANaviRoute(for: self.route?.paths.first, withNaviType: MANaviAnnotationType.drive, showTraffic: true, start: pstart, end: pend)
        
        naviRoute.add(to: mapView)
        
        mapView.showOverlays(naviRoute.routePolylines, edgePadding: UIEdgeInsetsMake(200, 50, 90, 50), animated: true)
    }
    //后台服务通知
    func orderStatusNotification (notification:Notification){
        let notificationInfor:[String:Any]? = notification.object as? [String : Any]
        
        guard notificationInfor?["orderId"] != nil && notificationInfor?["processType"] != nil else {
            //不满足条件直接返回
            return
        }
        guard (notificationInfor?["orderId"] as! String) == self.orderId else {
            //不是本订单的直接返回
            return
        }
        //推送类型
        switch notification.name {
        case NSNotification.Name.init(FNPushType_ShttleWaiting):
            self.getOrderDetail(waitSymbol: false)
        case NSNotification.Name.init(FNPushType_ShttleOngoing):
            self.getOrderDetail(waitSymbol: false)
        case NSNotification.Name.init(FNPushType_ShttleArrived):
            self.getOrderDetail(waitSymbol: false)
            break
        default:
            //不是本类型的直接返回
            return
        }
    }
    
    //MARK: MAMapViewDelegate/AMapSearchDelegate
    func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
        
        self.route = nil
        if response.count > 0 {
            
            mapView.removeOverlays(mapView.overlays)
            self.route = response.route
            presentCurrentCourse()
        }
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        print("Error:\(error)")
    }
    //标记view
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation is MAPointAnnotation {
            let pointReuseIndetifier:String = "pointReuseIndetifier"
            var annotationView:MAAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier) as MAAnnotationView?
            
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            if let annotation:PointAnnotation = annotation as? PointAnnotation {
                annotationView?.canShowCallout   = true
                annotationView?.image = annotation.image
            }

            return annotationView
        }
        
        return nil
    }

    func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
        if overlay.isKind(of: LineDashPolyline.self) {
            let naviPolyline: LineDashPolyline = overlay as! LineDashPolyline
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: naviPolyline.polyline)
            renderer.lineWidth = 4.0
            renderer.strokeColor = UIColor_DefGreen
            renderer.lineDash = false
            
            return renderer
        }
        if overlay.isKind(of: MANaviPolyline.self) {
            
            let naviPolyline: MANaviPolyline = overlay as! MANaviPolyline
            let renderer: MAPolylineRenderer = MAPolylineRenderer(overlay: naviPolyline.polyline)
            renderer.lineWidth = 4.0
            renderer.strokeColor = UIColor_DefGreen
            
            
            return renderer
        }
        if overlay.isKind(of: MAMultiPolyline.self) {
            let renderer: MAMultiColoredPolylineRenderer = MAMultiColoredPolylineRenderer(multiPolyline: overlay as! MAMultiPolyline!)
            renderer.lineWidth = 4.0
            renderer.strokeColors = [UIColor_DefGreen]
            
            return renderer
        }
        return nil
    }
    
    //MARK: UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView){
        //每页宽度
        let scrollViewWidth:Float = Float(scrollView.frame.size.width)
        let scrollViewPage = floor((Float(scrollView.contentOffset.x) - Float(scrollViewWidth)/2) / scrollViewWidth) + 1
        if self.useLocation != nil {
            self.useLocation?.displayDriver = Int(scrollViewPage)
        }
        
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        //减速完成 即是司机切换完成
        let displayIndex:Int = (self.useLocation?.displayDriver)!
        self.d_annotation.coordinate = (self.useLocation?.drivers?[displayIndex])!;
    }
    
    //MARK: - action
    override func userAlertView(_ alertView: UserCustomAlertView!, dismissWithButtonIndex btnIndex: Int) {
        if btnIndex == 0 {
            //取消了 要刷新List
            self.refreshDelegate?.setNeedRefresh!()
            self.startWait()
            NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_OrderCancel.rawValue), params: { (params:NetParams?) in
                params?.method = .DELETE
                params?.data   = ["id": self.orderId]
            })
        }
        else if btnIndex == 1 {
            self.startTimer()
        }
    }
    
    @IBAction func btnLookLocationClick(_ sender: Any) {
        let webViewController:WebContentViewController = WebContentViewController.instance(withStoryboardName:"Me");
        webViewController.vcTitle = "查看上车点";
        webViewController.urlString = self.order?.guide_page_url;
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    //MARK: - http handler
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        self.stopWait()
        let result:ResultDataModel = notification.object as! ResultDataModel
        
        if result.type == Int32(EmRequestType_OrderDetail.rawValue) {
            let returnOrder = ShuttleOrderObj.mj_object(withKeyValues: result.data)
            if returnOrder != nil {
                self.infoView.isHidden = false

                //设置订单信息
                self.order = returnOrder
                if self.order?.order_state != returnOrder?.order_state {
                    //列表应该刷新
                    self.refreshDelegate?.setNeedRefresh!()
                }
                
                //设置坐标信息
                self.useLocation = UseLocation.init()
                self.useLocation?.start?.latitude = (self.order?.s_latitude)!
                self.useLocation?.start?.longitude = (self.order?.s_longitude)!
                self.useLocation?.end?.latitude = (self.order?.d_latitude)!
                self.useLocation?.end?.longitude = (self.order?.d_longitude)!
                if let drivers:NSArray = self.order?.order_dispatches, (self.order?.order_dispatches?.count)! > 0 {
                    for item in drivers.enumerated() {
                        if let driver:DriverObj = item.element as? DriverObj {
                            let tempCLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: driver.latitude,
                                                                                         longitude: driver.longitude)
                            self.useLocation?.drivers?.append(tempCLLocationCoordinate2D)
                        }
                    }
                }
                
                
                self.refreshUI()
                //起点和终点 车辆
                self.initAnnotation()
                //路径规划
                self.searchRoutePlanning()
                //行程完成跳转页面
                guard let order = self.order else { return }
                let status:ShuttleOrderState? = ShuttleOrderState(rawValue: order.order_state)
                if status == .Completed {
                    self.gotoEvaluationViewController()
                }

            }
        }
        else if result.type == Int32(EmRequestType_OrderCancel.rawValue) {
            self.endTimer()
            
            //取消成功后进行页面跳转
            let cancelReasonViewController:ShuttleBusOrderCancelReasonViewController = ShuttleBusOrderCancelReasonViewController.instance(withStoryboardName: "ShuttleBusOrder")
            cancelReasonViewController.orderId = self.orderId
            let controllers:NSMutableArray =  NSMutableArray.init(array: (self.navigationController?.viewControllers)!)
            controllers.removeLastObject()
            controllers.add(cancelReasonViewController)
            self.navigationController?.setViewControllers((controllers as NSArray as? [UIViewController])!, animated: true)
        }
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
    }
    
    
}
