//
//  ShuttleBusSelectCityViewController.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/10/8.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

@objc protocol ShuttleBusSelectCityViewControllerDelegate {
    @objc func citySelected(_ viewController:ShuttleBusSelectCityViewController,city:CityObj) -> Void
}

class ShuttleBusSelectCityViewController: UserBaseUIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var mainTableView: UITableView!
    //协议
    var selectCityDelegate: ShuttleBusSelectCityViewControllerDelegate?
    //城市列表
    var cityArray:[Any]?
    //定位信息
    var locationTextLabel:UILabel?
    var locationCity:CityObj = CityObj()
    
    //是否更改了数据
    var isChangCity:Bool = false
    
    //YES接送车, NO通勤车
    var isShuttleBus:Bool = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.tableFooterView = UIView.init(frame:CGRect.zero)
        // Do any additional setup after loading the view.
        
        if self.isShuttleBus {
            self.locationCity.adcode = CityInfoCache.sharedInstance().shuttleCurCity?.adcode
            self.locationCity.city_name = CityInfoCache.sharedInstance().shuttleCurCity?.city_name
            self.cityArray = CityInfoCache.sharedInstance().arShuttleCitys ?? nil
        }
        else {
            self.cityArray = CityInfoCache.sharedInstance().arCommuteCitys ?? nil
            self.locationCity.adcode = CityInfoCache.sharedInstance().commuteCurCity?.adcode
            self.locationCity.city_name = CityInfoCache.sharedInstance().commuteCurCity?.city_name
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if isChangCity {
            //使用通知，不用回调
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KChangeCityNotification), object: nil)
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
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0.5
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //需要缓存选中的城市
        var recordCityObj:CityObj?
        switch indexPath.section {
        case 0:
            recordCityObj  = locationCity
        case 1:
            //选择提供的城市
            if let city = cityArray?[indexPath.row] as? CityObj{
                recordCityObj = city
            }
            
        default:
            break
        }
        //记录存储
        if recordCityObj != nil && recordCityObj?.adcode != locationCity.adcode{
            //城市修改
            self.isChangCity = true
            //设置默认城市
            if self.isShuttleBus {
                CityInfoCache.sharedInstance().shuttleCurCity = recordCityObj
                //设置adcode
                NetInterfaceManager.sharedInstance().setShuttleAdcode(CityInfoCache.sharedInstance().shuttleCurCity.adcode)
            }
            else {
                CityInfoCache.sharedInstance().commuteCurCity = recordCityObj
                //设置adcode
                NetInterfaceManager.sharedInstance().setCommuteAdcode(CityInfoCache.sharedInstance().commuteCurCity.adcode)
            }
            
            //请求默认，汽车站，火车站，机场数据
            CityInfoCache.sharedInstance().setAirports([], trainStations: [], busStations: [])
            
            self.startWait()
            NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EMRequestType_StationInfo.rawValue), params: { (params:NetParams?) -> Void in
                params?.method = .GET
                params?.data = ["adcode":recordCityObj?.adcode as Any,
                                "type":"All"]
            })
        }
        else{
            _ = navigationController?.popViewController(animated:true)
        }
        
    }
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if cityArray != nil {
                return cityArray!.count
            }
            else {
                return 0
            }
            
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "cellId"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if  cell == nil {
            cell = UITableViewCellEx()
        }
        
        if indexPath.section == 0 {
            let locationCell:UITableViewCellEx = UITableViewCellEx()
            self.locationTextLabel = locationCell.textLabel
            locationCell.imageView?.image = UIImage.init(named: "icon_pitch")
            locationCell.selectionStyle = .none

            self.locationTextLabel?.text = locationCity.city_name
            self.locationTextLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            self.locationTextLabel?.textColor = UITextColor_Black
            return locationCell
        }
        else if indexPath.section == 1{
            //设置数据
            let cityModel:CityObj = (cityArray?[indexPath.row] as? CityObj)!
            cell?.textLabel?.text = cityModel.city_name
        }
        cell?.selectionStyle = .none
        cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        cell?.textLabel?.textColor = UITextColor_Black
        
        return cell!
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView()
        headView.backgroundColor = UIColor.clear
        //添加label
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = UITextColor_DarkGray
        headView.addSubview(titleLabel)
        titleLabel.frame = CGRect.init(x: 24, y: 0, width: deviceWidth, height: 32.0)
        switch section {
        case 0:
            titleLabel.text = "当前城市"
        case 1:
            titleLabel.text = "开通城市"
        default:
            break
        }
        return headView
    }
    //MARK: - Http Handler
    
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        self.stopWait()
        let result:ResultDataModel = notification.object as! ResultDataModel
        
        if result.type == Int32(EMRequestType_StationInfo.rawValue) {
            //机场车站数据
            let stationInfo:NSDictionary = result.data as! NSDictionary
            let airports:NSArray!       = StationObj.mj_objectArray(withKeyValuesArray: stationInfo["airport"] as? [Any])
            let trainStations:NSArray!  = StationObj.mj_objectArray(withKeyValuesArray: stationInfo["train_station"] as? [Any])
            let busStations:NSArray!    = StationObj.mj_objectArray(withKeyValuesArray: stationInfo["bus_station"] as? [Any])
            
            CityInfoCache.sharedInstance().setAirports(airports as? [Any], trainStations: trainStations as? [Any], busStations: busStations as? [Any])
            
            _ = navigationController?.popViewController(animated:true)
        }
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
    }
}
