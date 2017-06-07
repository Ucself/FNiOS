//
//  ScheduleOrderDetailViewController.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 17/1/11.
//  Copyright © 2017年 tianbo. All rights reserved.
//

import UIKit

class ScheduleOrderDetailViewController: UserBaseUIViewController, UITableViewDataSource,UITableViewDelegate {

    var orderObj:CommuteOrderObj?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var carView: UIView!
    @IBOutlet weak var remarkImage: UIImageView!
    @IBOutlet weak var remarkImageHeight: NSLayoutConstraint!

    
    @IBOutlet weak var navView: UINavigationView!
    //车站数组
    var arSatations:Array<StationInfo> = Array()
    var photoView:StationPhotoView?
    //定时器
    var timer:Timer?
    
    //之前订单状态
    var beforeOrderState = "Unkown"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //注册
        let cellNib = UINib(nibName: "ScheduledBusOrderDetailTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "orderDetailCell")
        //请求数据
        self.requestData(waitSymbol: true)
        // Do any additional setup after loading the view.
        self.refreshUI()
        
        self.view.backgroundColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //启动定时获取
        self.startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //结束定时
        self.endTimer()
    }
    
    deinit {
        //结束定时
        self.endTimer()
    }
    

    override func navigationViewRightClick() {
        //名称
        if self.orderObj!.is_refundable {
            let alertView:UserCustomAlertView = UserCustomAlertView(title: "确定退票吗？", message: "", delegate: self, buttons: ["退票","取消"])
            alertView.delegate = self
            alertView.show(in: self.view)
        }
        else{
            //投诉
            let complaintViewController:ScheduleCancelReasonViewController = ScheduleCancelReasonViewController.instance(withStoryboardName: "ScheduledOrder")
            complaintViewController.orderId = self.orderObj?.id
            complaintViewController.viewControllerType = .Complaint
            self.navigationController?.pushViewController(complaintViewController, animated: true)
        }
    }
    
    override func userAlertView(_ alertView: UserCustomAlertView!, dismissWithButtonIndex btnIndex: Int) {
        if btnIndex == 0 {
            //退票
            self.startWait()
            NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteOrderRefund.rawValue), params: {(param:NetParams?) -> Void in
                param?.method = EMRequstMethod.DELETE
                param?.data = ["id" : self.orderObj?.id ?? ""]
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
    
    func requestData(waitSymbol:Bool) {
        if waitSymbol {
            self.startWait()
        }
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteOrderTicket.rawValue), params: {(param:NetParams?) -> Void in
            param?.method = EMRequstMethod.GET
            param?.data = ["id" : self.orderObj?.id ?? ""]
        })
    }
    
    
    func refreshUI(){
        self.startLabel.text = orderObj?.start_station_name ?? ""
        self.endLabel.text = orderObj?.destination_station_name ?? ""
        
        let toDate:Date = DateUtils.date(from: orderObj?.ticket_date ?? "", format: "yyyy-MM-dd HH:mm:ss")
        self.dateLabel.text = DateUtils.formatDate(toDate, format: "yyyy-MM-dd")

        self.remarkLabel.text = orderObj?.remark ?? ""//"周一提前10分钟发车"
        if self.remarkLabel.text == "" {
            self.remarkImageHeight.constant = 0
        }
        else{
            self.remarkImageHeight.constant = 10
        }
        //名称
        switch CommuteOrderState(rawValue: self.orderObj!.order_state)! {
        case .Dispatched:
            self.navView.title = "待出发"
        case .Waiting:
            self.navView.title = "已发车"
        case .Transporting:
            self.navView.title = "接送中"
        case .Completed,.Evaluated:
            self.navView.title = "已完成"
        default:
            self.navView.title = ""
            self.navView.rightTitle = ""
        }
        //是否可退票
        if self.orderObj!.is_refundable {
            self.navView.rightTitle = "退票"
        }
        else{
            self.navView.rightTitle = "投诉"
        }
        //车辆信息
        //清除所有子控件
        for view in self.carView.subviews {
            view.removeFromSuperview()
        }
        //存在车辆
        if self.orderObj?.buses != nil && (self.orderObj?.buses?.count)! > 0 {
            for item in 0..<(self.orderObj?.buses?.count)! {
                let busInfor:busInforObj = self.orderObj?.buses?[item] as! busInforObj
                let licenseLabel:UILabel = UILabel.init()
                licenseLabel.text = busInfor.license
                licenseLabel.textColor = UITextColor_Black
                licenseLabel.font = UIFont.systemFont(ofSize: 11)
                licenseLabel.backgroundColor = UIColor.clear
//                licenseLabel.textAlignment = .center
//                licenseLabel.layer.cornerRadius = 2
//                licenseLabel.layer.borderColor = UIColorFromRGB(0x000000).cgColor
//                licenseLabel.layer.borderWidth = 0.5
//                licenseLabel.clipsToBounds = true
                //布局
                let leftEdge = item == 0 ? 0 : 5
                self.carView.addSubview(licenseLabel)
//                licenseLabel.snp.makeConstraints({ (maker) in
//                    maker.top.equalTo(self.carView)
//                    maker.left.equalTo(self.carView).offset(51*item + leftEdge)
//                    maker.width.equalTo(51)
//                    maker.height.equalTo(15)
//                })
                licenseLabel.mas_makeConstraints({ (maker) in
                    maker!.top.equalTo()(self.carView)
                    maker!.left.equalTo()(self.carView)?.setOffset(CGFloat(60*item + leftEdge))
                    maker!.width.equalTo()(60)
                    maker!.height.equalTo()(15)
                })
                
            }
        }
    }
    
