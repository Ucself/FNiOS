//
//  BNSOrderCenterViewController.swift
//  FeiNiu_Business
//
//  Created by lbj@feiniubus.com on 16/9/6.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNCommon
import FNSwiftNetInterface
import FNUIView

class BNSOrderCenterViewController: BNSUserBaseUIViewController,UITableViewDelegate,UITableViewDataSource,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance {
    
    @IBOutlet weak var ticketDate: UILabel!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var orderIntroduce: UILabel!
    
    
    var pageNum = 1
    var onePageCount = 10
    var selectDate:Date?{
        didSet{
            self.ticketDate.text = "\(DateUtils.formatDate(selectDate, format: "yyyy-MM-dd") ?? "") \(DateUtils.week(from: selectDate) ?? "")"
            self.requestOrderList()
        }
    }
    //数据源
    var tableDataSource:NSMutableArray?{
        didSet{
            
        }
    }
    //总价格
    var total_price = 0
    //联系人数量
    var total_contacts = 0
    //后台联系人数
    var total_rows = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initialization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let toViewControl = segue.destination
        switch toViewControl.self {
        case is BNSDetailOrderViewController:
            if let detailOrderViewController:BNSDetailOrderViewController = toViewControl as? BNSDetailOrderViewController {
                detailOrderViewController.orderModel = sender as? Order
            }
            break
        default:
            break
        }
        
    }
    

    //MARK: -------
    func initialization() -> Void {
        selectDate = Date.init()
        //日期显示
        self.ticketDate.layer.borderColor = UIColor.red.cgColor
        self.ticketDate.layer.borderWidth = 1.0
        self.ticketDate.isUserInteractionEnabled = true
        let ticketDateClickTapGesture:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(ticketDateClick))
        ticketDate.addGestureRecognizer(ticketDateClickTapGesture)
        //设置刷新功能
        self.mainTableView.header = MJRefreshNormalHeader.init(refreshingBlock: { 
            self.pageNum = 1
            self.requestOrderList()
        })
        self.mainTableView.header.isAutomaticallyChangeAlpha = true
        self.mainTableView.footer = MJRefreshBackNormalFooter.init(refreshingBlock: { 
            self.pageNum += 1
            self.requestOrderList()
        })
        
    }
    
    func requestOrderList() -> Void {
//        self.startWait()
        //请求数据
        NetInterfaceManager.shareInstance.sendRequstWithType(EMRequestType.emRequestType_GetOrderCenterList.rawValue) { (params) in
            params.method = .emRequstMethod_GET
            params.data = ["page":self.pageNum,
                           "take":self.onePageCount,
                           "use_time":DateUtils.formatDate(self.selectDate, format: "yyyy-MM-dd")]  as AnyObject
        }
    }
    //跳入登录
    func toLoginViewController() -> Void {
        let rootViewController:UIViewController = self
        let storyboard = UIStoryboard.init(name: "Manager", bundle: nil)
        let logVC = storyboard.instantiateViewController(withIdentifier: "BNSLoginViewController") as! BNSLoginViewController
        logVC.finishedBlock = {
            logVC.dismiss(animated: true, completion: {
            })
        }
        let navVC:UINavigationController = UINavigationController.init(rootViewController: logVC)
        rootViewController.present(navVC, animated: true) {
            
        }
    }
    //MARK: UserAction
    override func navigateionViewBack() {
        AuthorizeCache.sharedInstance().clean()
        self.toLoginViewController()
    }
    override func navigateionViewRight() {
        super.navigateionViewRight()
        self.performSegue(withIdentifier: "toSeachOrder", sender: nil)
    }
    
    func ticketDateClick() -> Void {
        if self.mainCalendar == nil {
            //初始化日历控件
            self.initFSCalendar()
        }
        self.displayFSCalendar(KWINDOW!)
    }
    @IBAction func beforeDayClick(_ sender: AnyObject) {
       self.selectDate = self.selectDate?.addingTimeInterval(-(3600*24))
    }
    @IBAction func afterDayClick(_ sender: AnyObject) {
    self.selectDate = self.selectDate?.addingTimeInterval(3600*24)
    }
    
    //MARK: - FSCalendar
    //日历控件
    var mainCalendar:FSCalendar?
    //日历初始化
    func initFSCalendar() -> Void {
        self.mainCalendar = FSCalendar.init()
        self.mainCalendar?.backgroundColor = UIColor.white
        self.mainCalendar?.delegate = self
        self.mainCalendar?.dataSource = self
        self.mainCalendar?.scrollDirection = FSCalendarScrollDirection.vertical
        self.mainCalendar?.headerHeight = 44.0
        self.mainCalendar?.weekdayHeight = 20.0
        self.mainCalendar?.appearance.headerTitleColor = UIColorFromRGB(0xFF7043)
        self.mainCalendar?.appearance.headerDateFormat = "yyyy年M月"
        self.mainCalendar?.appearance.weekdayTextColor = UIColorFromRGB(0x333333)
        self.mainCalendar?.appearance.selectionColor = UIColorFromRGB(0xFF7043)
        
    }
    //用于显示隐藏日历的superView
    var superView:UIView?
    //显示日历
    func displayFSCalendar(_ parentView:UIView) -> Void {
        self.superView = parentView
        //遮罩层
        let coverView:UIView = UIView.init()
        coverView.backgroundColor = UIColor.init(white: 0, alpha: 0.4)
        coverView.tag = 100001
        guard parentView.viewWithTag(100001) == nil else{
            return
        }
        //布局遮罩层
        parentView.addSubview(coverView)
        coverView.snp_makeConstraints { (make) in
            make.edges.equalTo(parentView)
        }
        parentView.layoutIfNeeded()
        //布局日历
        coverView.addSubview(self.mainCalendar!)
        self.mainCalendar?.snp_makeConstraints { (make) in
            make.left.equalTo(coverView)
            make.width.equalTo(coverView)
            make.bottom.equalTo(250)
            make.height.equalTo(250)
        }
        self.mainCalendar?.layoutIfNeeded()
        UIView.animate(withDuration: 0.4, animations: { 
            self.mainCalendar?.snp_remakeConstraints({ (make) in
                make.left.equalTo(coverView)
                make.width.equalTo(coverView)
                make.bottom.equalTo(coverView)
                make.height.equalTo(250)
            })
            self.mainCalendar?.layoutIfNeeded()
        }) 
        //添加消失控件手势
//        let deDisplayGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(deDisplayFSCalendar))
//        let gestureView = UIView.init()
//        coverView.addSubview(gestureView)
//        gestureView.snp_makeConstraints { (make) in
//            make.left.equalTo(coverView);
//            make.right.equalTo(coverView);
//            make.top.equalTo(coverView);
//            make.bottom.equalTo(self.mainCalendar!.fs_height)
//        }
//        gestureView.layoutIfNeeded()
//        gestureView.userInteractionEnabled = true
//        gestureView.addGestureRecognizer(deDisplayGestureRecognizer)
        
    }
    //隐藏日历
    func deDisplayFSCalendar() -> Void {
        if superView == nil {
            return
        }
        if superView!.viewWithTag(100001) == nil {
            return
        }
        let coverView:UIView? = superView?.viewWithTag(100001)
        
        UIView.animate(withDuration: 0.4, animations: { 
            self.mainCalendar?.snp_remakeConstraints({ (make) in
                make.left.equalTo(coverView!)
                make.width.equalTo(coverView!)
                make.bottom.equalTo(250)
                make.height.equalTo(250)
            })
                self.mainCalendar?.layoutIfNeeded()
            }, completion: { (finished) in
                coverView?.removeFromSuperview()
                self.superView = nil
        }) 
        
    }
    func calendar(_ calendar: FSCalendar!, subtitleFor date: Date!) -> String! {
        return DateUtils.chineseDay(from: date)
    }
    func calendar(_ calendar: FSCalendar!, didSelect date: Date!) {
        self.selectDate = date
        self.deDisplayFSCalendar()
    }
    func calendar(_ calendar: FSCalendar!, shouldSelect date: Date!) -> Bool {
        return true
    }
    //标题颜色
    func calendar(_ calendar: FSCalendar!, appearance: FSCalendarAppearance!, titleDefaultColorFor date: Date!) -> UIColor! {
        return UIColorFromRGB(0x333333)
    }
    func calendar(_ calendar: FSCalendar!, appearance: FSCalendarAppearance!, subtitleDefaultColorFor date: Date!) -> UIColor! {
        return UIColorFromRGB(0x333333)
    }
    func calendar(_ calendar: FSCalendar!, appearance: FSCalendarAppearance!, selectionColorFor date: Date!) -> UIColor! {
        return UIColorFromRGB(0xFF7043)
    }
    func calendar(_ calendar: FSCalendar!, hasEventFor date: Date!) -> Bool {
        return false
    }
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toDetailOrder", sender:self.tableDataSource![(indexPath as NSIndexPath).row])
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableDataSource?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdent = "OrderCenterTableViewCellID"
        var cell:BNSOrderCenterTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdent) as? BNSOrderCenterTableViewCell
        if cell == nil {
            cell = Bundle.main.loadNibNamed("OrderCenterTableViewCell", owner: self, options: nil)?.first as? BNSOrderCenterTableViewCell
        }
        let orderInfor:Order = tableDataSource![(indexPath as NSIndexPath).row] as! Order
        //订单人数
        cell?.people_number.text = "人数\(orderInfor.people_number)人"
        //订单姓名
        if orderInfor.contacts!.count > 0 {
            if let contacts:contactsObject = orderInfor.contacts![0]{
                cell?.name.text = contacts.name
            }
        }
        //订单状态
        let switchOrderState = orderInfor.order_state ?? "0"
        switch switchOrderState {
        case "PendingDispatch":
            cell?.order_state.text = "等待派车"
            break
        case "QueuingDispatch":
            cell?.order_state.text = "预约排队"
            break
        case "Dispatched":
            cell?.order_state.text = "预约成功"
            break
        case "Transporting":
            cell?.order_state.text = "接送中"
            break
        case "PendingSettlement":
            cell?.order_state.text = "等待结算"
            break
        case "Completed":
            cell?.order_state.text = "已完成"
            break
        case "Waiting":
            cell?.order_state.text = "等待上车"
            break
        case "DispatchFail":
            cell?.order_state.text = "预约失败"
            break
        case "Cancelled":
            cell?.order_state.text = "已取消"
            break
        default:
            cell?.order_state.text = "未知状态"
        }
        //航班号
        cell?.flight_number.text = "航班号：\(orderInfor.flight_number ?? "")"
        //城市名称
        cell?.city_name.text = orderInfor.city_name
        //接送时间
        cell?.use_time.text = "接送时间：\(orderInfor.use_time ?? "")"
        
        return cell!
    }
    
    override func loginSuccessNotification() {
        super.loginSuccessNotification()
    }
    
    //MARK: - http handler
    override func httpRequestFinished(_ notification:Notification){
        super.httpRequestFinished(notification)
        let resultData:NetResultDataModel = notification.object as! NetResultDataModel
        switch resultData.type {
        case EMRequestType.emRequestType_GetOrderCenterList.rawValue:
            let returnData:NSDictionary = resultData.data as! NSDictionary
            //联系人个数
            total_contacts = returnData["total_contacts"] as? Int ?? 0
            //总价
            total_price = returnData["total_price"] as? Int ?? 0
            //订单数
            total_rows = returnData["total_rows"] as? Int ?? 0
            if let dataArray = returnData["data"] {
                let orderArray = Order.mj_objectArray(withKeyValuesArray: dataArray)
                if self.pageNum == 1 {
                    //如果是第一页，重置数据
                    tableDataSource = orderArray
                }
                else{
                    tableDataSource?.add(orderArray)
                }
            }
            self.mainTableView.reloadData()
            self.orderIntroduce.text = "你一共有\(total_rows)个订单，\(total_contacts)个联系人，总价共计：\(total_price/100)元"
            self.mainTableView.header.endRefreshing()
            self.mainTableView.footer.endRefreshing()
            break
        default:
            "default"
        }
    }
    override func httpRequestFailed(_ notification:Notification){
        super.httpRequestFailed(notification)
        self.mainTableView.header.endRefreshing()
        self.mainTableView.footer.endRefreshing()
    }
}
