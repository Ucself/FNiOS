//
//  ShuttleBusOrderListViewController.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/11/22.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNUIView

@objc protocol ShuttleOrderListDelegate {
    @objc optional func setNeedRefresh()
}

class ShuttleBusOrderListViewController: UserBaseUIViewController,UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate, ShuttleOrderListDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgView: UIView!
    var preCell:ShuttleBusOrderListTableViewCell?
    var deleteIndex:IndexPath?  //正在删除行
    
    var page:Int = 1     //页面
    let row:Int = 10     //分页大小
    //数据源
    var dataSource:NSMutableArray?
    
    var isNeedRefresh = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initInterface()
        
        isNeedRefresh = true
        
        //注册通知
        //注册推送通知
        NotificationCenter.default.addObserver(self, selector: #selector(orderStatusNotification(notification:)), name: NSNotification.Name(rawValue: FNPushType_ShttleWaiting), object: nil)   //等待上车
        NotificationCenter.default.addObserver(self, selector: #selector(orderStatusNotification(notification:)), name: NSNotification.Name(rawValue: FNPushType_ShttleOngoing), object: nil)   //行程开始
        NotificationCenter.default.addObserver(self, selector: #selector(orderStatusNotification(notification:)), name: NSNotification.Name(rawValue: FNPushType_ShttleArrived), object: nil)   //行程结束
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
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_OrderList.rawValue), params: {(param:NetParams?) -> Void in
            param?.method = EMRequstMethod.GET
            param?.data = ["page" : self.page ,"take": self.row]
        })
    }
    //刷新列表
    func refreshOrderList() {

        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_OrderList.rawValue), params: {(param:NetParams?) -> Void in
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
        let tempOrderObj:ShuttleOrderObj = dataSource![indexPath.row] as! ShuttleOrderObj
        //获取订单状态
        guard let orderState:ShuttleOrderState = ShuttleOrderState(rawValue: tempOrderObj.order_state) else {
            self.showTipsView("服务订单状态错误")
            return
        }
        switch orderState {
        case .PendingDispatch,.QueuingDispatch,.Dispatched,.Transporting,.Waiting,.DriverHasStarted,.DriverHasArrived,.PassengerAreNotOnBoard,.Dispatching,.LosslessCancellationOfApplication:
            
            //等待派车，预约排队，预约成功，接送中，等待上车  页面跳转到地图页面
            let order:ShuttleBusOrderStatusViewController = ShuttleBusOrderStatusViewController.instance(withStoryboardName: "ShuttleBusOrder")
            order.orderId = tempOrderObj.id;
            order.refreshDelegate = self
            self.navigationController?.pushViewController(order, animated: true)
            
        case .Completed,.Evaluated:
            
            //跳转到评价页面
            let evaluationViewController:ShuttleBusOrderEvaluationViewController = ShuttleBusOrderEvaluationViewController.instance(withStoryboardName: "ShuttleBusOrder")
            evaluationViewController.orderId = tempOrderObj.id
            evaluationViewController.refreshDelegate = self
            self.navigationController?.pushViewController(evaluationViewController, animated: true)
            //回调 暂时不需要
//            evaluationViewController.evaluationBlockCallback = { (orderId:String) ->Void in
//                tempOrderObj.order_state_key = ShuttleOrderState.Evaluated.rawValue
//                self.tableView.reloadData()
//            }
            
        case .PendingPay,.DispatchFail,.Cancelled,.Unkown:
            
            //等待支付，预约失败，已经取消 给提示
            self.showTip("订单" + orderState.toString(), with: FNTipTypeFailure)
            
        case .Refunding,.Refunded,.RefundApplying,.LosslessCancellation:
            
            //退款中，退款完成，退款申请中
            if !tempOrderObj.is_submit && orderState != .LosslessCancellation{
                //未填写取消原因跳转取消原因
                let cancelReasonViewController:ShuttleBusOrderCancelReasonViewController = ShuttleBusOrderCancelReasonViewController.instance(withStoryboardName: "ShuttleBusOrder")
                cancelReasonViewController.orderId = tempOrderObj.id
                cancelReasonViewController.viewControllerType = .Reason
                cancelReasonViewController.refreshDelegate = self
                
                //回调，改变数据源状态为已经提交了取消原因  暂时不需要
//                cancelReasonViewController.cancelBlockCallback = {(orderId:String) -> Void in
//                    tempOrderObj.is_submit_cancel_reason = true
//                    self.tableView.reloadData()
//                }
                
                self.navigationController?.pushViewController(cancelReasonViewController, animated: true)
            }
            else{
                //填写了取消原因跳转退款详情
                let refundDetailViewController:ShuttleBusOrderRefundDetailViewController = ShuttleBusOrderRefundDetailViewController.instance(withStoryboardName: "ShuttleBusOrder")
                refundDetailViewController.orderId = tempOrderObj.id
                self.navigationController?.pushViewController(refundDetailViewController, animated: true)
            }
            break
        default:
            break
        }
        
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.dataSource != nil ? (self.dataSource?.count)! : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        var cell:ShuttleBusOrderListTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "ShuttleBusOrderListTableViewCell") as? ShuttleBusOrderListTableViewCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("ShuttleBusOrderListTableViewCell", owner: nil, options: nil)?.first as? ShuttleBusOrderListTableViewCell
        }
        let tempOrderListObj:ShuttleOrderObj = dataSource![indexPath.row] as! ShuttleOrderObj
        cell?.setInterface(shuttleOrderList: tempOrderListObj)
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
        let tempOrderListObj:ShuttleOrderObj = dataSource![(deleteIndex?.row)!] as! ShuttleOrderObj
        //删除订单
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_Order_Delete.rawValue), params: {(param:NetParams?)->Void in
            param?.method = EMRequstMethod.DELETE
            param?.data = ["id":tempOrderListObj.id]
        })
        
    }
    func swippableTableViewCell(_ cell: SWTableViewCell!, scrollingTo state: SWCellState){
        if state == kCellStateRight && preCell != nil {
            self.preCell?.hideUtilityButtons(animated: true)
        }
        self.preCell = cell as? ShuttleBusOrderListTableViewCell
    }
    //MARK: http handle
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        guard let result:ResultDataModel = notification.object as? ResultDataModel else { self.stopWait(); return}
        if result.type == Int32(EmRequestType_OrderList.rawValue) {
            self.stopWait()
            let tempArray:NSMutableArray = ShuttleOrderObj.mj_objectArray(withKeyValuesArray: result.data)
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
        else if result.type == Int32(EmRequestType_Order_Delete.rawValue){
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