    //MARK: - Action
    @IBAction func ticketClick(_ sender: Any) {
        let controller:ScheduleTicketViewController = ScheduleTicketViewController.instance(withStoryboardName: "ScheduledOrder")
        controller.specTicket = self.orderObj
        self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func shareClick(_ sender: Any) {
        let c:InviteViewController = InviteViewController.instance(withStoryboardName: "Me")
        c.commuteId = self.orderObj?.line_id
        c.controller = self
        c.showInViewController()
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
        self.requestData(waitSymbol: false)
        print("handleTimer()")
    }
    
    //MARK: - UITableviewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let onInforArray:Array = orderObj?.on_station_infos , let offInforArray:Array = orderObj?.off_station_infos {
            return onInforArray.count + offInforArray.count + 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 32))
        view.backgroundColor = UIColor.white
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let onInforArray:Array = orderObj?.on_station_infos else {return 35}
        if indexPath.row == onInforArray.count {
            return 46
        }
        
        return 35;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ScheduledBusOrderDetailTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "orderDetailCell", for: indexPath) as! ScheduledBusOrderDetailTableViewCell
        
        if indexPath.row == 0 {
            cell.setVerticalLine(type: 0)
        }
        else if indexPath.row == (orderObj?.on_station_infos?.count)! + (orderObj?.off_station_infos?.count)! {
            cell.setVerticalLine(type: 1)
        }
        else {
            cell.setVerticalLine(type: 2)
        }
        
        cell.setHorizontalLine(type: 0)
        
        
