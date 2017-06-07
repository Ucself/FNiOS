//
//  ShuttleBusViewController.swift
//  FeiNiu_User
//
//  Created by tianbo on 16/9/28.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNUIView
import FNCommon
import FNNetInterface
import FNDataModule


public var globalIndex:Int = 0

public let initCityFunc:() -> Void = {
    
}
class ShuttleBusViewController: UserBaseUIViewController,ShuttleBusMainViewDelegate,ShuttleBusSelectTerminalViewControllerDelegate,FNSearchMapViewControllerDelegate,ShuttleBusSeachFlightViewControllerDelegate {

    //导航控件
    @IBOutlet weak var navigationRightButton: UIButton!
    @IBOutlet weak var switchSegmentedControl: UISegmentedControl!
    //界面控件
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var totalPricelbl: UILabel!
    @IBOutlet weak var headView: UIView!
    @IBOutlet weak var priceView: UIView!
    
    //接送数据View
    let shuttleBusMainView:ShuttleBusMainView = Bundle.main.loadNibNamed("ShuttleBusMainView", owner: nil, options: nil)!.first as! ShuttleBusMainView
    
    //接送数据
    var shuttleModule:ShuttleModule = ShuttleModule()
    
    //订单计价详情
    var valuationArray:Array<Any>?
    var payPrice:Double = 0
    //自定义使用控界面控件
    //时间选择器
    lazy var selectPickupDate:PickupDateSelectorView = PickupDateSelectorView.init(frame: CGRect.init(x: 0, y: 0, width: deviceWidth, height: deviceHeight), starTime: Date.init(), endTime: Date.init(), minuteInterval: 10)
    //时间选择器
    lazy var flightPickupDateSelectorView:FlightPickupDateSelectorView = FlightPickupDateSelectorView.init(frame: CGRect.init(x: 0, y: 0, width: deviceWidth, height: deviceHeight))
    //数量选择器
    var numPickerView:CustomPickerView?
    //通讯录对象
    lazy var addressBookHelp:AddressBookHelp = AddressBookHelp.init(addressDelegate: self)
    
    // MARK: override -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeInterface()
        
