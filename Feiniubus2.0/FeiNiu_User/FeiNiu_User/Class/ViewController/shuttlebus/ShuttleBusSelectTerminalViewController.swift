//
//  ShuttleBusSelectTerminalViewController.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/10/8.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

protocol ShuttleBusSelectTerminalViewControllerDelegate {
    //选择站点回调
    func didSelectStationCell(_ shuttleBusSelectTerminalViewController:ShuttleBusSelectTerminalViewController,station:StationObj)
}

class ShuttleBusSelectTerminalViewController: UserBaseUIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var navView: UINavigationView!
    @IBOutlet weak var currentCitylbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //变量
    let shuttleBusOrderStoryboard:UIStoryboard = UIStoryboard.init(name: "ShuttleBus", bundle: nil)
    var shuttleCategory:ShuttleCategory = .AirportPickup
    var selectTerminalDelegate:ShuttleBusSelectTerminalViewControllerDelegate?
    //站点数据源
    var dateSource:[StationObj]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //设置名称
        if let currentCityName = CityInfoCache.sharedInstance().shuttleCurCity?.city_name {
            currentCitylbl.text = currentCityName
        }
        //
        self.initInterface()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func initInterface() -> Void {
        //设置导航条名称和数据源
        switch shuttleCategory {
        case .AirportPickup,.AirportSend:
            self.navView.title = "选择航站楼"
            dateSource = CityInfoCache.sharedInstance().arAirports
        case .TrainPickup,.TrainSend:
            self.navView.title = "选择火车站"
            dateSource = CityInfoCache.sharedInstance().arTrainStations
        case .BusPickup,.BusSend:
            self.navView.title = "选择汽车站"
            dateSource = CityInfoCache.sharedInstance().arBusStations
        }
        
        self.tableView.reloadData()
    }
    //MARK: Action
    
    @IBAction func currentCityClick(_ sender: Any) {
        let selectCityViewController:UIViewController = shuttleBusOrderStoryboard.instantiateViewController(withIdentifier: "ShuttleBusSelectCityViewController")
        self.navigationController?.pushViewController(selectCityViewController, animated: true)
    }
    // MARK:UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 44.0
    }
    // MARK:UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let count = dateSource?.count {
            return count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cellId = "cellId"
        var cell:UITableViewCellEx? = tableView.dequeueReusableCell(withIdentifier: cellId) as! UITableViewCellEx?
        if cell == nil {
            cell = UITableViewCellEx()
        }
        if let station:StationObj = self.dateSource?[indexPath.row] {
            cell?.textLabel?.text = station.name
        }
        cell?.textLabel?.textColor = UITextColor_Black
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //回调
        self.selectTerminalDelegate?.didSelectStationCell(self, station: ((self.dateSource?[indexPath.row])! as StationObj))
        _ = navigationController?.popViewController(animated:true)
    }
}
