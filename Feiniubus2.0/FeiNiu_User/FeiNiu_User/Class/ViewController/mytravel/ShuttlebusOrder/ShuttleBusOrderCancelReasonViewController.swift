//
//  ShuttleBusOrderCancelReasonViewController.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/11/25.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

enum ReasonViewControllerType {
    case Reason
    case Complaint
}
protocol systemType{
    mutating func toString() -> String
    mutating func toInt() -> Int
    static func toEnum(name:String) -> Self
}
//系统取消原因
enum systemCancellType:Int,systemType {
    case PersonalReason         = 1
    case AppointmentTimeError   = 2
    case DriverNotOnTime        = 3
    case RouteAround            = 4
    
    func toString() -> String{
        switch self {
        case .PersonalReason:
            return "个人原因无法乘车"
        case .AppointmentTimeError:
            return "上车时间预约不对"
        case .DriverNotOnTime:
            return "司机无法按时到达"
        case .RouteAround:
            return "拼车线路太绕"
        }
    }
    func toInt() -> Int{
        return self.rawValue
    }
    //暂时没用
    static func toEnum(name:String) -> systemCancellType{ return .PersonalReason}
}
//系统评价原因
enum systemEvaluationType:Int,systemType {
    case CarGood            = 1
    case ExperienceGood     = 2
    case PriceAffordable    = 3
    case ServiceGood        = 4
    case DriverOnTime       = 5
    
    func toString() -> String{
        switch self {
        case .CarGood:
            return "车子好"
        case .ExperienceGood:
            return "很好的体验"
        case .PriceAffordable:
            return "价格实惠"
        case .ServiceGood:
            return "服务很好"
        case .DriverOnTime:
            return "司机很好，很准时"
        }
    }
    
    func toInt() -> Int{
        return self.rawValue
    }
    
    static func toEnum(name:String) -> systemEvaluationType{
        switch name {
        case "车子好":
            return .CarGood
        case "很好的体验":
            return .ExperienceGood
        case "价格实惠":
            return .PriceAffordable
        case "服务很好":
            return .ServiceGood
        case "司机很好，很准时":
            return .DriverOnTime
        default:
            return .CarGood
        }
    }
}
//系统投诉选项
enum systemComplaintsType:Int,systemType {
    case DriverAttitudeBad = 1
    case DriverLate = 2
    case DriverDangerDrive = 3
    case DrivingExperienceBad = 4
    
    func toString() -> String{
        switch self {
        case .DriverAttitudeBad:
            return "司机态度恶劣"
        case .DriverLate:
            return "司机迟到"
        case .DriverDangerDrive:
            return "司机危险驾驶"
        case .DrivingExperienceBad:
            return "乘车体验不好"
        }
    }
    func toInt() -> Int{
        return self.rawValue
    }
    //暂时没用
    static func toEnum(name:String) -> systemComplaintsType{ return .DriverAttitudeBad}
}

class ShuttleBusOrderCancelReasonViewController: UserBaseUIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UINavigationViewDelegate {
    
    var refreshDelegate:ShuttleOrderListDelegate?

    var orderId:String?    //订单id
    var dataSource:[systemType] = [systemCancellType.PersonalReason,
                                   systemCancellType.AppointmentTimeError,
                                   systemCancellType.DriverNotOnTime,
                                   systemCancellType.RouteAround]
    var defaultSelectIndex = 0   //默认选中
    var moveHeight:CGFloat = 0   //键盘出现View移动的高度
    //控制器类型 取消原因还是投诉
    var viewControllerType:ReasonViewControllerType = .Reason
    //界面控件
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var navView: UINavigationView!
    var contentTextView:UITextView?
    var tipLable:UILabel?
    @IBOutlet weak var submitButton: UIButton!
    
