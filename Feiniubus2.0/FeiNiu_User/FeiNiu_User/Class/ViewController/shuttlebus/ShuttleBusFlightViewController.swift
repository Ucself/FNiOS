//
//  ShuttleBusFlightViewController.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/9/30.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class ShuttleBusFlightViewController: UserBaseUIViewController,UITableViewDelegate,UITableViewDataSource {

    var seachFlightDelegate:ShuttleBusSeachFlightViewControllerDelegate?
    
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var tagsView: UIView!
    
    
    //数据源
    var tableViewDataSource:NSMutableArray?
    var seachFlightInforObj:FlightInforObj = FlightInforObj()
    //cell里面的控件关联出来
    var dateLable:UILabel?
    var flightNumTextField:UITextField?
    //时间选择器 和 数据
    var dateSource:Array = [Any]()
    lazy var dateCustomPickView:CustomPickerView =  CustomPickerView.init(frame:CGRect.init(x: 0, y: 0, width: deviceWidth, height: deviceHeight), dataSourceArray: [], useType: 1)
    
    var sendViewController:UIViewController?
    
    //临时增加
    var isPickup:Bool = false;
    //搜索时间
    var seachDate:String = ""{
        didSet{
            self.dateLable?.text = seachDate
            self.dateLable?.textColor = UITextColor_Black
        }
    }
    //搜索航班号
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.confirmButton.layer.masksToBounds = true
        self.confirmButton.layer.cornerRadius = 22
        self.confirmButton.layer.borderWidth = 1
        self.confirmButton.layer.borderColor = UIColor_DefOrange.cgColor
        //更新时间
        self.resetDateDisplay()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableViewDataSource = FlightInfoCache.sharedInstance().searchHistoryFlight
        self.mainTableView.reloadData()
        //标签
        self.displayTagsView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func navigationViewRightClick() {
        self.hideKeyboard()
        //判断数据是否齐全
        if seachDate == "" {
            self.showTip("请选择查询时间", with: FNTipTypeFailure)
            return
        }
        guard let flightNum = self.flightNumTextField?.text, flightNum != "" else {
            self.showTip("请输入航班号", with: FNTipTypeFailure)
            return
        }
        
        //记录文件缓存
        var needRemoveObject:Array = [Any]()
        seachFlightInforObj.seachDate = self.seachDate
        seachFlightInforObj.flight_number = self.flightNumTextField?.text
        //先移除
        if let getHistoryFlight:NSMutableArray = FlightInfoCache.sharedInstance().searchHistoryFlight {
            for tempFlightInforObj in getHistoryFlight{
                //判断对象是否为字典
                if let flightDic:Dictionary<String,String> = tempFlightInforObj as? Dictionary<String,String> {
                    //取值判断 seachDate flight_num
                    if flightDic["flight_num"] != nil &&
                        flightDic["flight_num"] == self.flightNumTextField?.text {
                        needRemoveObject.append(tempFlightInforObj)
                    }
                }
                else{
                    needRemoveObject.append(tempFlightInforObj)
                }
            }
            getHistoryFlight.removeObjects(in: needRemoveObject)
            //再添加//搜索数据
            getHistoryFlight.insert(["seachDate":seachFlightInforObj.seachDate ,
                                     "flight_num":seachFlightInforObj.flight_number ],
                                    at: 0)
            //超过10个删除多余的
            if getHistoryFlight.count > 6 {
                getHistoryFlight.removeObjects(in: NSRange.init(location: 6, length: getHistoryFlight.count - 6))
            }
            FlightInfoCache.sharedInstance().searchHistoryFlight = getHistoryFlight
        }
        else{
            //没有记录的时候
            FlightInfoCache.sharedInstance().searchHistoryFlight = NSMutableArray.init(object: ["seachDate":seachFlightInforObj.seachDate ,
                                                                                                "flight_num":seachFlightInforObj.flight_number ])
        }
        
        self.search()
    }
    
    @IBAction func submitClick(_ sender: Any) {
        self.navigationViewRightClick()
    }
    
    
    //加载tags
    func displayTagsView () {
        
        //清楚子控件
        for view:UIView in self.tagsView.subviews {
            //先移除
            view.removeFromSuperview()
        }
        
        var tagsString:Array<String> = []
        
        if self.tableViewDataSource != nil {
            for i in 0..<self.tableViewDataSource!.count {
                let flightInforObj = self.tableViewDataSource![i] as! Dictionary<String,String>
                tagsString.append(flightInforObj["flight_num"] != nil ? flightInforObj["flight_num"]! : "")
            }
        }
        for i in 0..<tagsString.count {
            //控件宽度
            let labelWidth = (Int(deviceWidth) - 24*2 - 22*2)/3
            //行数
            let lineNum = Int(i/3)
            let tagLabel:UILabel = UILabel.init()
            tagLabel.text = tagsString[i]
            //样式
            tagLabel.layer.masksToBounds = true
            tagLabel.layer.cornerRadius = 15
            tagLabel.layer.borderWidth = 0.5
            tagLabel.layer.borderColor = UIColorFromRGB(0xe6e6e6).cgColor
            tagLabel.textAlignment = .center
            tagLabel.font = UIFont.systemFont(ofSize: 14)
            tagLabel.textColor = UITextColor_DarkGray
            //布局
            tagLabel.frame = CGRect.init(x:(22 + labelWidth) * (i % 3), y: 44 * lineNum , width: labelWidth, height: 30)
            
            self.tagsView.addSubview(tagLabel)
            //添加手势交互
            tagLabel.tag = i
            let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tagLabelTapGesture))
            tagLabel.isUserInteractionEnabled = true
            tagLabel.addGestureRecognizer(tapGesture)
        }
    }
    
    func tagLabelTapGesture(sender:UITapGestureRecognizer) {
        let index:Int = (sender.view?.tag)!
        if self.tableViewDataSource != nil &&  (self.tableViewDataSource?.count)! > index{
            let flightInforObj = self.tableViewDataSource![index] as! Dictionary<String,String>
            self.flightNumTextField?.text = flightInforObj["flight_num"] != nil ? flightInforObj["flight_num"]! : ""
            
        }
    }
    
    func search() {
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_FlightInfo.rawValue), params: {(param:NetParams?) -> Void in
            param?.method = EMRequstMethod.GET
            param?.data = ["time":self.seachFlightInforObj.seachDate!,
                           "number":self.seachFlightInforObj.flight_number!]
        })
    }
    
    func hideKeyboard() -> Void {
        self.flightNumTextField?.resignFirstResponder()
    }
    //重置时间显示选择
    func resetDateDisplay() {
        self.dateSource = [Any]()
        var displayDateSource:Array = [Any]()   //控件显示的数组
        var nowData:Date = Date.init()
//        let maxDate:Date = nowData.addingTimeInterval(86400*365); //设置一年的时间
        let maxDate:Date = DateUtils.date(from: "2017-12-31 23:59:59", format: "yyyy-MM-dd HH:mm:ss")
        
        while nowData < maxDate {
            //数据源
            self.dateSource.append(nowData)
            //显示的数据源
            displayDateSource.append(DateUtils.formatDate(nowData, format: "yyyy年MM月dd日"))
            //然后加一天
            nowData = nowData.addingTimeInterval(86400)
        }
        //再设置数据源
        self.dateCustomPickView.updateDataSource(displayDateSource, useType: 1)
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 8.0
        case 1:
            return 31.0
        default:
            return 0.0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //先隐藏键盘
        self.hideKeyboard()
        if indexPath.section == 0 && indexPath.row == 0 {
            
            self.dateCustomPickView.clickCompleteIndex = {(index:Int32, useType:Int32)-> Void in
                let tempDate:Date = self.dateSource[Int(index)] as! Date
                
                self.seachDate = DateUtils.formatDate(tempDate, format: "yyyy-MM-dd")
            }
            self.dateCustomPickView.show(in: KWINDOW)
        }
        if indexPath.section == 1 {
            if let flightInforObj = self.tableViewDataSource?[indexPath.row] as? Dictionary<String,String>{
//                self.seachFlightInforObj.seachDate = flightInforObj["seachDate"] != nil ? flightInforObj["seachDate"] : ""
                if seachDate == "" {
                    self.showTip("请选择查询时间", with: FNTipTypeFailure)
                    return
                }
                self.seachFlightInforObj.seachDate = self.seachDate
                self.seachFlightInforObj.flight_number = flightInforObj["flight_num"] != nil ? flightInforObj["flight_num"] : ""
            }
            //self.performSegue(withIdentifier: "toSeachFlight", sender: nil)
            self.search()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return (self.tableViewDataSource != nil) ? self.tableViewDataSource!.count : 0
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell = UITableViewCell()
        
        if indexPath.section == 0 {
            
            switch indexPath.row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: "dateViewCellId")!
                dateLable = cell.viewWithTag(101) as? UILabel
                //设置默认搜索时间
//                self.seachDate = DateUtils.formatDate(Date.init(), format: "yyyy-MM-dd")
//                self.dateLable?.text = seachDate
//                self.dateLable?.textColor = UIColorFromRGB(0x4D4D4D)
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: "flightViewCellId")!
                flightNumTextField = cell.viewWithTag(101) as? UITextField
            default:
                break
            }
            
        }
        else if indexPath.section == 1{
            if let flightInforObj = self.tableViewDataSource?[indexPath.row] as? Dictionary<String,String>{
                cell.textLabel?.text = flightInforObj["flight_num"] != nil ? "  \(flightInforObj["flight_num"]!)" : ""
            }
            cell.textLabel?.textColor = UITextColor_Black
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView()
        headView.backgroundColor = UIColor.clear
        //添加label
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = UITextColor_Black
        if section == 1 {
            headView.addSubview(titleLabel)
            titleLabel.frame = CGRect.init(x: 24, y: 0, width: deviceWidth, height: 31.0)
            titleLabel.text = "历史纪录"
        }
        return headView
    }
    
    
    //MARK: HTTP response
    override func httpRequestFinished(_ notification: Notification!) {
        self.stopWait()
        
        guard let result:ResultDataModel = notification.object as? ResultDataModel else {return}
        switch result.type {
        case Int32(EmRequestType_FlightInfo.rawValue):
            let array:Array? = FlightInforObj.mj_objectArray(withKeyValuesArray: result.data) as Array
//            if array?.count == 1 {
//                //如果只有一条数据则直接返回
//                let tempFlightInfor:FlightInforObj = array?.first as! FlightInforObj
//                
//                var city = ""
//                if self.isPickup {
//                    city = tempFlightInfor.arr_city!
//                }
//                else {
//                    city = tempFlightInfor.dep_city!
//                }
//                
//                tempFlightInfor.seachDate = seachFlightInforObj.seachDate
//                self.resultFlightInfo = tempFlightInfor
//                
//                //检查城市
//                if self.chekcCityInfo(city) {
//                    self.seachFlightDelegate?.seachFlightViewController?(self, didSelectFlightInforObj: tempFlightInfor)
//                    _ = navigationController?.popViewController(animated: true)
//                }
//            }
//            else
            if array?.count == 0 {
                self.showTip("未搜索到航班信息", with: FNTipTypeFailure)
            }
            else {
                let controller:ShuttleBusSeachFlightViewController = ShuttleBusSeachFlightViewController.instance(withStoryboardName: "ShuttleBus")
                controller.flightInfor = seachFlightInforObj
                controller.isPickup = self.isPickup
                controller.flightInforArray = array
                controller.seachFlightDelegate = self.sendViewController as! ShuttleBusSeachFlightViewControllerDelegate?
                self.navigationController?.pushViewController(controller, animated: true)
            }
           
            break
        case Int32(EMRequestType_StationInfo.rawValue):
                //机场车站数据
                let stationInfo:NSDictionary = result.data as! NSDictionary
                let airports:NSArray!       = StationObj.mj_objectArray(withKeyValuesArray: stationInfo["airport"] as? [Any])
                let trainStations:NSArray!  = StationObj.mj_objectArray(withKeyValuesArray: stationInfo["train_station"] as? [Any])
                let busStations:NSArray!    = StationObj.mj_objectArray(withKeyValuesArray: stationInfo["bus_station"] as? [Any])
                
                CityInfoCache.sharedInstance().setAirports(airports as? [Any], trainStations: trainStations as? [Any], busStations: busStations as? [Any])
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: KChangeCityNotification), object: nil)
                
                self.seachFlightDelegate?.seachFlightViewController?(self, didSelectFlightInforObj: self.resultFlightInfo!)
                _ = navigationController?.popViewController(animated: true)
            break
        default:
            break
        }
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
    }
    
    
    func chekcCityInfo(_ city: String) -> Bool{
        //是否是开通城市
        var isOpen = false
        for item in CityInfoCache.sharedInstance().arShuttleCitys.enumerated() {
            let item:CityObj = item.element as CityObj
            let count = item.city_name?.components(separatedBy: city).count
            if count! > 1 {
                resultCity = item
                isOpen = true
            }
        }
        
        var type = ""
        if self.isPickup {
            type = "接机"
        }
        else {
            type = "送机"
        }
        
        if isOpen == false {
            let alert: UserCustomAlertView = UserCustomAlertView(title: "航班\(type)服务未开通", message: "\"\(city)\"还未开通服务, 小牛正努力开拓疆土,\r\n您可以切换到其它城市哦!", delegate: self)
            alert.isLongMessage = true
            alert.show(in: self.view)
            return false
        }
        
        let count = CityInfoCache.sharedInstance().shuttleCurCity.city_name?.components(separatedBy:city).count
        if count! <= 1 {
            let alert: UserCustomAlertView = UserCustomAlertView(title: "航班的\(type)城市为\"\(city)\"", message: "是否切换用车城市为\"\(city)\"?", delegate: self, buttons:["取消", "切换"])
            alert.tag = 111
            alert.show(in: self.view)
            
            return false
        }
        
        return true
    }
    
    
    var resultCity:CityObj?
    var resultFlightInfo:FlightInforObj?
    override func userAlertView(_ alertView: UserCustomAlertView!, dismissWithButtonIndex btnIndex: Int) {
        if alertView.tag == 111 {
            if btnIndex == 1 {
                //切换城市
                guard let city:CityObj = resultCity else {
                    return
                }
                //设置默认城市
                CityInfoCache.sharedInstance().shuttleCurCity = city
                //请求默认，汽车站，火车站，机场数据
                CityInfoCache.sharedInstance().setAirports([], trainStations: [], busStations: [])
                
                self.startWait()
                NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EMRequestType_StationInfo.rawValue), params: { (params:NetParams?) -> Void in
                    params?.method = .GET
                    params?.data = ["adcode": city.adcode,
                                    "type": "All"]
                })
                
            }
        }
    }
}
