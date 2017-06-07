//
//  BNSDetailOrderViewController.swift
//  FeiNiu_Business
//
//  Created by lbj@feiniubus.com on 16/9/6.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNCommon
import FNSwiftNetInterface
import FNUIView

class BNSDetailOrderViewController: BNSUserBaseUIViewController,UITableViewDelegate,UITableViewDataSource {

    //传入的订单信息
    internal var orderModel:Order?
    //车辆信息结构
    var dispatchsDataSource:[dispatchsObject]?
    //订单详情model
    var orderDetailData:OrderDetail?
    
    @IBOutlet weak var mainTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mainTableView.isHidden = true
        //请求数据
        self.startWait()
        NetInterfaceManager.shareInstance.sendRequstWithType(EMRequestType.emRequestType_GetOrderDetail.rawValue) { (params) in
            params.method = EMRequstMethod.emRequstMethod_GET
            params.data = ["id": self.orderModel!.id ?? ""]  as AnyObject
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func detailOrderStatusCellSet(_ tempDetailOrderStatusCell:BNSDetailOrderStatusTableViewCell?) -> BNSDetailOrderStatusTableViewCell {
        let detailOrderStatusCell = tempDetailOrderStatusCell
        //订单类型
        let tempOrderType = orderDetailData?.order_type ?? ""
        switch tempOrderType {
        case "AirportSend":
            detailOrderStatusCell!.order_typeName.text = "送机"
            detailOrderStatusCell!.flight_numberName.text = "航班号："
            detailOrderStatusCell?.stateAddress.text = orderDetailData?.destination
        case "AirportPickup":
            detailOrderStatusCell!.order_typeName.text = "接机"
            detailOrderStatusCell!.flight_numberName.text = "航班号："
            detailOrderStatusCell?.stateAddress.text = orderDetailData?.starting
        case "BusStationSend":
            detailOrderStatusCell!.order_typeName.text = "送汽车站"
            detailOrderStatusCell!.flight_numberName.text = "火车班次："
            detailOrderStatusCell?.stateAddress.text = orderDetailData?.destination
        case "BusStationPickup":
            detailOrderStatusCell!.order_typeName.text = "接汽车站"
            detailOrderStatusCell!.flight_numberName.text = "火车班次："
            detailOrderStatusCell?.stateAddress.text = orderDetailData?.starting
        case "TrainStationSend":
            detailOrderStatusCell!.order_typeName.text = "送火车站"
            detailOrderStatusCell!.flight_numberName.text = "火车班次："
            detailOrderStatusCell?.stateAddress.text = orderDetailData?.destination
        case "TrainStationPickup":
            detailOrderStatusCell!.order_typeName.text = "接火车站"
            detailOrderStatusCell!.flight_numberName.text = "火车班次："
            detailOrderStatusCell?.stateAddress.text = orderDetailData?.starting
        case "TransferSend":
            detailOrderStatusCell!.order_typeName.text = "中转车送"
            detailOrderStatusCell!.flight_numberName.text = "未知"
            detailOrderStatusCell?.stateAddress.text = orderDetailData?.destination
        case "TransferPickup":
            detailOrderStatusCell!.order_typeName.text = "中转车接"
            detailOrderStatusCell!.flight_numberName.text = "未知"
            detailOrderStatusCell?.stateAddress.text = orderDetailData?.starting
        default:
            detailOrderStatusCell!.order_typeName.text = "未知"
            detailOrderStatusCell!.flight_numberName.text = "未知"
            detailOrderStatusCell?.stateAddress.text = "未知"
        }
        //订单时间
        if let tempUseTime = DateUtils.string(toDate: orderDetailData?.use_time) {
            detailOrderStatusCell!.use_time.text = "\(DateUtils.formatDate(tempUseTime, format: "yyyy-MM-dd") ?? "")  \(DateUtils.week(from: tempUseTime) ?? "")"
        }
        
        //航班号
        detailOrderStatusCell!.flight_number.text = orderDetailData?.flight_number
        //出发时间
        detailOrderStatusCell?.flight_time.text = orderDetailData?.flight_time
        //订单状态
        let tempOrderState = orderDetailData?.order_state ?? ""
        switch tempOrderState {
        case "PendingDispatch":
            detailOrderStatusCell?.order_state.text = "等待派车"
        case "QueuingDispatch":
            detailOrderStatusCell?.order_state.text = "预约排队"
        case "Dispatched":
            detailOrderStatusCell?.order_state.text = "预约成功"
        case "Transporting":
            detailOrderStatusCell?.order_state.text = "接送中"
        case "PendingSettlement":
            detailOrderStatusCell?.order_state.text = "等待结算"
        case "Completed":
            detailOrderStatusCell?.order_state.text = "已完成"
        case "Waiting":
            detailOrderStatusCell?.order_state.text = "等待上车"
        case "DispatchFail":
            detailOrderStatusCell?.order_state.text = "预约失败"
        case "Cancelled":
            detailOrderStatusCell?.order_state.text = "已取消"
        default:
            detailOrderStatusCell?.order_state.text = "未知"
        }
        
        
        return detailOrderStatusCell!
    }
    func detailOrderPassengerCellSet(_ tempDetailOrderPassengerCell:BNSDetailOrderPassengerTableViewCell?) -> BNSDetailOrderPassengerTableViewCell {
        
        let detailOrderPassengerCell = tempDetailOrderPassengerCell
        detailOrderPassengerCell?.people_number.text = "\(orderDetailData?.people_number ?? 0)人"
        //取一个联系人
        if let firstContacts = orderDetailData?.contacts {
            if firstContacts.count > 0 {
                detailOrderPassengerCell?.name.text = firstContacts[0].name
                detailOrderPassengerCell?.phone.text = firstContacts[0].phone
                detailOrderPassengerCell?._description.text = firstContacts[0]._description
                
            }
        }
        //订单类型
        let tempOrderType = orderDetailData?.order_type ?? ""
        switch tempOrderType {
        case "AirportSend":
            detailOrderPassengerCell?.address.text = orderDetailData?.starting
        case "AirportPickup":
            detailOrderPassengerCell?.address.text = orderDetailData?.destination
        case "BusStationSend":
            detailOrderPassengerCell?.address.text = orderDetailData?.starting
        case "BusStationPickup":
            detailOrderPassengerCell?.address.text = orderDetailData?.destination
        case "TrainStationSend":
            detailOrderPassengerCell?.address.text = orderDetailData?.starting
        case "TrainStationPickup":
            detailOrderPassengerCell?.address.text = orderDetailData?.destination
        case "TransferSend":
            detailOrderPassengerCell?.address.text = orderDetailData?.starting
        case "TransferPickup":
            detailOrderPassengerCell?.address.text = orderDetailData?.destination
        default:
            detailOrderPassengerCell?.address.text = "未知"
        }
        return detailOrderPassengerCell!;
    }
    func detailOrderCarInfoCellSet(_ tempDetailOrderCarInfoCell:BNSDetailOrderCarInfoTableViewCell?, indexPath: IndexPath) -> BNSDetailOrderCarInfoTableViewCell {
        
        let detailOrderCarInfoCell = tempDetailOrderCarInfoCell
        let index = (indexPath as NSIndexPath).row - 1
        let dispatchsInfor = dispatchsDataSource![index]
        detailOrderCarInfoCell?.license.text = dispatchsInfor.license
        detailOrderCarInfoCell?.name.text = dispatchsInfor.name
        detailOrderCarInfoCell?.phone.text = dispatchsInfor.phone
        return detailOrderCarInfoCell!;
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).row {
        case 0:
            return 145
        case (dispatchsDataSource == nil ? 0 : dispatchsDataSource!.count) + 1:
            return 168
        default:
            return 125
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dispatchsDataSource == nil ? 0 : dispatchsDataSource!.count) + 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        switch (indexPath as NSIndexPath).row {
        case 0:
            //获取cell
            let detailOrderStatusCellID = "detailOrderStatusCellID"
            var detailOrderStatusCell:BNSDetailOrderStatusTableViewCell? = tableView.dequeueReusableCell(withIdentifier: detailOrderStatusCellID) as? BNSDetailOrderStatusTableViewCell
            if detailOrderStatusCell == nil {
                detailOrderStatusCell = Bundle.main.loadNibNamed("BNSDetailOrderStatusTableViewCell", owner: self, options: nil)?.first as? BNSDetailOrderStatusTableViewCell
            }
            //对cell数据赋值
            cell = self.detailOrderStatusCellSet(detailOrderStatusCell!)
        case (dispatchsDataSource == nil ? 0 : dispatchsDataSource!.count) + 1:
            let detailOrderPassengerCellID = "detailOrderPassengerCellID"
            var detailOrderPassengerCell:BNSDetailOrderPassengerTableViewCell? = tableView.dequeueReusableCell(withIdentifier: detailOrderPassengerCellID) as? BNSDetailOrderPassengerTableViewCell
            if detailOrderPassengerCell == nil {
                detailOrderPassengerCell = Bundle.main.loadNibNamed("BNSDetailOrderPassengerTableViewCell", owner: self, options: nil)?.first as? BNSDetailOrderPassengerTableViewCell
            }
            
            cell = self.detailOrderPassengerCellSet(detailOrderPassengerCell!)
        default:
            let detailOrderCarInfoCellID = "detailOrderCarInfoCellID"
            var detailOrderCarInfoCell:BNSDetailOrderCarInfoTableViewCell? = tableView.dequeueReusableCell(withIdentifier: detailOrderCarInfoCellID) as? BNSDetailOrderCarInfoTableViewCell
            if detailOrderCarInfoCell == nil {
                detailOrderCarInfoCell = Bundle.main.loadNibNamed("BNSDetailOrderCarInfoTableViewCell", owner: self, options: nil)?.first as? BNSDetailOrderCarInfoTableViewCell
            }
            cell = self.detailOrderCarInfoCellSet(detailOrderCarInfoCell, indexPath: indexPath)
        }
        return cell!;
    }
    
    // MARK: - actions
   
    @IBAction func btnPayClick(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "toPayment", sender: nil)
    }
    
    @IBAction func btnCancelClick(_ sender: AnyObject) {
    }
    
    //MARK: - http handler
    override func httpRequestFinished(_ notification:Notification){
        super.httpRequestFinished(notification)
        let resultData:NetResultDataModel = notification.object as! NetResultDataModel
        switch resultData.type {
        case EMRequestType.emRequestType_GetOrderDetail.rawValue:
            self.stopWait()
            if let returnData:NSDictionary = resultData.data as? NSDictionary {
                mainTableView.isHidden = false
                self.orderDetailData = OrderDetail.mj_object(withKeyValues: returnData)
                self.dispatchsDataSource = orderDetailData?.dispatchs
                mainTableView.reloadData()
            }
            
            break
        default:
            "default"
        }
    }
    override func httpRequestFailed(_ notification:Notification){
        super.httpRequestFailed(notification)
    }
    
}
