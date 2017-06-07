//
//  ScheduledEvaluationViewController.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/12/8.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNUIView

class ScheduleEvaluationViewController: UserBaseUIViewController, RatingBarDelegate ,UIScrollViewDelegate {
    
    //行程id
    var id:String?
    var orderObj:CommuteOrderObj?
    var requestMethod:EMRequstMethod = .GET
    
    var isComment:Bool = false //是否已经评价
    
    //控件
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var naviView: UINavigationView!
    @IBOutlet weak var labelEvaluation: UILabel!
    @IBOutlet weak var ratingBar: RatingBar!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var labelTravel: UILabel!
    @IBOutlet weak var labelStart: UILabel!
    @IBOutlet weak var labelEnd: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    @IBOutlet weak var priceViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var textView: PlaceHolderTextView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        //请求评价
        self.getEvaluate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func navigationViewRightClick() {
        let controller:ScheduleCancelReasonViewController = ScheduleCancelReasonViewController.instance(withStoryboardName: "ScheduledOrder")
        controller.orderId = id
        controller.viewControllerType = .Complaint
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func navigationViewBackClick() {
        super.navigationViewBackClick()
    }
    
    func getEvaluate () {
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteTicketEvaluate.rawValue), params: {(params:NetParams?) -> Void in
            params?.method = .GET
            params?.data = ["id":self.id]
            
            self.requestMethod = .GET
        })
    }
    
    func initUI(){
        //设置评分
        ratingBar.setImageDeselected("icon_big_star_hui", halfSelected: "icon_big_star_0.5", fullSelected: "icon_big_star_cheng", andDelegate: self)
        textView.placeHolder = "请留下您的宝贵意见"
        textView.numberLimit = 50
        
        //设置头部
        if orderObj != nil {
            self.labelTravel.text = "\(orderObj?.start_station_name ?? "")--\(orderObj?.destination_station_name ?? "")"
            //出发地
            let onDate:Date = DateUtils.string(toDate: orderObj?.on_station_time!)
            self.labelStart.text = "\(orderObj?.on_station_name ?? "") (\(DateUtils.formatDate(onDate, format: "HH:mm")!))"
            //目的地
            let offDate:Date = DateUtils.string(toDate: orderObj?.off_station_time!)
            self.labelEnd.text = "\(orderObj?.off_station_name ?? "") (\(DateUtils.formatDate(offDate, format: "HH:mm")!))"
        }
        //设置协议
        let scrollView:UIScrollView = self.tableView as UIScrollView
        scrollView.delegate = self
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView){
        self.textView.resignFirstResponder()
    }
    
    func refreshUI(with:EvaluateObj) {
        if self.isComment {
            self.priceViewHeightCons.constant = 86
            self.labelEvaluation.text = "  评价  "
            self.ratingBar.isIndicator = true
            self.textView.backgroundColor = UIColor_Background
            self.textView.isUserInteractionEnabled = false
            //设置显示数据
            self.ratingBar.setRating(Float(with.score))
            self.textView.text = with.content ?? ""
            self.priceLabel.text =  String.init(format: "¥%.2f", Double(with.price)/100.0) // with.price
            
            self.btnSubmit.isHidden = true
        }
        else {
            self.priceViewHeightCons.constant = 0
            self.labelEvaluation.text = " 请为我们的服务作评价  "
            self.ratingBar.isIndicator = false
            self.textView.backgroundColor = UIColor.white
            self.textView.isUserInteractionEnabled = true
            self.btnSubmit.isHidden = false
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
    
    
    //MARK: - Action
    @IBAction func btnSubmitClick(_ sender: Any) {
        if self.ratingBar.rating() == 0.0 {
            self.showTip("请为我们评星", with: FNTipTypeFailure)
            return
        }
        //请求数据
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_CommuteTicketEvaluate.rawValue), params: {(params:NetParams?) -> Void in
            params?.method = .POST
            params?.data = ["ticket_id":self.id ?? "",
                            "score":self.ratingBar.rating(),
                            "appraise_keys":[],
                            "content":self.textView.text]
            
            self.requestMethod = .POST
        })
    }

    
    //MARK: RatingBarDelegate
    public func ratingBar(_ ratingBar: RatingBar!, newRating: Float) {
        
    }
    //MARK: - http handler
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        self.stopWait()
        let result:ResultDataModel = notification.object as! ResultDataModel
        if result.type == Int32(EmRequestType_CommuteTicketEvaluate.rawValue) {
            if requestMethod == .GET {
                //获取评价数据
                let evaluateObj:EvaluateObj = EvaluateObj.mj_object(withKeyValues: result.data)
                
                self.refreshUI(with: evaluateObj)
            }
            else if requestMethod == .POST {
                //设置列表需要刷新
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: KOrderRefreshNotification), object: nil)
                //再次请求数据
                self.isComment = true
                self.getEvaluate()
                
                self.btnSubmit.isHidden = true
            }
        }
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
    }
}
