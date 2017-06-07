//
//  ScheduleCancelReasonViewController.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/12/8.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

//退票原因
enum systemRefundType:Int,systemType {
    case ScheduleChange = 1
    case OtherTransport = 2
    case OffSiteMuch = 3
    case RouteRound = 4
    case OtherReason = 5
    
    func toString() -> String{
        switch self {
        case .ScheduleChange:
            return "行程有变，不需要用车"
        case .OtherTransport:
            return "换用其他交通工具"
        case .OffSiteMuch:
            return "下车站点太多"
        case .RouteRound:
            return "线路有点绕"
        case .OtherReason:
            return "其他原因"
        }
    }
    func toInt() -> Int{
        return self.rawValue
    }
    //暂时没用
    static func toEnum(name:String) -> systemRefundType{ return .ScheduleChange}
}

class ScheduleCancelReasonViewController: UserBaseUIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UINavigationViewDelegate {
   
    var orderId:String?    //订单id
    var dataSource:[systemType] = [systemRefundType.ScheduleChange,
                                   systemRefundType.OtherTransport,
                                   systemRefundType.OffSiteMuch,
                                   systemRefundType.RouteRound,
                                   systemRefundType.OtherReason]
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
            dataSource = [systemRefundType.ScheduleChange,
                          systemRefundType.OtherTransport,
                          systemRefundType.OffSiteMuch,
                          systemRefundType.RouteRound,
                          systemRefundType.OtherReason]
            navView.rightTitle = "投诉"
            navView.title = "已退票"
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
            //提交退票原因
            self.startWait()
            NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteTicketReason.rawValue), params: { (params:NetParams?) in
                params?.method = .POST
                params?.data   = ["ticket_id": self.orderId ?? "",
                                  "reason_key": self.dataSource[self.defaultSelectIndex].toInt(),
                                  "content":self.contentTextView?.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""]
            })
        }
        else{
            //提交投诉
            self.startWait()
            NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteTicketComplaint.rawValue), params: { (params:NetParams?) in
                params?.method = .POST
                params?.data   = ["ticket_id": self.orderId ?? "",
                                  "reason_id":self.dataSource[self.defaultSelectIndex].toInt(),
                                  "content":self.contentTextView?.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""]
            })
        }
        
        
    }
    //MARK: UINavigationViewDelegate
    override func navigationViewBackClick() {
        super.navigationViewBackClick()
    }
    
    override func navigationViewRightClick() {
        super.navigationViewRightClick()
        //可以跳转到投诉页面
        if self.viewControllerType == .Reason {
            let complaintViewController:ScheduleCancelReasonViewController = ScheduleCancelReasonViewController.instance(withStoryboardName: "ScheduledOrder")
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
        labelView.text = "退票原因"
        labelView.backgroundColor = UIColor_Background
//        labelView.backgroundColor = UIColor_DefOrange
        
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
        if result.type == Int32(EmRequestType_CommuteTicketReason.rawValue) {
            //设置列表需要刷新
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KOrderRefreshNotification), object: nil)
            //页面跳转
            self.showTip("提交成功", with: FNTipTypeSuccess)
            //回调
            if (self.cancelBlockCallback != nil) {
                self.cancelBlockCallback!(self.orderId!)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC))/Double(NSEC_PER_SEC)) {
                //跳转到退款页面
                let refundDetail:ScheduleRefundViewController = ScheduleRefundViewController.instance(withStoryboardName: "ScheduledOrder")
                refundDetail.id = self.orderId;
                let controllers:NSMutableArray =  NSMutableArray.init(array: (self.navigationController?.viewControllers)!)
                controllers.removeLastObject()
                controllers.add(refundDetail)
                
                self.navigationController?.setViewControllers((controllers as NSArray as? [UIViewController])!, animated: true)
            }
        }
        else if result.type == Int32(EmRequestType_CommuteTicketComplaint.rawValue) {
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