        //初始化城市数据
        if globalIndex == 0 {
            globalIndex = 1
            self.getOpenCitys()
        }
        else {
            let cityArray = CityInfoCache.sharedInstance().arShuttleCitys
            if cityArray == nil || cityArray?.count == 0 {
                self.getOpenCitys()
            }
            else {
                self.initShuttleModule()
                self.isInOpenCity()
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(citySelectedChange) , name: NSNotification.Name(rawValue: KChangeCityNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(paySuccess) , name: NSNotification.Name(rawValue: KPaySuccessNotification), object: nil)
    }
    
    deinit{
        //NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        commitFlag = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //显示选择的城市
        guard let curCity = CityInfoCache.sharedInstance().shuttleCurCity else { return }
        if let cityName = curCity.city_name {
            self.navigationRightButton.setTitle(cityName, for: UIControlState.normal)
        }
        else{
            self.navigationRightButton.setTitle("选择城市", for: UIControlState.normal)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        commitFlag = false
    }
    
    open func setShuttle(category:String) {
        self.shuttleModule.order_type = ShuttleCategory(rawValue: category)!
        self.shuttleBusMainView.shuttleCategory = self.shuttleModule.order_type
    }
    
    //MARK: -
    //是否在开通城市中
    func isInOpenCity() {
        let location = CityInfoCache.sharedInstance().curLocation
        let city = CityInfoCache.sharedInstance().shuttleCurCity
        
        if (CityInfoCache.sharedInstance().bLocationSuccess) {
            if city != nil && location == nil {
                let alertView:UserCustomAlertView = UserCustomAlertView(title: "当前城市服务未开通", message: "当前未开通服务, 小牛正在努力开拓疆土, \r\n您可以切换到其它城市哦", delegate: self, buttons: ["取消","切换城市"])
                alertView.isLongMessage = true
                alertView.delegate = self
                alertView.show(in: KWINDOW)
            }
        }
        
    }
    
    //获取城市数据
    func getOpenCitys () {
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_OpenCity.rawValue)) { (params) in
            
        }
    }

    
    func getCityStations(adcode:String) {
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EMRequestType_StationInfo.rawValue)) { (params) in
            params?.data = ["adcode": adcode, "type": "All"]   //4 取全部车站
        }
    }
    
    //获取时间配置请求
    func getConfigSendtime() -> Void {
        //配置数据
        
        let adcode:String = CityInfoCache.sharedInstance().shuttleCurCity.adcode ?? ""
        let station_id:String = self.shuttleModule.station_id ?? ""
        let latitude:CLLocationDegrees = self.shuttleModule.start_place?.latitude ?? 0.0
        let longitude:CLLocationDegrees = self.shuttleModule.start_place?.longitude ?? 0.0
        let flight_time:String = self.shuttleModule.flight?.dep_full_time ?? ""
        
        var requestRequest:Dictionary<String,Any> = ["type":self.shuttleModule.order_type.rawValue,"adcode":adcode]
        //站点
        if self.shuttleModule.station_id  != nil {
            requestRequest["station_id"] = station_id
        }
        
        if self.shuttleModule.start_place != nil {
            requestRequest["latitude"] = latitude
            requestRequest["longitude"] = longitude
        }
        
        if self.shuttleModule.flight != nil {
            requestRequest["flight_type"] = (self.shuttleModule.flight?.is_international_flight)! ? "International" : "Domestic"
            requestRequest["flight_time"] = flight_time
        }
        
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_ConfigSendtime.rawValue)) { (params:NetParams?) in
            params?.method = .GET
            params?.data = requestRequest;
        }
    }
    
    //MARK: - action
    override func userAlertView(_ alertView: UserCustomAlertView!, dismissWithButtonIndex btnIndex: Int) {
        if btnIndex == 0 {
            //取消
        }
        else if btnIndex == 1 {
            self.performSegue(withIdentifier: "toSelectCity", sender: nil)
        }
    }

    //MARK: - init mothed
    func initShuttleModule() {
        //let airport:StationObj?     = (CityInfoCache.sharedInstance().arAirports)?.first
        var airport:StationObj?         //第一次不默认航站楼
        let trainSation:StationObj? = (CityInfoCache.sharedInstance().arTrainStations)?.first
        let busStation:StationObj?  = (CityInfoCache.sharedInstance().arBusStations)?.first
        
        switch self.shuttleModule.order_type {
        case .AirportPickup, .AirportSend:
            if (airport != nil) {
                shuttleModule.start_place = FNLocation.init(name: airport?.name, longitude: (airport?.longitude)!, latitude: (airport?.latitude)!)
                shuttleModule.station_id = airport?.station_id
                shuttleModule.substation_id = airport?.id
            }
        case .TrainPickup, .TrainSend:
            if (trainSation != nil) {
                shuttleModule.start_place = FNLocation.init(name: trainSation?.name, longitude: (trainSation?.longitude)!, latitude: (trainSation?.latitude)!)
                shuttleModule.station_id = trainSation?.station_id
                shuttleModule.substation_id = trainSation?.id
            }
        case .BusPickup, .BusSend:
            if (busStation != nil) {
                shuttleModule.start_place = FNLocation.init(name: busStation?.name, longitude: (busStation?.longitude)!, latitude: (busStation?.latitude)!)
                shuttleModule.station_id = busStation?.station_id
                shuttleModule.substation_id = busStation?.id
            }
        }
        
        if let user:User = UserPreferences.sharedInstance().getUserInfo() {
            shuttleModule.phone = user.phone as String?
        }
        //城市adcode
        if let currentCity:CityObj = CityInfoCache.sharedInstance().shuttleCurCity {
            shuttleModule.adcode = currentCity.adcode
        }
        
        shuttleBusMainView.refreshUI()
        if isFullModule() {
            self.computePrice()
        }
    }
    
    func initializeInterface() {
        //设置人数
        var numDataSource:[String] = []
        for i in 1...99{
            numDataSource.append(String(i))
        }
        self.numPickerView = CustomPickerView.init(frame:CGRect.init(x: 0, y: 0, width: deviceWidth, height: deviceHeight), dataSourceArray: numDataSource, useType: 1)
        
        //设置切换按钮
        for index in 0...1 {
            self.switchSegmentedControl.setTitle(self.shuttleModule.order_type.titles[index], forSegmentAt: index)
        }
        //设置颜色
        self.switchSegmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName:UIColorFromRGB(0xB1B1B5),NSFontAttributeName:UIFont.boldSystemFont(ofSize: 14)], for: UIControlState.normal)
        
        self.switchSegmentedControl.layer.masksToBounds = true
        self.switchSegmentedControl.layer.cornerRadius = 14.0
        self.switchSegmentedControl.layer.borderWidth = 1
        self.switchSegmentedControl.layer.borderColor = UIColorFromRGB(0xBBBBBF).cgColor
    
        //确认用车按钮
        self.confirmButton.layer.masksToBounds = true
        self.confirmButton.layer.cornerRadius = 22
        self.confirmButton.layer.borderWidth = 1
        self.confirmButton.layer.borderColor = UIColor_DefOrange.cgColor
        //设置头部的view位置和数据
        headView.addSubview(shuttleBusMainView)
