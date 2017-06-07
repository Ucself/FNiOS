//
//  ScheduledBusSeachResultTableViewCell.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/12/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class ScheduledSeachResultTableViewCell: UITableViewCell {
    
    var tempCommuteObj:CommuteObj?

    @IBOutlet weak var routeStateView: UIView!
    @IBOutlet weak var routeStateLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var iconPlaceY: NSLayoutConstraint!
    @IBOutlet weak var imageRemark: UIImageView!
    @IBOutlet weak var labelRemark: UILabel!
    
    
    @IBOutlet weak var departureLabel: UILabel!
    @IBOutlet weak var arrivalLabel: UILabel!
    
    @IBOutlet weak var onStationTimeLabel: UILabel!
    @IBOutlet weak var onStationLabel: UILabel!
    @IBOutlet weak var offStationTimeLabel: UILabel!
    @IBOutlet weak var offStationLabel: UILabel!
    
    @IBOutlet weak var onStationDistanceLabel: UILabel!
    @IBOutlet weak var offStationDistanceLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel! //优惠后价格
    @IBOutlet weak var labelOriginalPrice: UILineLabel! //优惠后价格
    @IBOutlet weak var labelDiscount: UILabel!  //折扣
    @IBOutlet weak var priceCenterY: NSLayoutConstraint!
    
    @IBOutlet weak var buyButton: UIButton!
    
    
    //回调闭包 用于评价成功后
    typealias callbackFunc = (_ commuteObj:CommuteObj ) -> Void
    var evaluationBlockCallback:callbackFunc?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buyButtonClick(_ sender: Any) {
        if evaluationBlockCallback != nil && self.tempCommuteObj != nil{
            self.evaluationBlockCallback!(self.tempCommuteObj!)
        }
    }
    

    
    func setWithTempCommuteObj(tempCommuteObj:CommuteObj){
        
        self.tempCommuteObj = tempCommuteObj
        
        if let state = tempCommuteObj.routeStateToName() {
            self.routeStateView.isHidden = false
            self.routeStateLabel.text = state
        }
        else {
            self.routeStateView.isHidden = true
        }
        
        //分解行程名称
        let startName:String = tempCommuteObj.starting ?? ""
        let endName:String =  tempCommuteObj.destination ?? ""
//        let str1Array = tempCommuteObj.name?.components(separatedBy: "&")
//        if let nameArray = str1Array {
//            if nameArray.count > 0 {
//                startName = nameArray[0]
//            }
//            if nameArray.count > 1 {
//                endName = nameArray[1]
//            }
//        }
        
        self.startLabel.text = startName    //tempCommuteObj.from
        self.endLabel.text = endName        //tempCommuteObj.to
        
        //标记提示
        if self.tempCommuteObj?.remark != "" {
            self.iconPlaceY.constant = -7
            self.imageRemark.isHidden = false
            self.labelRemark.isHidden = false
            self.labelRemark.text = self.tempCommuteObj?.remark
        }
        else {
            self.iconPlaceY.constant = 0
            self.imageRemark.isHidden = true
            self.labelRemark.isHidden = true
        }
        
        self.departureLabel.text = "\(tempCommuteObj.from ?? "")(出发地)"
        self.arrivalLabel.text = "\(tempCommuteObj.to ?? "")(目的地)"
        
        self.onStationTimeLabel.text = tempCommuteObj.timeFormat(timeString: tempCommuteObj.on_station?.time)
        
        var attriText:NSAttributedString = (NSString.hintString(withIntactString: "\(tempCommuteObj.on_station?.name ?? "") 上车 ", hintString: "上车", intactColor: UIColor.darkText, hintColor: UIColor.gray) as? NSAttributedString)!
        self.onStationLabel.attributedText = attriText
        self.offStationTimeLabel.text = tempCommuteObj.timeFormat(timeString: tempCommuteObj.off_station?.time)
        
        attriText = (NSString.hintString(withIntactString: "\(tempCommuteObj.off_station?.name ?? "") 下车 ", hintString: "下车", intactColor: UIColor.darkText, hintColor: UIColor.gray) as? NSAttributedString)!
        self.offStationLabel.attributedText = attriText
        
        self.onStationDistanceLabel.text = String.init(format: "距离%.0f米", tempCommuteObj.on_station_distance * 1000)
        self.offStationDistanceLabel.text = String.init(format: "距离%.0f米", tempCommuteObj.off_station_distance * 1000)
        
        //价格设置
        self.priceLabel.text = NSString.calculatePrice(tempCommuteObj.promotion_price)
        priceCenterY.constant = -8
        if tempCommuteObj.is_activity_price {
            //活动价
            labelDiscount.text = "活动立减\(NSString.calculatePriceNO(tempCommuteObj.discount)!)元"
            labelOriginalPrice.text = NSString.calculatePrice(tempCommuteObj.price)
            
        }
        else if AuthorizeCache.sharedInstance().accessToken == nil  ||
            AuthorizeCache.sharedInstance().accessToken == ""{
            //未登录时
            labelDiscount.text = "登录后查看优惠价格"
            labelOriginalPrice.text = ""
        }
        else if tempCommuteObj.discount > 0 {
            labelDiscount.text = "已用优惠劵抵扣\(NSString.calculatePriceNO(tempCommuteObj.discount)!)元"
            labelOriginalPrice.text = NSString.calculatePrice(tempCommuteObj.price)
        }
        else {
            //没有优惠价格
            labelDiscount.text = ""
            labelOriginalPrice.text = ""
            priceCenterY.constant = 0
        }
    }
    
}
