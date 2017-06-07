//
//  ScheduleTicketViewController.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/12/1.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNUIView

class ScheduleTicketViewController: UserBaseUIViewController, ScheduleTicketViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var labelPage: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    
    //指定显示车票数据
    var specTicket:CommuteOrderObj?
    
    //当前操作车票
    var curTicket:CommuteOrderObj?
    
    //车票数组
    var tickets:NSArray?
    
    //车票页面数组
    var ticketViews:NSMutableArray?
    
    //当前页号
    var page:Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.specTicket == nil {
             self.requestTickets()
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.specTicket != nil {
            self.tickets = NSArray.init(object: self.specTicket as Any);
            self.addTickets();
            
            labelPage.text = ""
            //显示引导提示
            dispalyGuide()
        }
    }
    
    //请求车票数据
    func requestTickets(){
        self.startWait()
        
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteMyTickets.rawValue)) { (params) in
        }
    }
    
    func dispalyGuide(){
        //显示引导提示
        if UserPreferences.sharedInstance().getTicketGuide() == nil {
            if self.tickets != nil && self.tickets?.count != 0  {
                let guidView:ScheduleGuideView = ScheduleGuideView.initFromXib()
                guidView.showTipView = 1
                guidView.showInView(view: self.view)
                
                UserPreferences.sharedInstance().setTicketGuide("TicketGuide")
            }
        }
    }

    func addTickets() {
        guard let tickets = self.tickets  else { return }
        
        
        self.ticketViews = NSMutableArray()
        
        self.labelPage.text = "\(self.page)/\(tickets.count)"
        
        let width:Int = Int(scrollView.frame.size.width)
        let height:Int = Int(scrollView.frame.size.height)
        scrollView.contentSize = CGSize(width: width*tickets.count, height: height)
        
        
        for item in tickets.enumerated() {
            if let ticket:CommuteOrderObj = item.element as? CommuteOrderObj {
                let ticketView:ScheduleTicketView = Bundle.main.loadNibNamed("ScheduleTicketView", owner: self, options: nil)?.first as! ScheduleTicketView
                ticketView.parentController = self
                ticketView.delegate = self
                
                let x:Int = item.offset * (Int(width))
                ticketView.frame = CGRect(x: x, y: 0, width: width, height: height)
                scrollView.addSubview(ticketView)
                
                
//                ticket.ticket_state = "Uncheckable"  //测试使用
                //显示车票详情
                ticketView.setTicketData(ticket)
                
                self.ticketViews?.add(ticketView)
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        guard let tickets = self.tickets  else { return }
        
        let index = fabs(self.scrollView.contentOffset.x) / self.scrollView.frame.size.width + 1;
        
        self.page = Int(index)
        self.labelPage.text = "\(Int(index))/\(tickets.count)"
    }
    
    
    //MARK: - action
    
    @IBAction func btnRefundRuleClick(_ sender: Any) {
        let webViewController:WebContentViewController = WebContentViewController.instance(withStoryboardName: "Me")
        webViewController.vcTitle = "退款规则"
        webViewController.urlString = HTMLRefundExplain
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    
    //分享
    func scheduleTicketViewOnShareAction(ticket:CommuteOrderObj) {
//        self.curTicket = ticket
//        let refund:ScheduleEvaluationViewController = ScheduleEvaluationViewController.instance(withStoryboardName: "ScheduledOrder")
//        self.navigationController?.pushViewController(refund, animated: true)
        
        let c:InviteViewController = InviteViewController.instance(withStoryboardName: "Me")
        c.commuteId = ticket.line_id
        c.controller = self
        c.showInViewController()
    }
    
    //退票
    func scheduleTicketViewOnRefundAction(ticket:CommuteOrderObj) {
        self.curTicket = ticket
        let alert:UserCustomAlertView = UserCustomAlertView(title: "确定退票吗？", message: "", delegate: self, buttons: ["退票","取消"])
        alert.show(in: self.view)
    }
    
    //投诉
    func scheduleTicketViewOnComplaintAction(ticket:CommuteOrderObj) {
        self.curTicket = ticket
        let complaintViewController:ScheduleCancelReasonViewController = ScheduleCancelReasonViewController.instance(withStoryboardName: "ScheduledOrder")
        complaintViewController.orderId = self.curTicket?.id
        complaintViewController.viewControllerType = .Complaint
        self.navigationController?.pushViewController(complaintViewController, animated: true)
    }
    
    //验票
    func scheduleTicketViewOnValidateTicket(ticket:CommuteOrderObj) {
        self.curTicket = ticket
        
        if CommuteTicketState(rawValue: self.curTicket!.ticket_state) == .Uncheckable {
            let alertView:UserCustomAlertView = UserCustomAlertView(title: "发车前30分钟才可以\n验票噢～～", message: "", delegate: nil, buttons: ["确定"])
            if alertView.viewWithTag(1001) != nil {
                let titleLabel:UILabel = alertView.viewWithTag(1001) as! UILabel
                titleLabel.numberOfLines = 0
                titleLabel.remakeConstraints({ (make) in
                    make?.centerY.equalTo()(0)
                })
            }
            alertView.show(in: self.view)
        }
        else if CommuteTicketState(rawValue: self.curTicket!.ticket_state) == .Unchecked {
            self.startWait()
            NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteValidateTicket.rawValue)) { (params) in
                params?.method = EMRequstMethod.GET
                params?.data = ["id":ticket.id];
            }
        }
        
    }
    
    
    override func userAlertView(_ alertView: UserCustomAlertView!, dismissWithButtonIndex btnIndex: Int) {
        if btnIndex == 0 {
            //退票
            self.startWait()
            NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteOrderRefund.rawValue), params: {(param:NetParams?) -> Void in
                param?.method = EMRequstMethod.DELETE
                param?.data = ["id" : self.curTicket?.id ?? ""]
            })
        }
    }
    
    
    //MARK: http handle
    override func httpRequestFinished(_ notification: Notification!) {
        self.stopWait()
        super.httpRequestFinished(notification)
        guard let result:ResultDataModel = notification.object as? ResultDataModel else { self.stopWait(); return}
        if result.type == Int32(EmRequestType_CommuteMyTickets.rawValue) {
            self.tickets = CommuteOrderObj.mj_objectArray(withKeyValuesArray: result.data)
            
            if self.tickets?.count == 0 {
                self.bgView.isHidden = false
            }
            else{
                self.bgView.isHidden = true
            }
            
            self.addTickets()
            //添加引导提示
            self.dispalyGuide()
        }
            //验票
        else if result.type == Int32(EmRequestType_CommuteValidateTicket.rawValue) {
            self.curTicket?.ticket_state = CommuteTicketState.Checked.rawValue
            self.curTicket?.order_state = CommuteOrderState.Completed.rawValue
            
            if let view:ScheduleTicketView = self.ticketViews?.object(at: self.page-1) as? ScheduleTicketView {
                view.setTicketData(self.curTicket)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KOrderRefreshNotification), object: nil)
        }
            //退票
        else if result.type == Int32(EmRequestType_CommuteOrderRefund.rawValue) {
            self.stopWait()
            
            //更新车票状态
            self.curTicket?.ticket_state = CommuteTicketState.Unchecked.rawValue
            self.curTicket?.order_state = CommuteOrderState.Refunding.rawValue
            if let view:ScheduleTicketView = self.ticketViews?.object(at: self.page-1) as? ScheduleTicketView {
                view.setTicketData(self.curTicket)
            }
            
            //跳转到退票原因
            let controller:ScheduleCancelReasonViewController = ScheduleCancelReasonViewController.instance(withStoryboardName: "ScheduledOrder")
            controller.orderId = self.curTicket?.id
            controller.viewControllerType = .Reason
            
            if self.specTicket != nil {
                //从行程进入
                let controllers:NSMutableArray =  NSMutableArray.init(array: (self.navigationController?.viewControllers)!)
                controllers.removeObjects(in: NSMakeRange(controllers.count-2, 2))
                controllers.add(controller)
                self.navigationController?.setViewControllers((controllers as NSArray as? [UIViewController])!, animated: true)
            }
            else {
                //从主菜单进入
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KOrderRefreshNotification), object: nil)
        }
        
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
    }
}