    //定义一个回调闭包
    typealias callbackFunc = (_ orderId:String ) -> Void
    var cancelBlockCallback:callbackFunc?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.submitButton.layer.borderWidth = 1
        self.submitButton.layer.borderColor = UIColorFromRGB(0xFE6E35).cgColor
        //键盘通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        //设置数据源
        switch viewControllerType {
        case .Reason:
            dataSource = [systemCancellType.PersonalReason,
                          systemCancellType.AppointmentTimeError,
                          systemCancellType.DriverNotOnTime,
                          systemCancellType.RouteAround]
            navView.rightTitle = "投诉"
            navView.title = "已取消"
        case .Complaint:
            dataSource = [systemComplaintsType.DriverAttitudeBad,
                          systemComplaintsType.DriverLate,
                          systemComplaintsType.DriverDangerDrive,
                          systemComplaintsType.DrivingExperienceBad]
            navView.rightTitle = ""
            navView.title = "投诉"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func hideKeyboard() {
        self.contentTextView?.resignFirstResponder()
    }
    
    func keyboardWillShow(notification:Notification){
        
        let userinfo: NSDictionary = notification.userInfo! as NSDictionary
        let nsValue = userinfo.object(forKey: UIKeyboardFrameEndUserInfoKey)
        let keyboardRec:CGRect = (nsValue as AnyObject).cgRectValue
        let toViewFrame = self.contentTextView?.convert((self.contentTextView?.frame)!, to: self.view)
        let toViewY:CGFloat = toViewFrame?.origin.y ?? 0
        let toViewH:CGFloat = toViewFrame?.size.height ?? 0
        self.moveHeight = (toViewY + toViewH) - keyboardRec.origin.y
        
        if self.moveHeight > 0 {
            UIView.animate(withDuration: 0.4, animations: {
                self.mainView.frame = CGRect.init(x: 0,
                                                  y: -self.moveHeight,
                                                  width: self.view.frame.size.width,
                                                  height: self.view.frame.size.height)
            })
        }
    }
    func keyboardWillHide(notification:Notification){
        if self.moveHeight > 0 {
            UIView.animate(withDuration: 0.4, animations: {
                self.mainView.frame = CGRect.init(x: 0,
                                                  y: 0,
                                                  width: self.view.frame.size.width,
                                                  height: self.view.frame.size.height)
            })
        }
    }
    @IBAction func submitClick(_ sender: Any) {
        if self.viewControllerType == .Reason {
            //提交取消原因
            self.startWait()
            NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_OrderReason.rawValue), params: { (params:NetParams?) in
                params?.method = .POST
                params?.data   = ["order_id": self.orderId ?? "",
                                  "reason_key": self.dataSource[self.defaultSelectIndex].toInt(),
                                  "content":self.contentTextView?.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""]
            })
        }
        else{
            //提交投诉
            self.startWait()
            NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_ComplaintAdd.rawValue), params: { (params:NetParams?) in
                params?.method = .POST
                params?.data   = ["order_id": self.orderId ?? "",
                                  "reason_id":self.dataSource[self.defaultSelectIndex].toInt(),
                                  "content":self.contentTextView?.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""]
            })
        }
        
        self.refreshDelegate?.setNeedRefresh!()
        
    }
    //MARK: UINavigationViewDelegate
    override func navigationViewBackClick() {
        super.navigationViewBackClick()
    }
    
    override func navigationViewRightClick() {
        super.navigationViewRightClick()
        //可以跳转到投诉页面
        if self.viewControllerType == .Reason {
            let complaintViewController:ShuttleBusOrderCancelReasonViewController = ShuttleBusOrderCancelReasonViewController.instance(withStoryboardName: "ShuttleBusOrder")
            complaintViewController.orderId = self.orderId
            complaintViewController.viewControllerType = .Complaint
            self.navigationController?.pushViewController(complaintViewController, animated: true)
        }
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < dataSource.count {
            return 50
        }
        else{
            return 91
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.viewControllerType == .Reason {
            return 48
        }
        else{
            return 0.1
        }
        
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard self.viewControllerType == .Reason else {
            return UIView.init()
        }
        
        let parentView = UIView.init()
        parentView.backgroundColor = UIColor.clear
        //线条line
        let lineView = UIView.init()
        parentView.addSubview(lineView)
        lineView.center = CGPoint.init(x: deviceWidth/2, y: 27)
        lineView.bounds = CGRect.init(x: 0, y: 0, width: deviceWidth - 110, height: 1)
        lineView.backgroundColor = UIColorFromRGB(0xE6E6E6)
        //中部文字
        let labelView = UILabel.init()
        parentView.addSubview(labelView)
        labelView.center = CGPoint.init(x: deviceWidth/2, y: 27)
        labelView.bounds = CGRect.init(x: 0, y: 0, width: 77, height: 20)
        labelView.backgroundColor = UIColor.white
        labelView.textColor = UITextColor_Black
        labelView.font = UIFont.systemFont(ofSize: 15)
        labelView.textAlignment = NSTextAlignment.center
        labelView.text = "取消原因"
        labelView.backgroundColor = UIColor_Background
        
        return parentView
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.dataSource.count {
            self.defaultSelectIndex = indexPath.row
            tableView.reloadData()
        }
        
    }
    //scroll 协议
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        self.hideKeyboard()
    }
    //text 协议
    public func textViewDidBeginEditing(_ textView: UITextView){
        self.tipLable?.isHidden = true
    }
    public func textViewDidEndEditing(_ textView: UITextView){
        if self.contentTextView?.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" {
            self.tipLable?.isHidden = true
        }
        else{
            self.tipLable?.isHidden = false
        }
    }
    public func textViewDidChange(_ textView: UITextView){
        
    }
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell?
        if indexPath.row < dataSource.count {
            cell = tableView.dequeueReusableCell(withIdentifier: "SelectCell")
            let selectReasonLabel:UILabel? = cell?.viewWithTag(101) as? UILabel
            let selectReasonImageView:UIImageView? = cell?.viewWithTag(102) as? UIImageView
            selectReasonLabel?.text = dataSource[indexPath.row].toString()
            selectReasonImageView?.image = indexPath.row == defaultSelectIndex ? UIImage.init(named: "icon_round_pressed") : UIImage.init(named: "icon_round")
            //设置边框颜色
            let parentView:UIView? = selectReasonLabel?.superview
            parentView?.layer.borderWidth = 0.5
            parentView?.layer.borderColor = UIColorFromRGB(0xE6E6E6).cgColor
        }
        else{
            cell = tableView.dequeueReusableCell(withIdentifier: "WriteCell")
            self.contentTextView = cell?.viewWithTag(101) as? UITextView
            self.tipLable = cell?.viewWithTag(102) as? UILabel
            self.contentTextView?.delegate = self
        }
        
        return cell!
    }
    
    
    //MARK: - http handler
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        self.stopWait()
        let result:ResultDataModel = notification.object as! ResultDataModel
        if result.type == Int32(EmRequestType_OrderReason.rawValue) {
            //页面跳转
            self.showTip("提交成功", with: FNTipTypeSuccess)
            //回调
            if (self.cancelBlockCallback != nil) {
                self.cancelBlockCallback!(self.orderId!)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC))/Double(NSEC_PER_SEC)) {
                //跳转到退款页面
                let refundDetail:ShuttleBusOrderRefundDetailViewController = ShuttleBusOrderRefundDetailViewController.instance(withStoryboardName: "ShuttleBusOrder")
                refundDetail.orderId = self.orderId;
                let controllers:NSMutableArray =  NSMutableArray.init(array: (self.navigationController?.viewControllers)!)
                controllers.removeLastObject()
                controllers.add(refundDetail)
                
                self.navigationController?.setViewControllers((controllers as NSArray as? [UIViewController])!, animated: true)
            }
        }
        else if result.type == Int32(EmRequestType_ComplaintAdd.rawValue) {
            //投诉成功
            self.showTip("投诉成功", with: FNTipTypeSuccess)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64( 1 * NSEC_PER_SEC))/Double(NSEC_PER_SEC)) {
                _ = self.navigationController?.popViewController(animated:true)
            }
            
            
        }
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
    }
    
}
