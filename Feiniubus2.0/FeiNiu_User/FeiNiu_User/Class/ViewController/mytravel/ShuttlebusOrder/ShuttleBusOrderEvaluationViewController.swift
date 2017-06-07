//
//  ShuttleBusOrderEvaluationViewController.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/10/14.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNUIView

class ShuttleBusOrderEvaluationViewController: UserBaseUIViewController,UITextViewDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,RatingBarDelegate {
    
    var refreshDelegate:ShuttleOrderListDelegate?
    //数据
    var orderId:String?
    var score:Float = 0 //评分
    var tags:[Int]?  //评价标签
    var content:String? //评价内容
    //回调闭包 用于评价成功后
    typealias callbackFunc = (_ orderId:String ) -> Void
    var evaluationBlockCallback:callbackFunc?
    //界面控件
    @IBOutlet weak var heardView: UIView!           //整个可滑动view
    //驾驶员头部信息
    @IBOutlet weak var driverScrollView: UIScrollView!
    
    //费用详情相关控件
    @IBOutlet weak var costDetailView: UIView!
    @IBOutlet weak var costDetailLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var costDetailHeight: NSLayoutConstraint!
    
    
    //评价相关控件
    @IBOutlet weak var evaluationView: UIView!
    @IBOutlet weak var evaluationLabel: UILabel!
    @IBOutlet weak var evaluationWidth: NSLayoutConstraint!
    
    //评价星相关控件
    @IBOutlet weak var startViewBig: RatingBar!
    
    //评价选项相关控件
    @IBOutlet weak var autoLayoutTagsView: AutoLayoutTagsView! //评价选项

    @IBOutlet weak var tagViewHeightCons: NSLayoutConstraint!
    //填写评价内容
    @IBOutlet weak var writeEvaluationTextView: PlaceHolderTextView!
    
