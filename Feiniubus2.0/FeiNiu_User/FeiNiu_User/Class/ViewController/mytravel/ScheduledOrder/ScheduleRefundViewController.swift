//
//  ScheduleOrderRefundViewController.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/12/8.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class ScheduleRefundViewController: UserBaseUIViewController {
    //数据
    var id:String?
    
    //界面控件
    @IBOutlet weak var MaskLayerView: UIView!   //界面遮罩层
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var useDateLabel: UILabel!   //用车时间控件
    @IBOutlet weak var startLabel: UILabel!  //出发地
    @IBOutlet weak var endLabel: UILabel!    //目的地
    @IBOutlet weak var cancelReasonLabel: UILabel!  //取消原因
    
    @IBOutlet weak var refundProcessImg: UIImageView!
    @IBOutlet weak var firstProcessNameLabel: UILabel!
    @IBOutlet weak var firstProcessDateLabel: UILabel!
    @IBOutlet weak var firstProcessDescribeLabel: UILabel!
    @IBOutlet weak var secondProcessNameLabel: UILabel!
    @IBOutlet weak var secondProcessDateLabel: UILabel!
    @IBOutlet weak var secondProcessDescribeLabel: UILabel!
    @IBOutlet weak var thirdProcessNameLabel: UILabel!
    @IBOutlet weak var thirdProcessDateLabel: UILabel!
    @IBOutlet weak var thirdProcessDescribeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.requestRefund()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initUI() {
        //圆角和边框
        self.infoView.layer.cornerRadius = 5
        self.infoView.layer.borderWidth = 0.5
        self.infoView.layer.borderColor = UIColorFromRGB(0xBBBBBF).cgColor
        
    }
    
    func requestRefund() {
        //请求数据
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteTicketRefund.rawValue), params: {(params:NetParams?) -> Void in
            params?.method = .GET
            params?.data = ["id":self.id]
        })
    }
    
    override func navigationViewRightClick() {
        super.navigationViewRightClick()
        //跳转到投诉
        let cancelReasonViewController:ScheduleCancelReasonViewController = ScheduleCancelReasonViewController.instance(withStoryboardName: "ScheduledOrder")
        cancelReasonViewController.orderId = self.id
        cancelReasonViewController.viewControllerType = .Complaint
        self.navigationController?.pushViewController(cancelReasonViewController, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //MARK: - http handler
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        self.stopWait()
        let result:ResultDataModel = notification.object as! ResultDataModel
        
        if result.type == Int32(EmRequestType_CommuteTicketRefund.rawValue) {
            self.stopWait()
            //解析数据
            let refundDetailObj:TicketRefundDetailObj = TicketRefundDetailObj.mj_object(withKeyValues: result.data)
            //时间数据
            var firstProcessDate:String?
            var secondProcessDate:String?
            var thirdProcessDate:String?
            for tempLog:RefundLog in refundDetailObj.refund_log!{
                switch ShuttleOrderState(rawValue:tempLog.order_state!)! {
                case .RefundApplying:
                    firstProcessDate = tempLog.time
                case .Refunding:
                    secondProcessDate = tempLog.time
                case .Refunded:
                    thirdProcessDate = tempLog.time
                default:
                    break
                }
            }
            if firstProcessDate != nil {
                self.firstProcessDateLabel.text = firstProcessDate
            }
            if secondProcessDate != nil {
                self.secondProcessDateLabel.text = secondProcessDate
            }
            if thirdProcessDate != nil {
                self.thirdProcessDateLabel.text = thirdProcessDate
            }
            else {
                self.thirdProcessDateLabel.text = "(退款将在3-7个工作日退到您的账户，请耐心等待)"
            }
            //基础信息
            let useDate:Date = DateUtils.date(from: refundDetailObj.ticket_date, format: "yyyy-MM-dd HH:mm:ss")
            self.useDateLabel.text = DateUtils.formatDate(useDate, format: "yyyy年MM月dd日")
            self.startLabel.text = refundDetailObj.on_station_name
            self.endLabel.text = refundDetailObj.off_station_name
            self.cancelReasonLabel.text = refundDetailObj.reason
            //退款流程数据
            let state:CommuteOrderState = CommuteOrderState(rawValue: refundDetailObj.order_state!)!
            switch state {
            case .RefundApplying:
                //退款申请中
                self.refundProcessImg.image = UIImage.init(named: "progress_bar_1")
                self.firstProcessNameLabel.textColor = UIColorFromRGB(0xFE6E35)
            case .Refunding:
                //退款中
                self.refundProcessImg.image = UIImage.init(named: "progress_bar_2")
                self.secondProcessNameLabel.textColor = UIColorFromRGB(0xFE6E35)
            case .Refunded:
                //退款完成
                self.refundProcessImg.image = UIImage.init(named: "progress_bar_3")
                self.secondProcessNameLabel.textColor = UIColorFromRGB(0xFE6E35)
                self.thirdProcessNameLabel.textColor = UIColorFromRGB(0xFE6E35)
                if refundDetailObj.payment_chanel != nil {
                    self.thirdProcessDescribeLabel.text = "已将您的退款至\(refundDetailObj.payment_chanel ?? "")"
                }
            default:
                break
            }
            
            //正常返回数据取消遮罩层
            self.MaskLayerView.isHidden = true
            
        }
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
    }
}
