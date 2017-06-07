//
//  ShuttleBusOrderListViewController.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/11/22.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNUIView

@objc protocol ScheduleOrderListDelegate {
    @objc optional func setNeedRefresh()
}

class ScheduleOrderListViewController: UserBaseUIViewController,UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate,ScheduleOrderListDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgView: UIView!
    var preCell:ScheduleOrderListTableViewCell?
    var deleteIndex:IndexPath?  //正在删除行
    
    var page:Int = 1     //页面
    let row:Int = 10     //分页大小
    //数据源
    var dataSource:NSMutableArray?
    
    var isNeedRefresh = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initInterface()
        
        self.isNeedRefresh = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(setNeedRefresh), name: NSNotification.Name(rawValue: KOrderRefreshNotification), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //刷新列表
        if isNeedRefresh {
            self.tableView.header.beginRefreshing()
            isNeedRefresh = false
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: KOrderRefreshNotification), object: nil)
    }

    //MARK: -
    func setNeedRefresh() {
        self.isNeedRefresh = true
    }
    
    func initInterface() {
        self.tableView.header = MJRefreshNormalHeader.init(refreshingBlock: {
            self.page = 1
            self.requestOrderList(tipWait: false)
        })
        self.tableView.header.isAutomaticallyChangeAlpha = true
        self.tableView.footer = MJRefreshBackNormalFooter.init(refreshingBlock: { 
            self.page += 1
            self.requestOrderList(tipWait: false)
        })
        //第一次数据请求
        //self.requestOrderList(tipWait: true)
    }
    
    func requestOrderList(tipWait:Bool) {
        //请求数据
        if tipWait {
            self.startWait()
        }
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteOrderList.rawValue), params: {(param:NetParams?) -> Void in
            param?.method = EMRequstMethod.GET
            param?.data = ["page" : self.page ,"take": self.row]
        })
    }
    //刷新列表
    func refreshOrderList() {

        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteOrderList.rawValue), params: {(param:NetParams?) -> Void in
            param?.method = EMRequstMethod.GET
            param?.data = ["page" : 1 ,"take": self.row * self.page]
        })
    }
    //后台服务通知
    func orderStatusNotification (notification:Notification){
        //收到通知刷新列表
        self.refreshOrderList()
    }
    
    //MARK: UITableViewDelegate
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 143
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if preCell != nil {
            preCell?.hideUtilityButtons(animated: true)
        }
        let tempOrderObj:CommuteOrderObj = dataSource![indexPath.row] as! CommuteOrderObj
        
        switch CommuteOrderState(rawValue: tempOrderObj.order_state)! {
        case .Dispatched,.Waiting,.Transporting:
            //行程正在进行中
            let controller:ScheduleOrderDetailViewController = ScheduleOrderDetailViewController.instance(withStoryboardName: "ScheduledOrder")
            controller.orderObj = tempOrderObj
            self.navigationController?.pushViewController(controller, animated: true)
        case .Refunding,.Refunded,.RefundApplying:
            //退款的 跳转到填写退票原因还是已取消页面
            if tempOrderObj.is_submit_cancel_reason {
                //退款详情页面
                let refund:ScheduleRefundViewController = ScheduleRefundViewController.instance(withStoryboardName: "ScheduledOrder")
                refund.id = tempOrderObj.id
                self.navigationController?.pushViewController(refund, animated: true)
            }
            else {
                //跳转到退票原因
                let controller:ScheduleCancelReasonViewController = ScheduleCancelReasonViewController.instance(withStoryboardName: "ScheduledOrder")
                controller.orderId = tempOrderObj.id
                controller.viewControllerType = .Reason
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
        case .Completed,.Evaluated:
            
//            //跳转到评价或则已评价页面 测试代码
//            let controller:ScheduleEvaluationViewController = ScheduleEvaluationViewController.instance(withStoryboardName: "ScheduledOrder")
//            controller.id = tempOrderObj.id
//            controller.orderObj = tempOrderObj
//            self.navigationController?.pushViewController(controller, animated: true)
//            controller.isComment = (tempOrderObj.order_state == CommuteOrderState.Evaluated.rawValue)
//            
//            break
            
            //没有验票跳转到线路详情页面
            if tempOrderObj.ticket_state != CommuteTicketState.Checked.rawValue &&
                tempOrderObj.order_state != CommuteOrderState.Evaluated.rawValue
            {
                let controller:ScheduleLineDetailViewController = ScheduleLineDetailViewController.instance(withStoryboardName: "ScheduledBus")
                let commuteObj:CommuteObj = CommuteObj.init()
                commuteObj.id = tempOrderObj.line_id
                controller.commuteObj = commuteObj
                self.navigationController?.pushViewController(controller, animated: true)
            }
            else {
                //跳转到评价或则已评价页面
                let controller:ScheduleEvaluationViewController = ScheduleEvaluationViewController.instance(withStoryboardName: "ScheduledOrder")
                controller.id = tempOrderObj.id
                controller.orderObj = tempOrderObj
                controller.isComment = (tempOrderObj.order_state == CommuteOrderState.Evaluated.rawValue)
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
            break
        default:
            self.showTip(CommuteOrderState.toStringNew(enumName: tempOrderObj.order_state), with: FNTipTypeFailure)
        }
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.dataSource != nil ? (self.dataSource?.count)! : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        var cell:ScheduleOrderListTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "ScheduleOrderListTableViewCell") as? ScheduleOrderListTableViewCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("ScheduleOrderListTableViewCell", owner: nil, options: nil)?.first as? ScheduleOrderListTableViewCell
        }
        let tempOrderListObj:CommuteOrderObj = dataSource![indexPath.row] as! CommuteOrderObj
        cell?.setInterface(order: tempOrderListObj)
        //添加删除按钮
        cell?.delegate = self
        cell?.height = 143
        cell?.containingTableView = tableView;
        cell?.offsetMargin = 10; //边距
        let btn:UIButton = UIButton.init(type: UIButtonType.custom)
        btn.backgroundColor = UIColor_DefOrange
        btn.setImage(UIImage.init(named: "ico_recycle"), for: UIControlState.normal)
        let btns:[Any] = [btn]
        cell?.setButtonsLeft(nil, right: btns)
        return cell!
    }
    //MARK: SWTableViewCellDelegate
    func swippableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int){
        deleteIndex = self.tableView.indexPath(for: cell)
        let tempOrderListObj:CommuteOrderObj = dataSource![(deleteIndex?.row)!] as! CommuteOrderObj
        //删除订单
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteOrderTicketDelete.rawValue), params: {(param:NetParams?)->Void in
            param?.method = EMRequstMethod.DELETE
            param?.data = ["id":tempOrderListObj.id ?? ""]
        })
        
    }
    func swippableTableViewCell(_ cell: SWTableViewCell!, scrollingTo state: SWCellState){
        if state == kCellStateRight && preCell != nil {
            self.preCell?.hideUtilityButtons(animated: true)
        }
        self.preCell = cell as? ScheduleOrderListTableViewCell
    }
    //MARK: http handle
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        guard let result:ResultDataModel = notification.object as? ResultDataModel else { self.stopWait(); return}
        if result.type == Int32(EmRequestType_CommuteOrderList.rawValue) {
            self.stopWait()
            
            guard  result.data != nil else {
                return
            }
            
            let tempArray:NSMutableArray = CommuteOrderObj.mj_objectArray(withKeyValuesArray: result.data)
            //如果是第一页直接赋值，后面页面累加
            if self.page == 1 {
                if tempArray.count == 0 {
                    self.bgView.isHidden = false
                }
                else{
                    self.bgView.isHidden = true
                }
                
                //更新数据源
                self.dataSource = tempArray
            }
            else{
                self.dataSource?.addObjects(from: tempArray as! [Any])
            }
            self.tableView.reloadData()
            self.tableView.header.endRefreshing()
            self.tableView.footer.endRefreshing()
        }
        else if result.type == Int32(EmRequestType_CommuteOrderTicketDelete.rawValue){
            self.stopWait()
            //删除成功后删除 数据源和列表
            if deleteIndex != nil {
                self.dataSource?.removeObject(at: (deleteIndex?.row)!)
                self.preCell = nil
                self.tableView.deleteRows(at: [deleteIndex!], with: UITableViewRowAnimation.left)
            }
        }
        
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
        self.tableView.header.endRefreshing()
        self.tableView.footer.endRefreshing()
        //出现错误隐藏删除按钮
        if  preCell != nil {
            self.preCell?.hideUtilityButtons(animated: true)
        }
    }

}