//        self.orderObj?.last_station_id = "1289961721045975267"
//        self.orderObj?.last_station_site_state = "Leave"
        //设置显示
        func configCell (_ station:StationInfo?, isOnStaion:Bool) {
            cell.setWithStationInfo(tempStationInfo: station, isOnstation: isOnStaion)
            
            let stationName = isOnStaion ? orderObj?.on_station_name : orderObj?.off_station_name
            let img = isOnStaion ?  UIImage(named: "icon_start_20*20") : UIImage(named: "icon_end_20*20")
            
            if let station = station {
                if station.name == stationName {
                    cell.imgDot.image = img
                    cell.lablelStation.textColor = UITextColor_Black
                    cell.setHorizontalLine(type: 1)
                }
                
                //车图标位置显示
                //if self.orderObj?.order_state == "Transporting" {
                if let Id:String = self.orderObj?.last_station_id {
                    if Id == station.id {
                        cell.carImg.isHidden = false
                        if self.orderObj?.last_station_site_state == "Arrive" {
                            //到达
                            cell.carImgTopCons.constant = -3
                        }
                        else {
                            //离开
                            cell.carImgTopCons.constant = 14
                            
                            if indexPath.row == (orderObj?.on_station_infos?.count)! - 1{
                                //上车站点最后一站已离开状态, 车辆图显示到下一行
                                cell.carImg.isHidden = true
                            }
                        }
                    }
                    else {
                        cell.carImg.isHidden = true
                    }
                }
                //}

                
                cell.imgDotTopCons.constant = 5
            }
            else {
                cell.imgDotTopCons.constant = 10
                
                //箭头位置与车位置重叠处理
                cell.carImg.isHidden = true
                if let Id:String = self.orderObj?.last_station_id {
                    if let onInforArray:Array = orderObj?.on_station_infos {
                        let station = onInforArray.last as? StationInfo
                        if Id == station?.id && self.orderObj?.last_station_site_state != "Arrive" {
                            cell.imgDot.image = UIImage.init(named: "icon_car_feiniu")
                        }
                        else {
                            cell.imgDot.image = UIImage.init(named: "icon_arrow")
                        }
                    }
                }
            }
        }
        
        if let onInforArray:Array = orderObj?.on_station_infos , let offInforArray:Array = orderObj?.off_station_infos {
            
            if indexPath.row < onInforArray.count {
                //上车点的数据
                guard let station = onInforArray[indexPath.row] as? StationInfo else {return cell}
                configCell(station, isOnStaion: true)

            }
            else if indexPath.row == onInforArray.count {
                //红色箭头
                configCell(nil, isOnStaion: false)
            }
            else {
                //下车点的数据
                guard let station = offInforArray[indexPath.row - onInforArray.count - 1] as? StationInfo else {return cell}
                configCell(station, isOnStaion: false)

            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let view = self.getPhotoView()
        
        if let onInforArray:Array = orderObj?.on_station_infos , let offInforArray:Array = orderObj?.off_station_infos {
            
            if indexPath.row < onInforArray.count {
                //上车点的数据
                guard let station = onInforArray[indexPath.row] as? StationInfo else {return }
                view.labelTitle.text = station.name
                view.labelDetail.text = station.address
                if let image = station.image_uri {
                    view.imageView.setImageWith(URL(string: image))
                }
                
            }
            else if indexPath.row == onInforArray.count {
  
            }
            else {
                //下车点的数据
                guard let station = offInforArray[indexPath.row - onInforArray.count - 1] as? StationInfo else {return }
                view.labelTitle.text = station.name
                view.labelDetail.text = station.address
                if let image = station.image_uri {
                    view.imageView.setImageWith(URL(string: image))
                }
            }
        }
        
        
        view.showIn(self.view)
        
    }
    
    func getPhotoView() -> StationPhotoView {
        if self.photoView == nil {
            self.photoView = Bundle.main.loadNibNamed("StationPhotoView", owner: self, options: nil)?.first as? StationPhotoView
        }
        
        return self.photoView!
    }
    
    //处理最后一站状态, 不能为离开
    func specHandleArray() {
        guard let offInforArray:Array = orderObj?.off_station_infos else {return}
        if let station = offInforArray.last as? StationInfo{
            if self.orderObj?.last_station_id == station.id {
                if self.orderObj?.last_station_site_state == "Leave" {
                    self.orderObj?.last_station_site_state = "Arrive"
                }
            }
        }
        
        
        
    }
    //MARK: http handle
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        guard let result:ResultDataModel = notification.object as? ResultDataModel else { self.stopWait(); return}
        if result.type == Int32(EmRequestType_CommuteOrderTicket.rawValue) {
            self.stopWait()
            let commuteOrderObj:CommuteOrderObj? = CommuteOrderObj.mj_object(withKeyValues: result.data)
            self.orderObj = commuteOrderObj
            
            self.specHandleArray()
            //刷新界面
            self.refreshUI()
            self.tableView.reloadData()
            //判断列表是否需要刷新
            if CommuteOrderState(rawValue:self.beforeOrderState) != .Unkown && self.beforeOrderState != commuteOrderObj?.order_state  {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: KOrderRefreshNotification), object: nil)
            }
            self.beforeOrderState = (commuteOrderObj?.order_state)!
            
            //行程结束停止定时器
            if CommuteOrderState(rawValue:(commuteOrderObj?.order_state)!) == .Completed {
                self.endTimer()
            }
            
            
            
        }
        else if result.type == Int32(EmRequestType_CommuteOrderRefund.rawValue) {
            self.stopWait()
            //结束计时器
            self.endTimer()
            
            //设置列表需要刷新
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KOrderRefreshNotification), object: nil)
            //跳转到退票原因
            let controller:ScheduleCancelReasonViewController = ScheduleCancelReasonViewController.instance(withStoryboardName: "ScheduledOrder")
            controller.orderId = self.orderObj?.id
            controller.viewControllerType = .Reason
            let controllers:NSMutableArray =  NSMutableArray.init(array: (self.navigationController?.viewControllers)!)
            controllers.removeLastObject()
            controllers.add(controller)
            self.navigationController?.setViewControllers((controllers as NSArray as? [UIViewController])!, animated: true)
        }
        
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
    }
    
}
