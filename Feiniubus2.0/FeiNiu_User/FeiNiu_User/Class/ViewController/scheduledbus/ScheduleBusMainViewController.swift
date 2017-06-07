//
//  ScheduledBusMainViewController.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/11/29.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class ScheduleBusMainViewController: UserBaseUIViewController, UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var naView: UINavigationView!
    
    //分页数据
    var page = 1
    var row = 10
    
    var needRefresh = false
    //数据源
    var dataSource:NSMutableArray = NSMutableArray.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        //添加界面
        self.initInterface()
        //请求数据
        self.reuestCommuteOpenCity()
        //注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(citySelectedChange) , name: NSNotification.Name(rawValue: KChangeCityNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(httpRequestFinished) , name: NSNotification.Name(rawValue: KNotification_RequestFinished), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(httpRequestFailed) , name: NSNotification.Name(rawValue: KNotification_RequestFailed), object: nil)
        
        
        self.navigationController?.isNavigationBarHidden = true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //super.viewWillAppear(animated)
        
        //显示选择的城市
        guard let curCity = CityInfoCache.sharedInstance().commuteCurCity else {
            self.naView.rightTitle = "选择城市"
            return
        }
        
        if let cityName = curCity.city_name {
            self.naView.rightTitle = cityName
        }
        else{
            self.naView.rightTitle = "选择城市"
        }
        
        if needRefresh {
            needRefresh = false
            self.tableView.header.beginRefreshing()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var showMenuFlag:Bool = false
    override func  navigationViewBackClick() {
        if AuthorizeCache.sharedInstance().accessToken == nil || AuthorizeCache.sharedInstance().accessToken == "" {
            showMenuFlag = true
            self.toLoginViewController()
            return;
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: KShowMenuNotification), object: nil)
    }
    
    
    var bSelCityEnter = false
    override func navigationViewRightClick() {
        let controller:ShuttleBusSelectCityViewController = ShuttleBusSelectCityViewController.instance(withStoryboardName: "ShuttleBus")
        controller.isShuttleBus = false
        
        bSelCityEnter = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: -----
    func initInterface() {
        let cellNib = UINib(nibName: "ScheduleMainTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "mainTableViewCell")
        
        self.tableView.header = MJRefreshNormalHeader.init(refreshingBlock: {
            self.page = 1
            self.requestCommuteList(tipWait: false)
        })
        self.tableView.header.isAutomaticallyChangeAlpha = true
        self.tableView.footer = MJRefreshBackNormalFooter.init(refreshingBlock: {
            self.page += 1
            self.requestCommuteList(tipWait: false)
        })
    }
    
    //通勤车城市列表
    func reuestCommuteOpenCity() {
        //self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteOpenCity.rawValue)) { (params) in
            
        }
    }
    
    func requestCommuteList(tipWait:Bool) {
        //请求数据
        if tipWait {
            self.startWait()
        }
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteList.rawValue), params: {(param:NetParams?) -> Void in
            param?.method = EMRequstMethod.GET
            var adcode = ""
            if let curCity:CityObj = CityInfoCache.sharedInstance().commuteCurCity {
                adcode = curCity.adcode ?? ""
            }
            else {
                if let array:Array<CityObj> = CityInfoCache.sharedInstance().arCommuteCitys {
                    if array.count != 0 {
                        let city = array.first
                        adcode = city?.adcode ?? ""
                    }
                    else {
                        if let location = CityInfoCache.sharedInstance().curLocation {
                            adcode = location.adCode!
                        }
                    }
                }
   
            }
            
            var latitude = 0.0
            var longitude = 0.0
            if let location:FNLocation = CityInfoCache.sharedInstance().curLocation {
                latitude = location.latitude
                longitude = location.longitude
            }
            
            //是否登录
            var islogin = "true"
            if AuthorizeCache.sharedInstance().accessToken == nil  ||
                AuthorizeCache.sharedInstance().accessToken == ""{
                islogin = "false"
            }
            
            param?.data = ["adcode" : adcode,
                           "page" : self.page,
                           "take": self.row,
                           "latitude":latitude,
                           "longitude":longitude,
                           "islogin":islogin]
        })
    }
    
    func citySelectedChange(_ notification: Notification!) -> Void {
        if bSelCityEnter {
            bSelCityEnter = false
            self.tableView.header.beginRefreshing()
        }
    }
    
    //添加广告显示
    func addAdvertView() {
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_ConfigAdvertisement.rawValue)) { (params) in
            
        }
        
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_ConfigActivity.rawValue)) { (params) in
            params?.method = EMRequstMethod.GET
            params?.data = ["bannerOnly" : true]
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
    
    //MARK: tableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ScheduleMainTableViewCell = tableView.dequeueReusableCell(withIdentifier: "mainTableViewCell", for: indexPath) as! ScheduleMainTableViewCell
        let tempCommuteObj:CommuteObj = dataSource[indexPath.row] as! CommuteObj
        cell.setWithCommuteListObj(tempCommuteObj: tempCommuteObj)
        
        //跳转到购票
        cell.evaluationBlockCallback = { [weak self] (callbackObj:CommuteObj) -> Void in
            guard let strongSelf = self else { return}
            
            let controller:ScheduleBuyViewController = ScheduleBuyViewController.instance(withStoryboardName: "ScheduledBus")
            controller.id = callbackObj.id
            controller.commuteObj = callbackObj
            strongSelf.navigationController?.pushViewController(controller, animated: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 32))
//        let label:UILabel = UILabel(frame: CGRect(x: 17, y: 0, width: self.tableView.frame.size.width, height: 32))
//        label.backgroundColor = UIColor.clear
//        label.textColor = UIColor.gray
//        label.font = UIFont.systemFont(ofSize: 13)
//        label.text = "请点击查看上下客站点详情"
//        
//        view .addSubview(label)
//        return view
        
        return nil
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.performSegue(withIdentifier: "mainToDetail", sender: nil)
        let controller:ScheduleLineDetailViewController = ScheduleLineDetailViewController.instance(withStoryboardName: "ScheduledBus")
        controller.commuteObj = dataSource[indexPath.row] as? CommuteObj
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: http handle
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        
        guard let result:ResultDataModel = notification.object as? ResultDataModel else { self.stopWait(); return}
        if result.type == Int32(EmRequestType_CommuteList.rawValue) {
            self.stopWait()
            let tempArray:NSMutableArray = CommuteObj.mj_objectArray(withKeyValuesArray: result.data)
            //如果是第一页直接赋值，后面页面累加
            if self.page == 1 {
                dataSource = tempArray
            }
            else{
                dataSource.addObjects(from: tempArray as Array)
            }
            self.tableView.reloadData()
            self.tableView.header.endRefreshing()
            self.tableView.footer.endRefreshing()
            
        }
        else if result.type == Int32(EmRequestType_CommuteOpenCity.rawValue) {
            
            let arCitys:NSArray = CityObj.mj_objectArray(withKeyValuesArray: result.data)
            self.cityLogic(commuteCityArray: arCitys)
            //请求广告活动 因为需要城市adcode 所以返回后再请求
            self.addAdvertView()
            
        }
        else if result.type == Int32(EmRequestType_ConfigAdvertisement.rawValue) {

            if let dict:NSDictionary = result.data as? NSDictionary {
                //广告新接口使用
                //if let array:Array<Any> = dict["advertisements"] as? Array<Any>{
                //    NotificationCenter.default.post(name:  NSNotification.Name(rawValue:KNotificationShowActivity), object: array)
                //}
                
                //保存广告图片
                DispatchQueue.global().async {
                    if let advert:Dictionary<String, String> = dict["startup_advertisement"] as? Dictionary<String, String>{
                        if  let imgUrl = advert["image_url"] {
                            let target_url = advert["target_url"] ?? ""
                            let name = "startup_advertisement"
                            WebImageCache.instance().saveImage(imgUrl, name: name, success: { (success:Bool) in
                                if success {
                                    UserPreferences.sharedInstance().setAdvertInfo(["image_url":name, "target_url":target_url])
                                }
                                
                            })
                        }
                    }
                }
                
            }
        }
        else if result.type == Int32(EmRequestType_ConfigActivity.rawValue) {
            guard let array:Array<Any> = result.data as? Array<Any> else { return }
            if array.count != 0 {
                NotificationCenter.default.post(name:  NSNotification.Name(rawValue:KNotificationShowActivity), object: array)
            }
        }
        
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        guard let result:ResultDataModel = notification.object as? ResultDataModel else { self.stopWait(); return}
        if result.type == Int32(EmRequestType_CommuteOpenCity.rawValue) {
            NSLog("获取城市数据失败")
            super.httpRequestFailed(notification)
        }
        else if result.type == Int32(EmRequestType_CommuteList.rawValue) {
            if self.tableView.footer.isRefreshing() {
                self.page -= 1
            }
            
            super.httpRequestFailed(notification)
            
        }
        else  if result.type == Int32(EmRequestType_ConfigAdvertisement.rawValue) ||
                 result.type == Int32(EmRequestType_ConfigActivity.rawValue){
            super.httpRequestFailed(notification)
        }
        
        self.tableView.header.endRefreshing()
        self.tableView.footer.endRefreshing()
    }

    
    func cityLogic(commuteCityArray:NSArray?) {
        guard let commuteCityArray = commuteCityArray else {
            return
        }
        
        //保存城市数组
        CityInfoCache.sharedInstance().arCommuteCitys = commuteCityArray as! [CityObj]
        
        if let locationCity = CityInfoCache.sharedInstance().curLocation {
            var isFound:Bool = false
            for item in commuteCityArray.enumerated() {
                guard let city:CityObj = item.element as? CityObj else {continue}
                
                let index = locationCity.adCode.index(locationCity.adCode.startIndex, offsetBy: 4)
                let text = city.adcode?.substring(to: index)
                NSLog(text!)
                if city.adcode?.substring(to: index) == locationCity.adCode.substring(to: index) {
                    //保存当前城市
                    CityInfoCache.sharedInstance().commuteCurCity = city
                    isFound = true
                    break
                }
            }
            
            if !isFound {
                if commuteCityArray.count != 0 {
                    guard let city:CityObj = commuteCityArray.firstObject as? CityObj else {return}
                    CityInfoCache.sharedInstance().commuteCurCity = city
                }
                
            }
        }
        else {
            if commuteCityArray.count != 0 {
                guard let city:CityObj = commuteCityArray.firstObject as? CityObj else {return}
                CityInfoCache.sharedInstance().commuteCurCity = city
                
                let location:FNLocation = FNLocation()
                location.name = city.city_name
                location.latitude = location.coordinate.latitude
                location.longitude = location.coordinate.longitude
                location.adCode = city.adcode
                CityInfoCache.sharedInstance().curLocation = location
            }
        }
        
        //设置adcode
        if commuteCityArray.count != 0 {
            guard let city:CityObj = CityInfoCache.sharedInstance().commuteCurCity else {return}
            NetInterfaceManager.sharedInstance().setCommuteAdcode(city.adcode)
        }
        
        if let commuteCurCity = CityInfoCache.sharedInstance().commuteCurCity {
            self.naView.rightTitle = commuteCurCity.city_name
        }
        self.tableView.header.beginRefreshing()
    }
    
    override func loginSuccessHandler() {
        if let _:User = UserPreferences.sharedInstance().getUserInfo() {

            if showMenuFlag {
                showMenuFlag = false
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: KShowMenuNotification), object: nil)
            }
            
            self.tableView.header.beginRefreshing()
        }
    }
    
    override func logoutHandler() {
        needRefresh = true
    }
}
