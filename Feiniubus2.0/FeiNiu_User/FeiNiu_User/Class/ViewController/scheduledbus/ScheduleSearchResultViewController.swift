//
//  ScheduleSearchResultViewController.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/12/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

struct SearchParameterStruct {
    var adcode:String?              //城市编码
    var from:String?                //起点
    var to:String?                  //终点
    var onlatitude:Double = 0       //上车点纬度
    var onlongitude:Double = 0      //上车点经度
    var offlatitude:Double = 0      //下车点纬度
    var offlongitude:Double = 0     //下车点经度
}

class ScheduleSearchResultViewController: UserBaseUIViewController, UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noLineView: UIView!
    @IBOutlet weak var labelstarTAddr: UILabel!
    @IBOutlet weak var labelEndAddr: UILabel!
    
    //请求对象
    var requestParameter:SearchParameterStruct?
    var dataSource:NSMutableArray = NSMutableArray.init()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.noLineView.isHidden = true
        let cellNib = UINib(nibName: "ScheduledSeachResultTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "searchResultTableViewCell")
        
        //请求数据
        self.requestData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnApplyLineClick(_ sender: Any) {
        let c:ApplyScheduledViewController = ApplyScheduledViewController.instance(withStoryboardName: "Me")
        c.homeAddr = self.requestParameter?.from
        c.homeCoorinate = CLLocationCoordinate2D(latitude: (self.requestParameter?.onlatitude)!, longitude: (self.requestParameter?.onlongitude)!)
        c.componyAddr = self.requestParameter?.to
        c.componyCoorinate = CLLocationCoordinate2D(latitude: (self.requestParameter?.offlatitude)!, longitude: (self.requestParameter?.offlongitude)!)
        
        let controllers:NSMutableArray =  NSMutableArray.init(array: (self.navigationController?.viewControllers)!)
        controllers.removeObjects(in: NSMakeRange(controllers.count-2, 2))
        controllers.add(c)
        self.navigationController?.setViewControllers((controllers as NSArray as? [UIViewController])!, animated: true)
    }
    
    func requestData(){
        
        if requestParameter != nil {
//            AuthorizeCache.sharedInstance().refreshToken = "fadfdas"
            
            self.startWait()
            NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteSearch.rawValue), params: {(param:NetParams?) -> Void in
                
                let adcode:String = self.requestParameter?.adcode ?? ""
                let from:String = self.requestParameter?.from ?? ""
                let to:String = self.requestParameter?.to ?? ""
                let onlatitude:Double = self.requestParameter?.onlatitude ?? 0
                let onlongitude:Double = self.requestParameter?.onlongitude ?? 0
                let offlatitude:Double = self.requestParameter?.offlatitude ?? 0
                let offlongitude:Double = self.requestParameter?.offlongitude ?? 0
//                let onlatitude:Double = 30.646614
//                let onlongitude:Double = 104.067666
//                let offlatitude:Double = 30.646614
//                let offlongitude:Double = 104.067666
                
                //是否登录
                var islogin = "true"
                if AuthorizeCache.sharedInstance().accessToken == nil  ||
                    AuthorizeCache.sharedInstance().accessToken == ""{
                    islogin = "false"
                }
                param?.method = EMRequstMethod.GET
                param?.data = ["adcode" : adcode,
                               "s_address" : from,
                               "d_address": to,
                               "s_latitude": onlatitude,
                               "s_longitude": onlongitude,
                               "d_latitude": offlatitude,
                               "d_longitude": offlongitude,
                               "islogin": islogin]

            })
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 275;
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:ScheduledSeachResultTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "searchResultTableViewCell", for: indexPath) as! ScheduledSeachResultTableViewCell

        cell.setWithTempCommuteObj(tempCommuteObj: dataSource[indexPath.row] as! CommuteObj)
        
        //跳转到购票
        cell.evaluationBlockCallback = {[weak self] (callbackObj:CommuteObj) -> Void in
            guard let strongSelf = self else { return}
            
            let controller:ScheduleBuyViewController = ScheduleBuyViewController.instance(withStoryboardName: "ScheduledBus")
            controller.id = callbackObj.id
            controller.commuteObj = callbackObj
            strongSelf.navigationController?.pushViewController(controller, animated: true)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller:ScheduleLineDetailViewController = ScheduleLineDetailViewController.instance(withStoryboardName: "ScheduledBus")
        controller.commuteObj = dataSource[indexPath.row] as? CommuteObj
        controller.seachCommuteObj = dataSource[indexPath.row] as? CommuteObj
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: http handle
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        guard let result:ResultDataModel = notification.object as? ResultDataModel else { self.stopWait(); return}
        if result.type == Int32(EmRequestType_CommuteSearch.rawValue) {
            self.stopWait()
            let tempArray:NSMutableArray = CommuteObj.mj_objectArray(withKeyValuesArray: result.data)
            self.dataSource = tempArray
            
            if self.dataSource.count == 0 {
                self.tableView.isHidden = true
                self.noLineView.isHidden = false
                self.labelstarTAddr.text = self.requestParameter?.from
                self.labelEndAddr.text = self.requestParameter?.to
            }
            else {
                self.tableView.isHidden = false
                self.noLineView.isHidden = true
            }
            //刷新界面
            self.tableView.reloadData()
        }
        
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
    }
    
    override func loginSuccessHandler() {
        //登录成功重新请求搜索
        self.requestData()
    }

}
