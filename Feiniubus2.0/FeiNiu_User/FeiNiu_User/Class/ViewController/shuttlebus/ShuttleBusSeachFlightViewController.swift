//
//  ShuttleBusSeachFlightViewController.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/10/9.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNNetInterface

@objc protocol ShuttleBusSeachFlightViewControllerDelegate {
    //选择后回调
    @objc optional func seachFlightViewController(_ viewController:UIViewController ,didSelectFlightInforObj:FlightInforObj) -> Void
}



class ShuttleBusSeachFlightViewController: UserBaseUIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navView: UINavigationView!
    var headLable: UILabel! = UILabel(frame: CGRect(x: 24, y: 0, width: 200, height: 32))
    
    //变量
    var isPickup:Bool = false;
    var flightInfor:FlightInforObj?
    var flightInforArray:Array<Any>?
    var seachFlightDelegate:ShuttleBusSeachFlightViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initInterface() -> Void {
        //消除多余的横线
        self.tableView.tableFooterView = UIView.init(frame:CGRect.zero)

        //设置基础界面
        self.navView.title = flightInfor?.flight_number ?? ""
        
        self.tableView.reloadData()
        self.headLable.text = "\((flightInfor?.seachDate ?? "")!)( 共\(self.flightInforArray!.count)个航段)"

    }
    //点击后返回界面
    func gotoReturnSelect(inforObj:FlightInforObj){
        //向航班也返回
        let resultFlightInfor:FlightInforObj = inforObj
        resultFlightInfor.seachDate = flightInfor?.seachDate
        
        var city = ""
        if self.isPickup {
            city = resultFlightInfor.arr_city!
        }
        else {
            city = resultFlightInfor.dep_city!
        }
        
        resultFlightInfo = resultFlightInfor
        //是否是开通城市
        if self.chekcCityInfo(city) {
            //控制器跳出
            self.seachFlightDelegate?.seachFlightViewController?(self, didSelectFlightInforObj: resultFlightInfor)
            _ = navigationController?.popToRootViewController(animated: true)
        }
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
            let alert: UserCustomAlertView = UserCustomAlertView(title: "航班\(type)服务未开通", message: "\"\(city)\"还未开通服务, 小牛正努力开拓疆土, \r\n您可以切换到其它城市哦!", delegate: self)
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
                                    "type":"All"]
                })
                
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (self.flightInforArray != nil) ? self.flightInforArray!.count : 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tempFlightInfor:FlightInforObj = flightInforArray![indexPath.row] as! FlightInforObj
        let cellId = "cellId"
        var cell:UITableViewCellEx? = tableView.dequeueReusableCell(withIdentifier: cellId) as! UITableViewCellEx?
        if cell == nil {
            cell = UITableViewCellEx.init(style: .subtitle, reuseIdentifier: cellId)
        }

        cell?.accessoryType = .disclosureIndicator
        cell?.accessoryView = UIImageView.init(image: UIImage.init(named: "icon_right"))
        
        cell?.textLabel?.text = "\(tempFlightInfor.dep_city!) － \(tempFlightInfor.arr_city!)"
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell?.textLabel?.textColor = UITextColor_Black

        cell?.detailTextLabel?.text = "\(tempFlightInfor.dep_time!)-\(tempFlightInfor.arr_time!)"
        cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 11)
        cell?.detailTextLabel?.textColor = UITextColor_DarkGray
        
        //添加一个状态
        let flightStateLabel = UILabel.init()
        flightStateLabel.text = tempFlightInfor.flight_state
        flightStateLabel.textColor = UITextColor_DarkGray
        flightStateLabel.textAlignment = .right
        flightStateLabel.font = UIFont.systemFont(ofSize: 12)
        cell?.addSubview(flightStateLabel)
        flightStateLabel.makeConstraints { (maker) in
            maker?.centerY.equalTo()(cell)?.setOffset(0)
            maker?.right.equalTo()(cell)?.setOffset(-39)
        }
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //返回到选择页
        let tempFlightInfor:FlightInforObj = flightInforArray![indexPath.row] as! FlightInforObj
        self.gotoReturnSelect(inforObj: tempFlightInfor)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view:UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 32))

        headLable.backgroundColor = UIColor.clear
        headLable.textColor = UIColor.gray
        headLable.textAlignment = .left
        headLable.font = UIFont.systemFont(ofSize: 13)
        //headLable.text = "请点击查看上下客站点详情"

        view.addSubview(headLable)
        
        let line:UIView = UIView(frame: CGRect(x: 0, y: 31.5, width: self.tableView.frame.size.width, height: 0.5))
        line.backgroundColor = UIColorFromRGB(0xe6e6e6)
        view.addSubview(line)
        return view

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
    
        if self.flightInforArray != nil {
            if indexPath.row == (self.flightInforArray?.count)!-1 {
                cell.separatorInset = .zero
            }
        }
        
    }
    
    //MARK: HTTP response
    override func httpRequestFinished(_ notification: Notification!) {
        self.stopWait()
        
        guard let result:ResultDataModel = notification.object as? ResultDataModel else {return}
        switch result.type {
        case Int32(EMRequestType_StationInfo.rawValue):
            //机场车站数据
            let stationInfo:NSDictionary = result.data as! NSDictionary
            let airports:NSArray!       = StationObj.mj_objectArray(withKeyValuesArray: stationInfo["airport"] as? [Any])
            let trainStations:NSArray!  = StationObj.mj_objectArray(withKeyValuesArray: stationInfo["train_station"] as? [Any])
            let busStations:NSArray!    = StationObj.mj_objectArray(withKeyValuesArray: stationInfo["bus_station"] as? [Any])
            
            CityInfoCache.sharedInstance().setAirports(airports as? [Any], trainStations: trainStations as? [Any], busStations: busStations as? [Any])
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KChangeCityNotification), object: nil)
            
            self.seachFlightDelegate?.seachFlightViewController?(self, didSelectFlightInforObj: self.resultFlightInfo!)
            _ = navigationController?.popToRootViewController(animated: true)
            break
        default:
            break
        }
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
    }
    
    
}


class UITableViewCellEx:UITableViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if nil != self.imageView?.image{
            var rect:CGRect! = self.imageView?.frame
            rect.origin.x = 24
            self.imageView?.frame = rect
            
            rect = self.textLabel?.frame
            rect.origin.x = 48
            self.textLabel?.frame = rect
        }
        else {
            if let frame = self.textLabel?.frame {
                var rect:CGRect! = frame
                rect.origin.x = 24
                self.textLabel?.frame = rect
            }
            
            if let frame = self.detailTextLabel?.frame {
                var rect:CGRect! = frame
                rect.origin.x = 24
                self.detailTextLabel?.frame = rect
            }
        }
    }
}
