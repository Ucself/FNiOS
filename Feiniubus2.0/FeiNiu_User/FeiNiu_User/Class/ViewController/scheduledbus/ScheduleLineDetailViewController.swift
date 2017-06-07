//
//  ScheduleLineDetailViewController.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/12/12.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class ScheduleLineDetailViewController: UserBaseUIViewController, UITableViewDataSource,UITableViewDelegate {
    
    //数据对象
    var commuteObj:CommuteObj?
    
    var seachCommuteObj:CommuteObj?
    //界面控件
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var labelPrice: UILabel! //优惠后价格
    @IBOutlet weak var labelOriginalPrice: UILineLabel! //原价
    @IBOutlet weak var labelDiscount: UILabel!  //折扣
    @IBOutlet weak var priceCenterY: NSLayoutConstraint!
    
    
    @IBOutlet weak var lebelStart: UILabel!
    @IBOutlet weak var labelEnd: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelCout: UILabel!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageRemark: UIImageView!
    @IBOutlet weak var labelRemark: UILabel!
    
    
    
    var photoView: StationPhotoView?
    
    //MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let cellNib = UINib(nibName: "ScheduledBusLineDetailTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "lineDetailCell")
        
        //刷新界面
        self.refreshUI()
        self.requestData()
        
        self.view.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if needRefresh {
            needRefresh = false
            self.requestData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func refreshUI() {
        if commuteObj == nil {
            commuteObj = CommuteObj.init()
        }
        
        //分解行程名称
        let startName:String = commuteObj!.starting ?? ""
        let endName:String =  commuteObj!.destination ?? ""
//        let str1Array = commuteObj!.name?.components(separatedBy: "&")
//        if let nameArray = str1Array {
//            if nameArray.count > 0 {
//                startName = nameArray[0]
//            }
//            if nameArray.count > 1 {
//                endName = nameArray[1]
//            }
//        }
        
        self.lebelStart.text = startName
        self.labelEnd.text = endName
        self.labelTime.text = "\(commuteObj!.timeFormat(timeString: commuteObj?.line_departure_time ?? ""))(始发) - \(commuteObj!.timeFormat(timeString: commuteObj?.line_arrival_time ?? ""))(到达)"
        self.labelCout.text = "已有\(commuteObj!.sold_tickets_count)人乘坐"
        self.labelCout.attributedText = NSString.hintString(withIntactString: self.labelCout.text, hintString: "\(commuteObj!.sold_tickets_count)", intactColor: UITextColor_DarkGray, hintColor: UIColorFromRGB(0xFE6E35)) as! NSAttributedString?
        //说明标记
        if self.commuteObj!.remark != "" {
            self.topViewHeight.constant = 74
            self.imageRemark.isHidden = false
            self.labelRemark.isHidden = false
            self.labelRemark.text = self.commuteObj!.remark
        }
        else {
            self.topViewHeight.constant = 62
            self.imageRemark.isHidden = true
            self.labelRemark.isHidden = true
        }
        //价格展示
        self.labelPrice.text = NSString.calculatePrice(commuteObj!.promotion_price) //String.init(format: "¥%.2f元", commuteObj!.price/100.0)
        priceCenterY.constant = -8
        if commuteObj!.is_activity_price {
            //活动价
            labelDiscount.text = "活动立减\(NSString.calculatePriceNO(commuteObj!.discount)!)元"
            labelOriginalPrice.text = NSString.calculatePrice(commuteObj!.price)

        }
        else if AuthorizeCache.sharedInstance().accessToken == nil  ||
            AuthorizeCache.sharedInstance().accessToken == ""{
            //未登录时
            labelDiscount.text = "登录后查看优惠价格"
            labelOriginalPrice.text = ""
            
        }
        else if commuteObj!.discount > 0 {
            labelDiscount.text = "已用优惠劵抵扣\(NSString.calculatePriceNO(commuteObj!.discount)!)元"
            labelOriginalPrice.text = NSString.calculatePrice(commuteObj!.price)
        }
        else {
            //没有优惠价格
            labelDiscount.text = ""
            labelOriginalPrice.text = ""
            priceCenterY.constant = 0
        }
    }
    
    func requestData() {
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteDetail.rawValue), params: {(param:NetParams?) -> Void in
            
            //是否登录
            var islogin = "true"
            if AuthorizeCache.sharedInstance().accessToken == nil  ||
                AuthorizeCache.sharedInstance().accessToken == ""{
                islogin = "false"
            }
            
            param?.method = EMRequstMethod.GET
            param?.data = ["id" : self.commuteObj?.id ?? "",
                           "islogin" : islogin]
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func navigationViewRightClick() {
        super.navigationViewRightClick()
        //分享页面
        let c:InviteViewController = InviteViewController.instance(withStoryboardName: "Me")
        c.commuteId = self.commuteObj?.id
        c.controller = self
        c.showInViewController()
    }
    
    
    //MARK: - photoview
    func getPhotoView() -> StationPhotoView {
        if self.photoView == nil {
            self.photoView = Bundle.main.loadNibNamed("StationPhotoView", owner: self, options: nil)?.first as? StationPhotoView
        }
        
        return self.photoView!
    }
    
    //MARK: - UITableviewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if commuteObj?.on_station_infos?.count != 0 {
            if let onInforArray:Array = commuteObj?.on_station_infos , let offInforArray:Array = commuteObj?.off_station_infos {
                return onInforArray.count + offInforArray.count + 1
            }
        }

        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let onInforArray:Array = commuteObj?.on_station_infos ,indexPath.row == onInforArray.count {
            //蓝色箭头高度
            return 46
        }
        return 35
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
        let cell:ScheduledBusLineDetailTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "lineDetailCell", for: indexPath) as! ScheduledBusLineDetailTableViewCell
        
        //上线线
        if indexPath.row == 0 {
            cell.setVerticalLine(type: 0)
        }
        else if indexPath.row == (commuteObj?.on_station_infos?.count)! + (commuteObj?.off_station_infos?.count)! {
            cell.setVerticalLine(type: 1)
        }
        else {
            cell.setVerticalLine(type: 2)
        }
        //还原中间数据
        cell.setHorizontalLine(type: 0)
        cell.imgDot.image = UIImage(named: "icon_start_or_end_20*20")
        cell.lablelStation.textColor = UITextColor_DarkGray
        cell.dotTopCons.constant = 5;
        
        //中间数据
        if let onInforArray:Array = commuteObj?.on_station_infos , let offInforArray:Array = commuteObj?.off_station_infos {
            
            var tempStationInfo:StationInfo?
            
            if indexPath.row < onInforArray.count {
                tempStationInfo = onInforArray[indexPath.row] as? StationInfo
                //上车点的数据
                cell.setWithStationInfo(tempStationInfo: tempStationInfo ,isOffStation: false)
                //是否是上车点
                if seachCommuteObj != nil && tempStationInfo?.name == seachCommuteObj?.on_station?.name{
                    cell.setHorizontalLine(type: 1)
                    cell.imgDot.image = UIImage(named: "icon_start_20*20")
                    cell.lablelStation.textColor = UIColorFromRGB(0x000000)
                }
            }
            else if indexPath.row == onInforArray.count {
                //蓝色箭头
                cell.dotTopCons.constant = 10;
                cell.setWithStationInfo(tempStationInfo: nil,isOffStation: false)
            }
            else {
                tempStationInfo = offInforArray[indexPath.row - onInforArray.count - 1] as? StationInfo
                //下车点的数据
                cell.setWithStationInfo(tempStationInfo: tempStationInfo,isOffStation: true)
                //是否是下车车点
                if seachCommuteObj != nil && tempStationInfo?.name == seachCommuteObj?.off_station?.name{
                    cell.setHorizontalLine(type: 1)
                    cell.imgDot.image = UIImage(named: "icon_end_20*20")
                    cell.lablelStation.textColor = UIColorFromRGB(0x000000)
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let view = self.getPhotoView()
        
        if let onInforArray:Array = commuteObj?.on_station_infos , let offInforArray:Array = commuteObj?.off_station_infos {
            
            if indexPath.row < onInforArray.count {
                //上车点的数据
                let station:StationInfo? = onInforArray[indexPath.row] as? StationInfo
                view.labelTitle.text = station?.name
                view.labelDetail.text = station?.address
                
                if let image = station?.image_uri {
                    view.imageView.setImageWith(URL(string: image))
//                    view.imageView.sd_setImage(with: URL(string: image), placeholderImage: nil, options: nil, progress: { (received, expected, url) in
//                        
//                    }, completed: { (image, error, type, url) in
//                        
//                    })
                }
                
            }
            else if indexPath.row == onInforArray.count {
                return
            }
            else {
                //下车点的数据
                let station:StationInfo? = offInforArray[indexPath.row - onInforArray.count - 1] as? StationInfo
                view.labelTitle.text = station?.name
                view.labelDetail.text = station?.address

                if let image = station?.image_uri {
                    view.imageView.setImageWith(URL(string: image))
                }
            }
        }
        
        
        view.showIn(self.view)

    }
    
    
    
    //MARK: - Action
    
    @IBAction func btnBuyClick(_ sender: Any) {
        
        let controller:ScheduleBuyViewController = ScheduleBuyViewController.instance(withStoryboardName: "ScheduledBus")
        controller.id = self.commuteObj?.id
        controller.commuteObj = self.commuteObj
        self.navigationController?.pushViewController(controller, animated: true)
        
    }

    //MARK: http handle
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        guard let result:ResultDataModel = notification.object as? ResultDataModel else { self.stopWait(); return}
        if result.type == Int32(EmRequestType_CommuteDetail.rawValue) {
            self.stopWait()
            let commuteObj:CommuteObj? = CommuteObj.mj_object(withKeyValues: result.data)
            self.commuteObj = commuteObj
            //搜索的站点信息
            self.commuteObj?.on_station?.name = self.seachCommuteObj?.on_station?.name
            self.commuteObj?.off_station?.name = self.seachCommuteObj?.off_station?.name
            //刷新界面
            self.refreshUI()
            self.tableView.reloadData()
            //显示提示
            //显示引导提示
            if UserPreferences.sharedInstance().getLineGuide() == nil {
                let guidView:ScheduleGuideView = ScheduleGuideView.initFromXib()
                guidView.showTipView = 4
                guidView.showInView(view: self.view)
                
                UserPreferences.sharedInstance().setLineGuide("LineGuide")
            }
            
        }
        
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
    }
    
    var needRefresh = false
    override func loginSuccessHandler() {
        needRefresh = true
    }
}
