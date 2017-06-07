//
//  ShuttleBusMainView.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/11/15.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

@objc protocol ShuttleBusMainViewDelegate {
    //选择航班点击
    @objc optional func chooseflightClick(shuttleBusMainView:ShuttleBusMainView)
    //选择时间点击
    @objc optional  func chooseDateTimeClick(shuttleBusMainView:ShuttleBusMainView,isDate:Bool)
    //选择站点点击
    @objc optional  func chooseStationClick(shuttleBusMainView:ShuttleBusMainView,shuttleCategory:ShuttleCategory.RawValue)
    //选择地图位置点击
    @objc optional  func chooseMapLocationClick(shuttleBusMainView:ShuttleBusMainView)
    //选择通讯录电话
    @objc optional  func chooseAddressBookPhoneClick(shuttleBusMainView:ShuttleBusMainView)
    //选择人数
    @objc optional  func choosePeopleNumberClick(shuttleBusMainView:ShuttleBusMainView)
    //包车点击
    @objc optional  func charterCarClick(shuttleBusMainView:ShuttleBusMainView)
    //拼车点击
    @objc optional  func poolingCarClick(shuttleBusMainView:ShuttleBusMainView)
}

class ShuttleBusMainView: UIView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    /*override func draw(_ rect: CGRect) {
        // Drawing code
    }*/
    
    //变量
    var parent:ShuttleBusViewController?
    var shuttleBusMainViewDelegate:ShuttleBusMainViewDelegate?
    
    //MARK: 界面控件
    //需要重新布局的界面控件
    @IBOutlet weak var flightView: UIView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var dateView: UIView!
    //界面控件
    @IBOutlet weak var flightNumberlbl: UILabel!
    @IBOutlet weak var flightIntroducelbl: UILabel!
    @IBOutlet weak var outTimelbl: UILabel!
    @IBOutlet weak var originPlacelbl: UILabel!
    @IBOutlet weak var destinationPlacelbl: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var peopleNumberlbl: UILabel!
    //拼车包车四个控件
    @IBOutlet weak var carpoolingImage: UIImageView!
    @IBOutlet weak var carpoolinglbl: UILabel!
    @IBOutlet weak var charterImage: UIImageView!
    @IBOutlet weak var charterlbl: UILabel!
    //出发地，目的地选择控件
    @IBOutlet weak var stationSelectiveView: UIView!
    @IBOutlet weak var stationSelectiveViewTopConstrint: NSLayoutConstraint!
    @IBOutlet weak var mapSelectiveView: UIView!
    @IBOutlet weak var mapSelectiveViewTopConstrint: NSLayoutConstraint!
    @IBOutlet weak var stationSelectiveImage: UIImageView!
    @IBOutlet weak var mapSelectiveImage: UIImageView!
    
    //MARK: - mothed
    override func layoutSubviews() {
        
        self.phoneTextField.addTarget(self, action: #selector(phoneNumTextFieldDidChange(textField:)), for: .editingChanged)
        
        //设置显示航班和不现实航班
        UIView.animate(withDuration: 1.0) {
            switch self.shuttleCategory {
            case .AirportPickup:
                self.flightView.mas_updateConstraints({ (maker) in
                    maker!.height.equalTo()(44)
                })
                self.dateView.mas_updateConstraints({ (maker) in
                    maker!.height.equalTo()(0)
                })
                self.firstView.mas_updateConstraints({ (maker) in
                    maker!.height.equalTo()(134)
                })
            case .AirportSend:
                self.flightView.mas_updateConstraints({ (maker) in
                    maker!.height.equalTo()(44)
                })
                self.dateView.mas_updateConstraints({ (maker) in
                    maker!.height.equalTo()(44)
                })
                self.firstView.mas_updateConstraints({ (maker) in
                    maker!.height.equalTo()(178)
                })
                
            case .TrainPickup,.BusPickup:
                self.flightView.mas_updateConstraints({ (maker) in
                    maker!.height.equalTo()(0)
                })
                self.firstView.mas_updateConstraints({ (maker) in
                    maker!.height.equalTo()(134)
                })
            default:
                break
            }
        }
    }
    
    //重新刷新界面
    func refreshUI() {
        guard (self.parent != nil) else {
            return
        }
        //订单类型          originPlacelbl 是选择车站的 destinationPlacelbl是选择地图的
        switch shuttleCategory {
        case .AirportPickup, .TrainPickup, .BusPickup:
            let origin:String? = parent?.shuttleModule.start_place?.name as String?
            let dest:String?   = parent?.shuttleModule.end_place?.name as String?
            
            if origin == nil || origin == ""{
                self.originPlacelbl.text = shuttleCategory == .AirportPickup ? "请填写航班号，自动填充航站楼" : "请选择上车地点"
                self.originPlacelbl.textColor = UITextColor_LightGray
            }
            else {
                self.originPlacelbl.text = origin
                
                self.originPlacelbl.textColor = UITextColor_Black
            }
            
            if dest == nil || dest == ""{
                self.destinationPlacelbl.text = "请选择下车地点"
                self.destinationPlacelbl.textColor = UITextColor_LightGray
            }
            else {
                self.destinationPlacelbl.text = dest
                self.destinationPlacelbl.textColor = UITextColor_Black
            }
        case .AirportSend, .TrainSend, .BusSend:
            
            let origin:String? = parent?.shuttleModule.start_place?.name as String?
            let dest:String?   = parent?.shuttleModule.end_place?.name as String?
            
            if origin == nil || origin == "" {
                self.destinationPlacelbl.text = "请选择上车地点"
                self.destinationPlacelbl.textColor = UITextColor_LightGray
            }
            else {
                self.destinationPlacelbl.text = origin
                self.destinationPlacelbl.textColor = UITextColor_Black
            }
            if dest == nil || dest == "" {
                self.originPlacelbl.text = shuttleCategory == .AirportSend ? "请填写航班号，自动填充航站楼" : "请选择上车地点"
                self.originPlacelbl.textColor = UITextColor_LightGray
            }
            else {
                self.originPlacelbl.text = dest
                self.originPlacelbl.textColor = UITextColor_Black
            }
        }
        //航班号
        if parent?.shuttleModule.flight == nil {
            self.flightNumberlbl.text = "请输入航班号"
            self.flightIntroducelbl.text = "飞机延误，司机免费等待"
            self.flightNumberlbl.textColor = UITextColor_LightGray
            self.flightIntroducelbl.textColor = UITextColor_LightGray
            
        }
        else if parent?.shuttleModule.order_type == .AirportPickup{     //接机
            //parent?.shuttleModule.flight?.flight_number as String!
            self.flightNumberlbl.text = "\((parent?.shuttleModule.flight?.flight_number)!)  \((parent?.shuttleModule.flight?.dep_city)!) - \((parent?.shuttleModule.flight?.arr_city)!)"
            self.flightIntroducelbl.text = "预计\((parent?.shuttleModule.flight?.arr_full_time)!)到达"
            self.flightNumberlbl.textColor = UITextColor_Black
            self.flightIntroducelbl.textColor = UITextColor_DarkGray
        }
        else if parent?.shuttleModule.order_type == .AirportSend{     //送机
            self.flightNumberlbl.text = "\((parent?.shuttleModule.flight?.flight_number)!)  \((parent?.shuttleModule.flight?.dep_city)!) - \((parent?.shuttleModule.flight?.arr_city)!)"
            self.flightIntroducelbl.text = "预计\((parent?.shuttleModule.flight?.dep_full_time)!)起飞"
            self.flightNumberlbl.textColor = UITextColor_Black
            self.flightIntroducelbl.textColor = UITextColor_DarkGray
        }
        //选择上车时间
        if parent?.shuttleModule.use_time == nil {
            self.outTimelbl.text = "请选择上车时间"
            self.outTimelbl.textColor = UITextColor_LightGray
        }
        else if parent?.shuttleModule.order_type == .AirportPickup && parent?.shuttleModule.flight != nil && parent?.shuttleModule.dateSelectMethod == 1 {   //接机且选择了航班号
            //有航班选择了时间
            let flightDate:Date = DateUtils.date(from: parent!.shuttleModule.flight!.arr_full_time!, format: "yyyy-MM-dd HH:mm")
            let minutesTime = DateUtils.formatDate(parent!.shuttleModule.use_time!, format: "HH:mm")
            let intervalTime = (parent!.shuttleModule.use_time!).timeIntervalSince(flightDate)
            self.outTimelbl.text = "航班到达后\(String(format: "%.0f", intervalTime/60) )分钟上车(\(minutesTime!))"
            self.outTimelbl.attributedText = NSString.hintString(withIntactString: self.outTimelbl.text, hintString: "\(String(format: "%.0f", intervalTime/60))分钟", intactColor: UITextColor_Black, hintColor: UIColor_DefOrange) as! NSAttributedString?
        }
        else{
            self.outTimelbl.textColor = UITextColor_Black
            //没有航班选择了时间
            self.outTimelbl.text = DateUtils.formatDate(parent!.shuttleModule.use_time!, format: "yyyy-MM-dd HH:mm")
        }
        //选择人数
        if parent?.shuttleModule.person_number == 0 {
            self.peopleNumberlbl.text = "请选择人数"
            self.peopleNumberlbl.textColor = UITextColor_LightGray
        }
        else {
            self.peopleNumberlbl.text  = "\((parent?.shuttleModule.person_number)!)人"
            self.peopleNumberlbl.textColor = UITextColor_Black
        }
        
        self.phoneTextField.text  = parent?.shuttleModule.phone as String!    }
    
    //MARK:属性值
    //属性值
    var shuttleCategory:ShuttleCategory = .AirportPickup{
        didSet{
            //视图还未创建时直接返回
            if self.firstView == nil {
                return
            }
            //动画交换接送地位置
            switch shuttleCategory {
            case .AirportPickup,.TrainPickup,.BusPickup:
                UIView.animate(withDuration: 0.4, animations: {

                    self.stationSelectiveViewTopConstrint.constant = 0
                    self.mapSelectiveViewTopConstrint.constant = 44
                    self.firstView.layoutIfNeeded()
                }, completion: { (result:Bool) in
                    self.stationSelectiveImage.image = UIImage.init(named: "icon_start")
                    self.mapSelectiveImage.image = UIImage.init(named: "icon_end")
                    //重新布局 接机和送机布局不一样
                    self.layoutSubviews()
                })
            case .AirportSend,.TrainSend,.BusSend:
                UIView.animate(withDuration: 0.4, animations: {
                    self.stationSelectiveViewTopConstrint.constant = 44
                    self.mapSelectiveViewTopConstrint.constant = 0
                    self.firstView.layoutIfNeeded()
                }, completion: { (result:Bool) in
                    self.stationSelectiveImage.image = UIImage.init(named: "icon_end")
                    self.mapSelectiveImage.image = UIImage.init(named: "icon_start")
                    //重新布局 接机和送机布局不一样
                    self.layoutSubviews()
                })
            }

            self.refreshUI()
        }
    }
    var nowUseCarType:UseCarType = .Chartered{
        didSet{
            //隐藏隐藏
            self.hideKeyboard()
            //设置界面
            switch nowUseCarType {
            case .Chartered:
                self.charterlbl.textColor = UIColorFromRGB(0xFE6E35)
//                self.charterImage.snp.remakeConstraints({ (make) in
//                    make.width.equalTo(17)
//                    make.height.equalTo(13)
//                })
                self.charterImage.mas_makeConstraints({ (maker) in
                    maker!.width.equalTo()(17)
                    maker!.height.equalTo()(13)
                })
                self.carpoolinglbl.textColor = UITextColor_Black
//                self.carpoolingImage.snp.remakeConstraints({ (make) in
//                    make.width.equalTo(0)
//                    make.height.equalTo(0)
//                })
                self.carpoolingImage.mas_makeConstraints({ (maker) in
                    maker!.width.equalTo()(0)
                    maker!.height.equalTo()(0)
                })
            case .CarPool:
                self.carpoolinglbl.textColor = UIColor_DefOrange
//                self.carpoolingImage.snp.remakeConstraints({ (make) in
//                    make.width.equalTo(17)
//                    make.height.equalTo(13)
//                })
                self.carpoolingImage.mas_makeConstraints({ (maker) in
                    maker!.width.equalTo()(17)
                    maker!.height.equalTo()(13)
                })
                self.charterlbl.textColor = UITextColor_Black
//                self.charterImage.snp.remakeConstraints({ (make) in
//                    make.width.equalTo(0)
//                    make.height.equalTo(0)
//                })
                self.charterImage.mas_makeConstraints({ (maker) in
                    maker!.width.equalTo()(0)
                    maker!.height.equalTo()(0)
                })
            }
        }
    }
    //MARK:Action
    //隐藏键盘
    func hideKeyboard() {
        self.phoneTextField.resignFirstResponder()
    }
    //包车点击
    @IBAction func charterCarClick(_ sender: AnyObject) {
        self.nowUseCarType = .Chartered
        self.shuttleBusMainViewDelegate?.charterCarClick!(shuttleBusMainView: self)
    }
    //拼车点击
    @IBAction func carpoolingCarClick(_ sender: AnyObject) {
        self.nowUseCarType = .CarPool
        self.shuttleBusMainViewDelegate?.poolingCarClick!(shuttleBusMainView: self)
    }
    //选择航班点击
    @IBAction func chooseFlightClick(_ sender: AnyObject) {
        self.shuttleBusMainViewDelegate?.chooseflightClick!(shuttleBusMainView: self)
    }
    
    //选择时间
    @IBAction func dateViewClick(_ sender: AnyObject) {
        //隐藏键盘
        self.hideKeyboard()
        if parent?.shuttleModule.order_type == .AirportPickup && parent?.shuttleModule.flight != nil{
            //送机选择分钟数
            self.shuttleBusMainViewDelegate?.chooseDateTimeClick!(shuttleBusMainView: self, isDate: false)
        }
        else{
            //其他选择全部时间
            self.shuttleBusMainViewDelegate?.chooseDateTimeClick!(shuttleBusMainView: self, isDate: true)
        }
        
    }
    //选择人数
    @IBAction func numberViewClick(_ sender: AnyObject) {
        //隐藏键盘
        self.hideKeyboard()
        self.shuttleBusMainViewDelegate?.choosePeopleNumberClick!(shuttleBusMainView: self)
    }
    //选择电话簿（其他人）
    @IBAction func forOtherClick(_ sender: AnyObject) {
        self.shuttleBusMainViewDelegate?.chooseAddressBookPhoneClick!(shuttleBusMainView: self)
    }
    //选择机场，汽车站，火车站
    @IBAction func fromViewClick(_ sender: AnyObject) {
        self.shuttleBusMainViewDelegate?.chooseStationClick!(shuttleBusMainView: self, shuttleCategory: self.shuttleCategory.rawValue)
        //3.4 接送机不能选择航站楼
//        switch self.shuttleCategory {
//        case .AirportPickup,.AirportSend:
//            break
//        default:
//            //其他可以点击
//            self.shuttleBusMainViewDelegate?.chooseStationClick!(shuttleBusMainView: self, shuttleCategory: self.shuttleCategory.rawValue)
//        }
    }
    //选择地图选址
    @IBAction func toViewClick(_ sender: AnyObject) {
        self.shuttleBusMainViewDelegate?.chooseMapLocationClick!(shuttleBusMainView: self)
    }
    
    func phoneNumTextFieldDidChange(textField:UITextField) {
        if textField == phoneTextField {
            if (textField.text?.characters.count)! > 11 {
                let index = textField.text?.index((textField.text?.startIndex)!, offsetBy: 11)
                textField.text = textField.text?.substring(to: index!)
            }
        }
        
        parent?.shuttleModule.phone = textField.text
    }
    
    func textFieldResponder()  {
        self.phoneTextField.resignFirstResponder()
    }
}