    //提交按钮
    @IBOutlet weak var submitButton: UIButton!
    
    
    //默认标签数据
    let defaultTags = [systemEvaluationType.CarGood.toString():false,
                          systemEvaluationType.ExperienceGood.toString():false,
                          systemEvaluationType.PriceAffordable.toString():false,
                          systemEvaluationType.ServiceGood.toString():false,
                          systemEvaluationType.DriverOnTime.toString():false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        
        //第一次加载隐藏
        self.heardView.isHidden = true
        self.submitButton.isHidden = true
        //请求数据 判断是提交评价还是，展示评价
        self.getEvaluate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getEvaluate () {
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_EvaluateGet.rawValue), params: {(params:NetParams?) -> Void in
            params?.method = .GET
            params?.data = ["id":self.orderId]
        })
    }
    
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func initUI(){
        //设置评分
        startViewBig.setImageDeselected("icon_big_star_hui", halfSelected: "icon_big_star_0.5", fullSelected: "icon_big_star_cheng", andDelegate: self)
        
        //填写评价
        self.writeEvaluationTextView.layer.cornerRadius = 3
        self.writeEvaluationTextView.delegate = self
        self.writeEvaluationTextView.placeHolder = "请留下你宝贵的意见"
        self.writeEvaluationTextView.numberLimit = 50;
        
        self.costDetailLabel.backgroundColor = UIColor_Background
        self.evaluationLabel.backgroundColor = UIColor_Background
        //边框圆角
        self.submitButton.layer.borderWidth = 1
        self.submitButton.layer.borderColor = UIColorFromRGB(0xFE6E35).cgColor
        //设置驾驶员信息
        self.driverScrollView.contentSize = CGSize.init(width: deviceWidth, height: 65)
        self.driverScrollView.showsVerticalScrollIndicator = false
        self.driverScrollView.showsHorizontalScrollIndicator = false
        self.driverScrollView.isPagingEnabled = true
        
    }
    func hideKeyboard(){
        self.writeEvaluationTextView.resignFirstResponder()
    }
    
    
    func configUI(with evaluateObj:EvaluateObj?) {
        guard let obj:EvaluateObj = evaluateObj else { return }
        
        
        self.heardView.isHidden = false
        if obj.is_comment {
            //显示费用费用详情
            self.costDetailHeight.constant = 83
            //设置评价名称
            self.evaluationLabel.text = "评价"
            self.evaluationWidth.constant = 50.0
            //设置星星 是指示器
            self.startViewBig.isIndicator = true
            //设置选项
            self.autoLayoutTagsView.isEnabled = false
            //设置评价内容隐藏
            self.writeEvaluationTextView.backgroundColor = UIColor_Background
            self.writeEvaluationTextView.isUserInteractionEnabled = false
            //提交按钮
            self.submitButton.isHidden = true
            
            //评价
            self.startViewBig.setRating(Float(obj.score))
            //评价内容
            if obj.content == nil || obj.content == "" {
                obj.content = " "
            }
            self.writeEvaluationTextView.text = obj.content
            //费用详情加载
            self.priceLabel.text = String(format:"¥%.1f",Float(obj.payment_price)/100)
            
            //标签
            var tags:Dictionary = [AnyHashable: Any]()
            if obj.appraise_keys != nil {
                if let arKeys:Array = obj.appraise_keys?.components(separatedBy: ",") {
                    //有标签
                    for item in arKeys.enumerated() {
                        //标签转换为Int
                        if let itemInt = Int(item.element) {
                            
                            let evaluationType:systemEvaluationType = systemEvaluationType(rawValue: itemInt)!
                            tags.updateValue(true, forKey: evaluationType.toString())
                        }
                    }
                }
            }
            
            autoLayoutTagsView.removeAll()
            let lines:CGFloat = CGFloat(autoLayoutTagsView.addItemsDictionary(tags))
            self.tagViewHeightCons.constant = lines * 35
        }
        else {
            //隐藏费用详情
            self.costDetailHeight.constant = 0.0
            //设置评价名称
            self.evaluationLabel.text = "请为我们的服务作评价"
            self.evaluationWidth.constant = 170.0
            //设置星星  不是指示器
            self.startViewBig.isIndicator = false
            //设置选项
            self.autoLayoutTagsView.isEnabled = true
            //设置评价内容隐藏
            self.writeEvaluationTextView.backgroundColor = UIColor.white
            self.writeEvaluationTextView.isUserInteractionEnabled = true
            
            self.submitButton.isHidden = false
            
            
            //标签数据回调
            let lines:CGFloat = CGFloat(autoLayoutTagsView.addItemsDictionary(defaultTags))
            autoLayoutTagsView.selectChangeActionDic = {[weak self] (items:Dictionary?)->Void in
                guard let strongSelf = self else { return }
                
                if items != nil {
                    var tempTags:[Int] = [Int]()
                    for (key,value) in items! {
                        if (value as! Bool) {
                            let keyTag:systemEvaluationType = systemEvaluationType.toEnum(name: key as! String)
                            tempTags.append(keyTag.rawValue)
                        }
                    }
                    strongSelf.tags = tempTags
                }
            }
            
            self.tagViewHeightCons.constant = lines * 35
        }
        
        //驾驶员信息
        if self.driverScrollView.subviews.count == 0 {
            self.driverScrollView.contentSize = CGSize.init(width: Int(deviceWidth) * (obj.order_dispatches?.count)!, height: 65)
            var itemCount:Int = 0
            for item:DriverObj in obj.order_dispatches as! [DriverObj] {
                let driverInforHead:ShuttleBusDriverInforHeadView = Bundle.main.loadNibNamed("ShuttleBusEvaluationDriverInforHeadView", owner: nil, options: nil)?[0] as! ShuttleBusDriverInforHeadView
                self.driverScrollView.addSubview(driverInforHead)
//                driverInforHead.snp.makeConstraints({ (maker) in
//                    maker.left.equalTo(self.driverScrollView).offset(itemCount * Int(deviceWidth))
//                    maker.top.equalTo(self.driverScrollView)
//                    maker.width.equalTo(deviceWidth)
//                    maker.height.equalTo(65)
//                })
                let offsetWith = itemCount*Int(deviceWidth)
                driverInforHead.mas_makeConstraints({ (maker) in
                    maker!.left.equalTo()(self.driverScrollView)?.setOffset(CGFloat(offsetWith))
                    maker!.top.equalTo()(self.driverScrollView)
                    maker!.width.equalTo()(deviceWidth)
                    maker!.height.equalTo()(65)
                })
                //设置司机界面显示
                //driverInforHead.headImageView.sd_setImage(with: URL.init(string: (item.avatar ?? "")), placeholderImage: UIImage.init(named: "icon_driver"))
                driverInforHead.headImageView.setImageWith(URL.init(string: (item.avatar ?? "")), placeholderImage: UIImage.init(named: "icon_driver"))
                driverInforHead.driverNameLabel.text = item.name
                driverInforHead.scoreLabel.text = String(format:" %.1f",item.score)
                driverInforHead.ratingBar.setRating(item.score)
//                driverInforHead.carInfor.text = "\(item.license!) (\(item.people_number)人/\(item.seats)座)"
                driverInforHead.carInfor.text = "\(item.license!)"
                driverInforHead.phoneNum = item.phone
                driverInforHead.sortingDriverLabel.text = "\(itemCount+1)/\((obj.order_dispatches?.count)!)"
                driverInforHead.sortingDriverLabel.attributedText = NSString.hintString(withIntactString: driverInforHead.sortingDriverLabel.text,
                                                                                        hintString: "\(itemCount+1)",
                    intactColor: UITextColor_LightGray,
                    hintColor: UIColorFromRGB(0xFE6E35)) as! NSAttributedString?
                
                //最后加一
                itemCount += 1
            }
        }
        
    }
    
    //MARK:  Action
    override func navigationViewRightClick() {
        //跳转到投诉
        let cancelReasonViewController:ShuttleBusOrderCancelReasonViewController = ShuttleBusOrderCancelReasonViewController.instance(withStoryboardName: "ShuttleBusOrder")
        cancelReasonViewController.orderId = self.orderId
        cancelReasonViewController.viewControllerType = .Complaint
        self.navigationController?.pushViewController(cancelReasonViewController, animated: true)
    }
    @IBAction func checkDetailClick(_ sender: Any) {
        //查看明细，从订单详情中查找
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_BillDetail.rawValue)) { (params:NetParams?) in
            params?.method = .GET
            params?.data = ["id": self.orderId!]
        }
        
    }
    @IBAction func submitClick(_ sender: Any) {
        
        if self.score <= 0 {
            self.showTip("请为我们的服务评星", with: FNTipTypeFailure)
            return
        }
        //数据请求
        self.content = self.writeEvaluationTextView.text
        
        self.startWait()
        NetInterfaceManager.sharedInstance().sendRequst(withType: Int32(EmRequestType_EvaluatePost.rawValue), params: {(params:NetParams?) -> Void in
            params?.method = .POST
            params?.data = ["order_id":self.orderId ?? "",
                            "score":self.score,
                            "appraise_keys":self.tags ?? [],
                            "content":self.content ?? ""]
        })
        //刷新列表
        self.refreshDelegate?.setNeedRefresh!()
    }
    
    //MARK: RatingBarDelegate
    func ratingBar(_ ratingBar: RatingBar!, newRating: Float) {
        self.score = newRating
    }
    
    //MARK: UITextViewDelegate
    public func textViewDidBeginEditing(_ textView: UITextView){
        
    }
    public func textViewDidEndEditing(_ textView: UITextView){
        if self.writeEvaluationTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != "" {
            
        }
        else{
            
        }
    }
    //scroll 协议
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        self.hideKeyboard()
    }
    //MARK:  UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell.init()
    }
    
    //MARK: - http handler
    override func httpRequestFinished(_ notification: Notification!) {
        super.httpRequestFinished(notification)
        self.stopWait()
        let result:ResultDataModel = notification.object as! ResultDataModel
        if result.type == Int32(EmRequestType_EvaluateGet.rawValue) {
            //获取评价数据
            let evaluateObj:EvaluateObj = EvaluateObj.mj_object(withKeyValues: result.data)
            
            self.configUI(with: evaluateObj)

        }
        else if result.type == Int32(EmRequestType_EvaluatePost.rawValue) {
            //回调
            if self.evaluationBlockCallback != nil {
                self.evaluationBlockCallback!(self.orderId!)
            }
            //self.showTip("感谢你的评价", with: FNTipTypeSuccess)
            self.getEvaluate()
        }
        else if result.type == Int32(EmRequestType_OrderDetail.rawValue) {
//            let order:ShuttleOrderObj = ShuttleOrderObj.mj_object(withKeyValues: result.data)
            
        }
        else if result.type == Int32(EmRequestType_BillDetail.rawValue) {
            //跳转页面使用
            let priceController:ShuttleBusOrderPriceViewController = ShuttleBusOrderPriceViewController.instance(withStoryboardName: "ShuttleBusOrder")
            priceController.dataSourceArray = result.data as? Array<Any>
            self.navigationController?.pushViewController(priceController, animated: true)
        }
    }
    
    override func httpRequestFailed(_ notification: Notification!) {
        super.httpRequestFailed(notification)
    }
}
