//
//  ShuttleBusPayFareViewController.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/10/9.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNPayment





class ShuttleBusPayFareViewController: UserBaseUIViewController,UITableViewDataSource,UITableViewDelegate {

    //包车
    var costDetail = [["name":"11座商务巴士","count":"1","price":"120"],
                      ["name":"12座商务巴士","count":"2","price":"220"],
                      ["name":"14座商务巴士","count":"3","price":"320"]]
    
    
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var labelTime: UILabel!
    
    
    //订单id
    var orderId:String?
    //支付方式
    var payType:PayType = .Wechat
    //用车类型
    var useCarType:UseCarType = .CarPool
    //人数
    var peopleNum:Int = 1
    //订单总金客
    var billDetail:Array<Any>?
    //需要支付金额
    var needPrice:Float = 0.0
    //优惠券id
    var coupon:CouponObj?
    //支付倒计时
    var timerIntervarl = 120
    
    var timer:Timer?
    var appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fd_interactivePopDisabled = true;
        
        
        self.initInterface()
        // Do any additional setup after loading the view.
        
        self.startTimer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParentViewController {
            self.endTimer()
        }

    }
    
    //MARK: -
    override func navigationViewBackClick() {
        let alertView:UserCustomAlertView = UserCustomAlertView(title: " 确定退出支付页面吗？", message: "", delegate: self, buttons: ["取消支付", "继续支付"])
        alertView.delegate = self
        alertView.show(in: self.view)
    }
    
    override func userAlertView(_ alertView: UserCustomAlertView!, dismissWithButtonIndex btnIndex: Int) {
        if btnIndex == 0 {
            _ = navigationController?.popViewController(animated:true)
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
    
    
    //MARK: - Timer
    func startTimer () {
        //设置可以后台运行
        self.appDelegate.needBgTask = true
        //记时开始
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerFunction), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    func endTimer() {
        timer?.invalidate()
        self.appDelegate.needBgTask = false
    }
    
    func timerFunction() {
        timerIntervarl = timerIntervarl - 1
        if timerIntervarl == 0 {
            self.endTimer()
            _ = navigationController?.popViewController(animated:true)
        }
        
        if let time = DateUtils.timeFormatted(Int32(timerIntervarl)) {
            self.labelTime.text = "支付倒计时 \(time)"
        }
        
    }
    
    
    // MARK: - Navigation
    func initInterface() {
        //确认用车按钮
        self.confirmButton.layer.masksToBounds = true
        self.confirmButton.layer.cornerRadius = 22
        self.confirmButton.layer.borderWidth = 1
        self.confirmButton.layer.borderColor = UIColorFromRGB(0xFE6E35).cgColor
        
        self.confirmButton.setTitle(String(format:"确认支付 ¥%.2f",self.needPrice/100), for: .normal)
        
        //倒计时
        
        if let time = DateUtils.timeFormatted(Int32(timerIntervarl)) {
            self.labelTime.text = "支付倒计时 \(time)"
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let parentView = UIView.init()
        parentView.backgroundColor = UIColor.white
        //线条line
        let lineView = UIView.init()
        parentView.addSubview(lineView)
        lineView.center = CGPoint.init(x: deviceWidth/2, y: 60/2 + 10)
        lineView.bounds = CGRect.init(x: 0, y: 0, width: deviceWidth - 110, height: 0.5)
        lineView.backgroundColor = UIColorFromRGB(0xE6E6E6)
        //中部文字
        let labelView = UILabel.init()
        parentView.addSubview(labelView)
        labelView.center = CGPoint.init(x: deviceWidth/2, y: 60/2 + 10)
        labelView.bounds = CGRect.init(x: 0, y: 0, width: 77, height: 20)
        labelView.backgroundColor = UIColor.white
        labelView.textColor = UITextColor_Black
        labelView.font = UIFont.systemFont(ofSize: 15)
        labelView.textAlignment = NSTextAlignment.center
        switch section {
        case 0:
            labelView.text = "费用详情"
        case 1:
            labelView.text = "支付方式"
        default:
            break
        }
        
        return parentView
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 14.0
        }
        return 0.01
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 28
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 && indexPath.row < 2{
            
            payType = PayType(rawValue: indexPath.row)!;
            tableView.reloadData();
            
        }else if indexPath.row == 2 {
//            //暂时不要优惠卷
//            return
//            //跳入优惠卷页面
//            //取出adcode
//            var requestAdcode:String = ""
//            if let curCity = CityInfoCache.sharedInstance().shuttleCurCity {
//                requestAdcode = curCity.adcode ?? ""
//            }
//            
//            let c:CouponsViewController = CouponsViewController.instanceFromStoryboard()
//            c.selectedCoupon = self.coupon
//            c.couponsParams = ["car_type":"CarPool",
//                               "order_type":"Commute",
//                               "adcode":requestAdcode,]
//            //回调
//            c.selectedCouponsCallback = {[weak self] (coupon:CouponObj?) -> Void in
//                guard let strongSelf = self else {return}
//                if coupon != nil {
//                    strongSelf.coupon = coupon
//                    //修改界面显示
//                }
//            }
//            
//            self.navigationController?.pushViewController(c, animated: true)
        }
        
        
    }
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            if self.useCarType == .CarPool {
                return 2
            }
            else {
                return costDetail.count + 1
            }
            
        case 1:
            return 3
        default:
            return 0
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell?
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "costCellId")
            //用车名
            let desciptionLb:UILabel = cell?.viewWithTag(101) as! UILabel
            //用车单价
            let priceLb:UILabel = cell?.viewWithTag(104) as! UILabel
            
            let bill:Dictionary<String, Any> = self.billDetail![indexPath.row] as! Dictionary<String, Any>
            if self.useCarType == .CarPool {
                let name:String = bill["name"] as! String
                let price:Int = bill["price"] as! Int
                switch indexPath.row {
                case 0:
                    priceLb.textColor = UITextColor_Black
                    priceLb.text = String(format:"¥ %.2f", Float(price)/100.0)
                    desciptionLb.text = name
                case 1:
                    priceLb.textColor = UIColor_DefOrange
                    priceLb.text = String(format:"¥ %.2f", Float(price)/100.0)
                    desciptionLb.text = name
                default:
                    break
                }
                
            }
            else {
                switch indexPath.row {
                case 0...costDetail.count - 1:
                    let item = costDetail[indexPath.row]
                    
                    desciptionLb.text = item["name"]! as String
                    priceLb.text = "¥\(item["price"]! as String)"
                    
                    break
                case costDetail.count:
                    desciptionLb.text = "总计"
                    priceLb.text = "¥\(needPrice)"
                    priceLb.textColor = UIColor_DefOrange
                    break
                default:
                    break
                }
            }
            
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "payCellId")
            //支付图标
            let payIcon:UIImageView = cell?.viewWithTag(101) as! UIImageView;
            //支付名称
            let payName:UILabel = cell?.viewWithTag(102) as! UILabel;
            //立减名称
            let reduceName:UILabel = cell?.viewWithTag(103) as! UILabel;
            //优惠价格
            let preferentialPrice:UILabel = cell?.viewWithTag(104) as! UILabel;
            //选择图标
            let selectIcon:UIImageView = cell?.viewWithTag(105) as! UIImageView;
            if self.payType == PayType(rawValue: indexPath.row) {
                selectIcon.image = UIImage.init(named: "icon_round_pressed")
            }
            else{
                selectIcon.image = UIImage.init(named: "icon_round")
            }
            switch indexPath.row {
            case 0:
                payIcon.image = UIImage.init(named: "icon_wechat")
                payName.text = "微信支付"
                reduceName.isHidden = true
                preferentialPrice.isHidden = true
            case 1:
                payIcon.image = UIImage.init(named: "icon_-alipay")
                payName.text = "支付宝支付"
                reduceName.isHidden = true
                preferentialPrice.isHidden = true
            
//            case 2:
//                payIcon.image = UIImage.init(named: "icon_yiwangtong")
//                payName.text = "一网通银行卡支付"
//                reduceName.layer.borderColor = UIColorFromRGB(0xFE6E35).cgColor
//                reduceName.layer.borderWidth = 1
//                reduceName.layer.cornerRadius = 2.0
//                reduceName.layer.masksToBounds = true
//                reduceName.isHidden = false
//                preferentialPrice.isHidden = true
            case 2:
                payIcon.image = UIImage.init(named: "icon_discount")
                payName.text = "优惠劵抵扣"
                reduceName.isHidden = true
                preferentialPrice.isHidden = false
                selectIcon.image = UIImage.init(named: "icon_right")
//                let couponPrice:Float = self.coupon != nil ? Float((self.coupon?.discount)!) : 0
//                preferentialPrice.text = "\(String.init(format: "￥%.1f", couponPrice/100))"
                preferentialPrice.text = NSString.calculatePrice(Int(self.coupon == nil ? 0 : self.coupon!.value))

            default:
                break
            }
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "payCellId")
        }
        
        return cell!
    }
    func numberOfSections(in tableView: UITableView) -> Int{
        return 2
    }
    
    
    //MARK: - function
    @IBAction func confirmClick(_ sender: AnyObject) {
        //验证复位
        validateNum = 0
        
        self.startWait()
        //取支付信息
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_PaymentCharge.rawValue)) { (params:NetParams?) in
            params?.method = .POST
            
            params?.data = ["order_class": "PassengerDedicated",
                            "channel": self.payType.toString(),
                            "order_id": self.orderId ?? "",
                            "coupon_id": self.coupon?.id ?? "0"]
        }
        
    }
    
    func payment(_ data:NSDictionary?)  {
        if let data = data {

            PaymentHelper.instance.pay(self.payType, data: data, controller:self, block: { [weak self] code in
                guard let strongSelf = self else { return}
                
                switch strongSelf.payType {
                case .Ali:
                    if code == .PaySuccess || code == .ErrCodePayProcessing {
                        strongSelf .paymetQuery()
                    }
                    else if code != .ErrCodeUserCancel {
                        strongSelf.showTip("支付失败, 请重新尝试", with: FNTipTypeFailure)
                    }
                case .Wechat:
                    if code == .PaySuccess || code == .ErrCodePayProcessing {
                        strongSelf .paymetQuery()
                    }
                    else if code == .WXNotInstalled {
                        strongSelf.showTip("没有安装微信", with: FNTipTypeFailure)
                    }
                    else if code != .ErrCodeUserCancel {
                        strongSelf.showTip("支付失败, 请重新尝试", with: FNTipTypeFailure)
                    }
                case .Union:
                    if code == .PaySuccess || code == .ErrCodePayProcessing {
                        strongSelf.paymetQuery()
                    }
                }
            })
        }
    }
    
    
    func paymetQuery() {
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_PaymentQuery.rawValue)) { (params:NetParams?) in
            params?.method = .GET
            params?.data = ["chargeId":self.charge_id];
        }
    }
    
    
    func gotoOrderDetail() {
        let order:ShuttleBusOrderStatusViewController = ShuttleBusOrderStatusViewController.instance(withStoryboardName: "ShuttleBusOrder")
        order.orderId = self.orderId;
        
        
//        let webViewController:WebContentViewController = WebContentViewController.instance(withStoryboardName:"Me");
//        webViewController.vcTitle = "查看上车点";
//        webViewController.urlString = HTMLGetonPage;
 
        let controllers:NSMutableArray =  NSMutableArray.init(array: (self.navigationController?.viewControllers)!)
        controllers.removeLastObject()
        controllers.add(order)
//        controllers.add(webViewController);
        
        self.navigationController?.setViewControllers((controllers as NSArray as? [UIViewController])!, animated: true)
        
    }
    
    
    //MARK: - http handler
    var validateNum:Int = 0
    var charge_id:String?
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        self.stopWait()
        
        guard let result:ResultDataModel = notification.object as? ResultDataModel else {return}
        if result.type == Int32(EmRequestType_PaymentCharge.rawValue) {
            if let data:NSDictionary = result.data as? NSDictionary {
                
                self.charge_id = data["charge_id"] as? String
                //调起支付
                self.payment(data["credentials"] as? NSDictionary)
            }
            
        }
        else if result.type == Int32(EmRequestType_PaymentQuery.rawValue) {
            if let data:NSDictionary = result.data as? NSDictionary {
                let succeed:Bool = data["succeed"] as! Bool
                if succeed {
                    //通知支付成功
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: KPaySuccessNotification), object: nil)
                    //支付成功, 跳转订单详情
                    self.gotoOrderDetail()
                }
                else {
                    //失败重新查询一次
                    if self.payType == .Ali || self.payType == .Wechat {
                        if validateNum == 0 {
                            validateNum = 1
                            
                            self.startWait()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                self.paymetQuery()
                            }
                            
                        }
                        else {
                            NSLog("支付查询失败!")
                        }
                        
                    }
                }
            }
        }

    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
    }
}