//        shuttleBusMainView.snp.makeConstraints { (make) in
//            make.edges.equalTo(headView)
//        }
        shuttleBusMainView.mas_makeConstraints { (make) in
            make?.edges.equalTo()(self.headView)
        }
        
        shuttleBusMainView.parent = self
        shuttleBusMainView.shuttleBusMainViewDelegate = self
    }
    
    //检查是否填写完全
    func isFullModule() -> Bool {
        if  (self.shuttleModule.phone != nil) &&
            (self.shuttleModule.use_time != nil) &&
            (self.shuttleModule.start_place != nil) &&
            (self.shuttleModule.end_place != nil) &&
            (self.shuttleModule.adcode != nil) &&
            (self.shuttleModule.station_id != nil) {
            
            //如果是接机送机则选判断航班  未选择航班可以计价可以下单
//            if self.shuttleModule.order_type == .AirportPickup || self.shuttleModule.order_type == .AirportSend {
//                return (self.shuttleModule.flight != nil) ? true : false
//            }
//            else{
//
//                return true
//            }
            
            return true
            
        }
        else{
            return false
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let tempViewController = segue.destination;
        //选择机场，汽车站，火车站控制器
        if tempViewController.isKind(of: ShuttleBusSelectTerminalViewController.classForCoder()) {
            let viewController:ShuttleBusSelectTerminalViewController =  tempViewController as! ShuttleBusSelectTerminalViewController
            viewController.shuttleCategory = self.shuttleModule.order_type
            viewController.selectTerminalDelegate = self
        }
        else if tempViewController.isKind(of: FNSearchMapViewController.classForCoder()){
            let viewController:FNSearchMapViewController =  tempViewController as! FNSearchMapViewController
            //viewController.navTitle = "选择地点"
            viewController.fnMapSearchDelegate = self
            viewController.isShuttleBus = true
            viewController.type = Int32(self.shuttleModule.order_type.toInt())
            
            if let city:CityObj = CityInfoCache.sharedInstance().shuttleCurCity {
                viewController.adcode = city.adcode
                viewController.coordinate = CLLocationCoordinate2D(latitude: city.central_latitude, longitude: city.central_longitude)
            }
        }
        else if tempViewController.isKind(of: ShuttleBusFlightViewController.classForCoder()){
            let viewController:ShuttleBusFlightViewController =  tempViewController as! ShuttleBusFlightViewController
            viewController.sendViewController = self
            viewController.seachFlightDelegate = self
            
            //start 临时代码
            switch self.shuttleModule.order_type {
            case .AirportPickup,.TrainPickup,.BusPickup:
                viewController.isPickup = true
            case .AirportSend,.TrainSend,.BusSend:
                viewController.isPickup = false
            }
            //end
        }

        
    }
    
    // MARK: - Action
    @IBAction func navigateionRightClick(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "toSelectCity", sender: nil)
    }
    
    @IBAction func menuClick(_ sender: AnyObject) {
        if AuthorizeCache.sharedInstance().accessToken == nil || AuthorizeCache.sharedInstance().accessToken == "" {
            showMenuFlag = true
            self.toLoginViewController()
            return;
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KShowMenuNotification), object: nil)
    }
    
    @IBAction func switchSegmentedClick(_ sender: Any) {
        //临时变量接送类型
        var tempShuttleCategory:ShuttleCategory = self.shuttleModule.order_type
        //更换接送类型
        if let segmentedControl:UISegmentedControl = sender as? UISegmentedControl  {
            switch self.shuttleModule.order_type {
            case .AirportPickup,.AirportSend:
                if segmentedControl.selectedSegmentIndex == 0 {
                    tempShuttleCategory = .AirportPickup
                }
                else{
                    tempShuttleCategory = .AirportSend
                }
            case .TrainPickup,.TrainSend:
                if segmentedControl.selectedSegmentIndex == 0 {
                    tempShuttleCategory = .TrainPickup
                }
                else{
                    tempShuttleCategory = .TrainSend
                }
            case .BusPickup,.BusSend:
                if segmentedControl.selectedSegmentIndex == 0 {
                    tempShuttleCategory = .BusPickup
                }
                else{
                    tempShuttleCategory = .BusSend
                }
            }
        }
        //清空航班号和上车时间
        self.shuttleModule.flight  = nil
        self.shuttleModule.use_time = nil
        
        self.shuttleModule.order_type = tempShuttleCategory
        //交换上下车地点
        let location:FNLocation? = self.shuttleModule.start_place
        shuttleModule.start_place = shuttleModule.end_place
        shuttleModule.end_place = location
        
        shuttleBusMainView.shuttleCategory = tempShuttleCategory
        
        //显示的价格要清零
        self.totalPricelbl.text = "¥0.00"
        self.priceView.isHidden = true
        
        if isFullModule() {
            self.computePrice()
        }
    }
    
    @IBAction func priceDetailClick(_ sender: AnyObject) {
        if self.valuationArray == nil {
            return
        }
        let priceController:ShuttleBusOrderPriceViewController = ShuttleBusOrderPriceViewController.instance(withStoryboardName: "ShuttleBusOrder")
        priceController.dataSourceArray = self.valuationArray
        priceController.payPrice = self.payPrice
        self.navigationController?.pushViewController(priceController, animated: true)
    }

    @IBAction private func confirmCarClick(_ sender: AnyObject) {
        //验证是否填写完整
        if !self.isFullModule() {
            self.showTip("请选择完整数据再确认用车", with: FNTipTypeFailure)
            return
        }
        
        if BCBaseObject.isMobileNumber(shuttleModule.phone) == false {
            self.showTip("请填写正确的手机号码", with: FNTipTypeFailure)
            return
        }
        
        commitFlag = true
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CreateOrder.rawValue)) { (params:NetParams?) in
            params?.method = .POST
            params?.data = self.shuttleModule.toOrderDictionary();
            }
        
    }
    
    @IBAction func tableViewClickAction(_ sender: UITapGestureRecognizer) {
        shuttleBusMainView.textFieldResponder()
        if self.isFullModule() {
            self.computePrice()
        }
    }
    //选择城市变化回调
    func citySelectedChange(_ notification: Notification!) -> Void {
        //清空数据
        self.shuttleModule.flight  = nil
        self.shuttleModule.use_time = nil
        
        self.shuttleModule.start_place = nil
        self.shuttleModule.end_place = nil
        
        self.shuttleModule.adcode = CityInfoCache.sharedInstance().shuttleCurCity.adcode
        
        //显示的价格要清零
        self.totalPricelbl.text = "¥0.00"
        self.priceView.isHidden = true
        //再设置默认出发地目的地
        var stationObj:StationObj?
        
        switch self.shuttleModule.order_type {          //设置站点信息
        case .AirportPickup,.AirportSend:
            if CityInfoCache.sharedInstance().arAirports.count > 0{
                stationObj = CityInfoCache.sharedInstance().arAirports[0]
            }
            
        case .TrainPickup,.TrainSend:
            if CityInfoCache.sharedInstance().arTrainStations.count > 0{
                stationObj = CityInfoCache.sharedInstance().arTrainStations[0]
            }
        case .BusPickup,.BusSend:
            if CityInfoCache.sharedInstance().arBusStations.count > 0{
                stationObj = CityInfoCache.sharedInstance().arBusStations[0]
            }
        }
        
        guard stationObj != nil else {
            self.shuttleBusMainView.refreshUI()
            return
        }
        
        if self.shuttleModule.order_type == .AirportPickup ||
            self.shuttleModule.order_type == .TrainPickup ||
            self.shuttleModule.order_type == .BusPickup{
            //如果是接站, 就是上车地点
            self.shuttleModule.station_id = stationObj?.station_id
            self.shuttleModule.substation_id = stationObj?.id
            self.shuttleModule.start_place = FNLocation.init(name: stationObj?.name, longitude: (stationObj?.longitude)!, latitude: (stationObj?.latitude)!)
            
        }
        else {
            self.shuttleModule.station_id = stationObj?.station_id
            self.shuttleModule.substation_id = stationObj?.id
            self.shuttleModule.end_place = FNLocation.init(name: stationObj?.name, longitude: (stationObj?.longitude)!, latitude: (stationObj?.latitude)!)
        }
        self.shuttleBusMainView.refreshUI()

    }
    //支付成功回复默认设置
    func paySuccess(_ notification: Notification!) -> Void {
        self.citySelectedChange(notification)
    }
    
    //MARK: - ShuttleBusMainViewDelegate
    //选择航班点击
    func chooseflightClick(shuttleBusMainView:ShuttleBusMainView){
        self.performSegue(withIdentifier: "toSelectFlight", sender: nil)
    }
    //选择时间点击
    func chooseDateTimeClick(shuttleBusMainView:ShuttleBusMainView,isDate:Bool){
        
        switch self.shuttleModule.order_type {
        case .AirportPickup,.BusPickup,.TrainPickup:
            //接服务
//            let startTempTime:Date = DateUtils.date(from: "2017-1-18 04:43:29", format: "yyyy-MM-dd HH:mm:ss")
//            let endTempTime:Date = DateUtils.date(from: "2017-1-19 21:01:29", format: "yyyy-MM-dd HH:mm:ss")
            //时间选择框  产品说时间设置终点为 2017年底，不是一年区间
            //selectPickupDate.resetDateSource(Date.init().addingTimeInterval(10800), endTime: Date.init().addingTimeInterval(86400*365), minuteInterval: 10)
//            selectPickupDate.resetDateSource(startTempTime, endTime: endTempTime, minuteInterval: 10)
            
            selectPickupDate.specTime = self.shuttleModule.use_time
            selectPickupDate.resetDateSource(Date.init().addingTimeInterval(10800), endTime: DateUtils.date(from: "2017-12-31 23:59:59", format: "yyyy-MM-dd HH:mm:ss"), minuteInterval: 10)
            selectPickupDate.clickCompleteBlock = {[weak self] (showDateString:String?,useDate:Date?,isReal:Bool)-> Void in
                //
                guard let strongSelf = self else {return}
                strongSelf.shuttleModule.use_time = useDate
                strongSelf.shuttleModule.dateSelectMethod = 0
                strongSelf.shuttleBusMainView.refreshUI()
                if strongSelf.isFullModule() {
                    strongSelf.computePrice()
                }
            }
            //航班到达后选择框
            flightPickupDateSelectorView.clickCompleteBlock = {[weak self] (interval:Int32) -> Void in
                guard let strongSelf = self else {return}
                
                //返回时间换算
                let flightDate:Date = DateUtils.date(from: strongSelf.shuttleModule.flight!.arr_full_time!, format: "yyyy-MM-dd HH:mm")
                //根据接送机判断加时间还是减时间
                let tempDate:Date = DateUtils.add(flightDate, interval: Int(interval * 60))
                strongSelf.shuttleModule.use_time = tempDate
                strongSelf.shuttleModule.dateSelectMethod = 1
                strongSelf.shuttleBusMainView.refreshUI()
                if strongSelf.isFullModule() {
                    strongSelf.computePrice()
                }
            }
            //判断时间选择框选用哪一个
            if let flightDate:Date = DateUtils.date(from: self.shuttleModule.flight?.arr_full_time, format: "yyyy-MM-dd HH:mm"), self.shuttleModule.order_type == .AirportPickup {
                if flightDate.addingTimeInterval(1800) > Date.init().addingTimeInterval(10800) {
                    //航班到达后多少分钟选择框
                    flightPickupDateSelectorView.show(in: KWINDOW)
                }
                else {
                    selectPickupDate.show(in: KWINDOW)
                }
            }
            else {
                
                selectPickupDate.show(in: KWINDOW)
            }
            
            break
        case .AirportSend,.BusSend,.TrainSend:
            //送服务 需要请求服务器
            self.getConfigSendtime()
            break
        }
        
    }
    //选择站点点击
    func chooseStationClick(shuttleBusMainView:ShuttleBusMainView,shuttleCategory:ShuttleCategory.RawValue){
        self.performSegue(withIdentifier: "toSelectTerminal", sender: nil)
    }
    //选择地图位置点击
    func chooseMapLocationClick(shuttleBusMainView:ShuttleBusMainView){
        self.performSegue(withIdentifier: "toSelectAddressOld", sender: nil)
    }
    //选择通讯录电话
    func chooseAddressBookPhoneClick(shuttleBusMainView:ShuttleBusMainView){
        self.addressBookHelp.clickComplete = {(phoneNumber:String?,error:String?) -> Void in
            if (error != nil) {
                return
            }
            self.shuttleModule.phone = phoneNumber
            self.shuttleBusMainView.refreshUI()
            if self.isFullModule() {
                self.computePrice()
            }
        }
        self.addressBookHelp.showAddressBookController();
    }
    //选择人数
    func choosePeopleNumberClick(shuttleBusMainView:ShuttleBusMainView){
        
        //********临时代码
        //送火车、送汽车人数为1，且不能更改
        if self.shuttleModule.order_type == .TrainSend || self.shuttleModule.order_type == .BusSend {
            self.shuttleModule.person_number = 1
            self.shuttleBusMainView.refreshUI()
            if self.isFullModule() {
                self.computePrice()
            }
            return
        }
        //********
        
        numPickerView?.show(in: KWINDOW)
        numPickerView?.clickComplete = {(resultString:String?) in
            self.shuttleModule.person_number = Int(resultString!)!
            self.shuttleBusMainView.refreshUI()
            if self.isFullModule() {
                self.computePrice()
            }
        }
    }
    //MARK: - 操作回调
    //选择站点
    func didSelectStationCell(_ shuttleBusSelectTerminalViewController: ShuttleBusSelectTerminalViewController, station: StationObj) {
        //站点选择回调

        if self.shuttleModule.order_type == .AirportPickup ||
            self.shuttleModule.order_type == .TrainPickup ||
            self.shuttleModule.order_type == .BusPickup{
            //如果是接站, 就是上车地点
            self.shuttleModule.station_id = station.station_id
            self.shuttleModule.substation_id = station.id
            self.shuttleModule.start_place = FNLocation.init(name: station.name, longitude: station.longitude, latitude: station.latitude)

        }
        else {
            self.shuttleModule.station_id = station.station_id
            self.shuttleModule.substation_id = station.id
            self.shuttleModule.end_place = FNLocation.init(name: station.name, longitude: station.longitude, latitude: station.latitude)
        }
        
        self.shuttleBusMainView.refreshUI()
        if isFullModule() {
            self.computePrice()
        }
    }
    //选择地址
    func searchMapViewController(_ searchMapViewController: FNSearchMapViewController!, didSelect location: FNLocation!) {
        //地图选址回调
        if self.shuttleModule.order_type == .AirportPickup ||
            self.shuttleModule.order_type == .TrainPickup ||
            self.shuttleModule.order_type == .BusPickup{
            //如果是接站, 选地图就是下车地点
//            if location == nil {
//                self.shuttleModule.end_place = nil;
//            }
            if location != nil && location.name != nil {
                self.shuttleModule.end_place = FNLocation.init(name: location.name, longitude: location.longitude, latitude: location.latitude)
            }
            
        }
        else {
//            if location == nil {
//                self.shuttleModule.start_place = nil;
//            }
            if location != nil  && location.name != nil {
                self.shuttleModule.start_place = FNLocation.init(name: location.name, longitude: location.longitude, latitude: location.latitude)
            }
            
        }
        
        self.shuttleBusMainView.refreshUI()
        if isFullModule() {
            self.computePrice()
        }
    }
    //选择航班返回
    func seachFlightViewController(_ viewController: UIViewController, didSelectFlightInforObj: FlightInforObj) {
        
        let flightInfo = didSelectFlightInforObj
        self.shuttleModule.flight = flightInfo
        
        //匹配航楼
        var airport:StationObj?;var airportStationObj:NSArray?
        if self.shuttleModule.order_type == .AirportPickup {
            //接机用到达匹配
            airportStationObj = flightInfo.arr_station
        }
        else if self.shuttleModule.order_type == .AirportSend{
            //送机用出发匹配
            airportStationObj = flightInfo.dep_station
        }
        if airportStationObj != nil {
            for (_, value) in airportStationObj!.enumerated() {
                let station:StationObj = value as! StationObj
                if station.matched {
                    airport = station
                }
            }
        }
        
        if airport != nil {
            //选择航班后从新选择时间
            if self.shuttleModule.order_type == .AirportPickup {
                let flightDate:Date = DateUtils.date(from: self.shuttleModule.flight?.arr_full_time, format: "yyyy-MM-dd HH:mm")
//                if flightDate.addingTimeInterval(1800) > Date.init().addingTimeInterval(10800) {
//                    self.shuttleModule.use_time = flightDate.addingTimeInterval(1800)
//                    self.shuttleModule.dateSelectMethod = 1
//                }
//                else{
//                    self.shuttleModule.use_time = nil
//                }
                self.shuttleModule.use_time = flightDate
                self.shuttleModule.dateSelectMethod = 1
                
                shuttleModule.start_place = FNLocation.init(name: airport?.name, longitude: (airport?.longitude)!, latitude: (airport?.latitude)!)
                shuttleModule.station_id = airport?.station_id
                shuttleModule.substation_id = airport?.id
            }
            else {
                shuttleModule.end_place = FNLocation.init(name: airport?.name, longitude: (airport?.longitude)!, latitude: (airport?.latitude)!)
                shuttleModule.station_id = airport?.station_id
                shuttleModule.substation_id = airport?.id
            }
        }
        
        self.shuttleBusMainView.refreshUI()
        
        //是否在当前城市
        guard let curCity = CityInfoCache.sharedInstance().shuttleCurCity else {
            NSLog("当前城市为空!!!!!")
            return
        }
        let curCityName = curCity.city_name ?? ""
        if self.shuttleModule.order_type == .AirportPickup {
            if curCityName.contains(flightInfo.arr_city!) == false {
                self.showTipsView("您选择的航班到达地未在当前城市, 请切换城市!")
                return
            }

        }
        else if self.shuttleModule.order_type == .AirportSend {
            if curCityName.contains(flightInfo.dep_city!) == false {
                self.showTipsView("您选择的航班起始地未在当前城市, 请切换城市!")
                //self.showTipsView("\(flightInfo.dep_city)还未开通服务, 小牛正努力开拓疆土, 您可以切换到其它城市哦!")
                return
            }
        }
        
        if isFullModule() {
            self.computePrice()
        }
    }
    
    //MARK: - Http Handler
    //计算价格
    func computePrice (){
        print("计算价格")
        
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_ComputePrice.rawValue)) { (params:NetParams?) in
            params?.method = .POST
            params?.data = self.shuttleModule.toPriceDictionary();
        }
    }
    
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        //self.stopWait()
        let result:ResultDataModel = notification.object as! ResultDataModel
        if result.type == Int32(EmRequestType_OpenCity.rawValue) {
            let cityArray:NSArray = CityObj.mj_objectArray(withKeyValuesArray: result.data)
            CityInfoCache.sharedInstance().arShuttleCitys = cityArray as! [CityObj]
            
            //获取当前城市
            guard let locationCity = CityInfoCache.sharedInstance().curLocation else {return}
            var isFound:Bool = false
            for item in cityArray.enumerated() {
                let city:CityObj = item.element as! CityObj
                
                let index = locationCity.adCode.index(locationCity.adCode.startIndex, offsetBy: 4)
                let text = city.adcode?.substring(to: index)
                NSLog(text!)
                if city.adcode?.substring(to: index) == locationCity.adCode.substring(to: index) {
                    //保存当前城市
                    CityInfoCache.sharedInstance().shuttleCurCity = city
                    isFound = true
                    break
                }
            }
            
            if !isFound {
                CityInfoCache.sharedInstance().shuttleCurCity = cityArray.firstObject as! CityObj!
            }
            
            //设置adcode
            NetInterfaceManager.sharedInstance().setShuttleAdcode(CityInfoCache.sharedInstance().shuttleCurCity.adcode)
            
            self.navigationRightButton.setTitle(CityInfoCache.sharedInstance().shuttleCurCity.city_name, for: UIControlState.normal)
            
            //取城市站点
            self.getCityStations(adcode: CityInfoCache.sharedInstance().shuttleCurCity.adcode!)
        }
        else if result.type == Int32(EMRequestType_StationInfo.rawValue) {
            self.stopWait()
            //机场车站数据
            let stationInfo:NSDictionary = result.data as! NSDictionary
            let airports:NSArray!       = StationObj.mj_objectArray(withKeyValuesArray: stationInfo["airport"] as? [Any])
            let trainStations:NSArray!  = StationObj.mj_objectArray(withKeyValuesArray: stationInfo["train_station"] as? [Any])
            let busStations:NSArray!    = StationObj.mj_objectArray(withKeyValuesArray: stationInfo["bus_station"] as? [Any])
            
            CityInfoCache.sharedInstance().setAirports(airports as? [Any], trainStations: trainStations as? [Any], busStations: busStations as? [Any])
            
            self.initShuttleModule()
            self.isInOpenCity()
        }
        else if result.type == Int32(EmRequestType_ComputePrice.rawValue) {
            self.stopWait()
            //计算价格
            let dataDic:NSDictionary? = result.data as? NSDictionary
            self.valuationArray = Array.init()
            //计价结果
            if let totalPrice:Double = dataDic?["total_price"] as? Double {
                self.totalPricelbl.text = "￥\(String(format: "%.2f", totalPrice/100))"
                self.payPrice = totalPrice
            }
            //后台返回详情数组
            if let billDetails:Array<Any> = dataDic?["bill_details"] as? Array<Any> {
                self.valuationArray = billDetails
            }
            
            self.priceView.isHidden = false
            
        }
        else if result.type == Int32(EmRequestType_CreateOrder.rawValue) {
            self.stopWait()
            //创建订单
            let dataDic:Dictionary<String,Any> = result.data as! Dictionary<String,Any>
            
//            let test:ShuttleOrderObj  = ShuttleOrderObj.mj_object(withKeyValues: result.data)
//            print(test)
            //判断订单是否生产成功
            guard let _ = dataDic["id"] else {
                print("订单生成失败请重试")
                return
            }
            
            //页面跳转
            let payContrller:ShuttleBusPayFareViewController = ShuttleBusPayFareViewController.instance(withStoryboardName: "ShuttleBus")
            payContrller.orderId = dataDic["id"] as? String ?? ""
            payContrller.useCarType = self.shuttleModule.use_car_type
            payContrller.peopleNum = self.shuttleModule.person_number
            payContrller.billDetail = dataDic["bill_details"] as! Array<Any>?
            payContrller.needPrice = dataDic["promotion_price"] as? Float ?? 0
            if dataDic["best_coupon"] != nil {
                payContrller.coupon = CouponObj.mj_object(withKeyValues: dataDic["best_coupon"])
            }
            //倒计时
            if let paymentCountdown = dataDic["payment_countdown"] {
                payContrller.timerIntervarl = paymentCountdown as! Int//Int(paymentCountdown as! String)!
            }
            
            self.navigationController?.pushViewController(payContrller, animated: true)
        }
        else if result.type == Int32(EmRequestType_ConfigSendtime.rawValue) {
            self.stopWait()
            if let dataDic:NSDictionary = result.data as? NSDictionary {
                
                let startDate:Date = DateUtils.date(from: dataDic["start_time"] as! String, format: "yyyy-MM-dd HH:mm:ss")
                let endDate:Date = DateUtils.date(from: dataDic["end_time"] as! String, format: "yyyy-MM-dd HH:mm:ss")
                
                if endDate < startDate {
                    self.showTip("该航班无可选时间送机", with: FNTipTypeFailure)
                    return
                }
                
                selectPickupDate.specTime = self.shuttleModule.use_time
                selectPickupDate.resetDateSource(startDate, endTime: endDate, minuteInterval: 10)
                selectPickupDate.clickCompleteBlock = {[weak self] (showDateString:String?,useDate:Date?,isReal:Bool)-> Void in
                    guard let strongSelf = self else {return}
                    
                    strongSelf.shuttleModule.use_time = useDate
                    strongSelf.shuttleModule.dateSelectMethod = 0
                    strongSelf.shuttleBusMainView.refreshUI()
                    if strongSelf.isFullModule() {
                        strongSelf.computePrice()
                    }
                }
                selectPickupDate.show(in: KWINDOW)
            }
            else {
                self.showTip("无可用时间可选送机", with: FNTipTypeFailure)
            }
            
        }
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
        
        let result:ResultDataModel = notification.object as! ResultDataModel
        if result.type == Int32(EmRequestType_ComputePrice.rawValue) {
            //计价设置为0
            self.totalPricelbl.text = "¥0.00"
            self.priceView.isHidden = true
            self.valuationArray = nil
        }
        
    }
    
    var commitFlag:Bool = false
    var showMenuFlag:Bool = false
    override func loginSuccessHandler() {
        
        if self != self.navigationController?.viewControllers.last {
            return
        }
        
        if let user:User = UserPreferences.sharedInstance().getUserInfo() {
            if shuttleModule.phone == nil || shuttleModule.phone == "" {
                shuttleModule.phone = user.phone as String?
                shuttleBusMainView.refreshUI()
            }
            else {
                shuttleModule.phone = shuttleBusMainView.phoneTextField.text
            }
            
            //如果是点提交登录成功, 而自动提交
            if commitFlag {
                commitFlag = false
                self.startWait()
                NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CreateOrder.rawValue)) { (params:NetParams?) in
                    params?.method = .POST
                    params?.data = self.shuttleModule.toOrderDictionary();
                }
            }
            else {
                if isFullModule() {
                    self.computePrice()
                }
            }
            
            if showMenuFlag {
                showMenuFlag = false
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: KShowMenuNotification), object: nil)
            }
        }
        
//        shuttleBusMainView.refreshUI()
//        self.isFullModule(isValuation:true)
    }
    
}
