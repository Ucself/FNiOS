//
//  ScheduleMainTableViewCell.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/12/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class ScheduleMainTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var btnBuy: UIButton!
    @IBOutlet weak var originalPrice: UILineLabel!  //原价
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var imageDescription: UIImageView!
    
    
    @IBOutlet weak var viewMark: UIView!
    @IBOutlet weak var labelStart: UILabel!
    @IBOutlet weak var labelEnd: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelRemark: UILabel!
    @IBOutlet weak var imageRemark: UIImageView!
    
    @IBOutlet weak var iconTimeY: NSLayoutConstraint!
    
    
    @IBOutlet weak var line: UIImageView!
    @IBOutlet weak var bgView: UIView!
    //数据
    var commuteObj:CommuteObj?
    
    //回调闭包 用于评价成功后
    typealias callbackFunc = (_ commuteObj:CommuteObj ) -> Void
    var evaluationBlockCallback:callbackFunc?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.bgView.layer.borderColor = UIColorFromRGB(0xbbbbbf).cgColor
        self.bgView.layer.borderWidth = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func btnBuyClick(_ sender: Any) {
        
        if evaluationBlockCallback != nil {
            self.evaluationBlockCallback!(self.commuteObj!)
        }
    }
    
    
    func setWithCommuteListObj(tempCommuteObj:CommuteObj){
        //数据
        self.commuteObj = tempCommuteObj
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
        
        if endName == "" {
            self.line.isHidden = true
        }
        else {
            self.line.isHidden = false
        }
        
        //绑定界面显示
        self.labelStart.text = startName
        self.labelEnd.text = endName
        self.labelTime.text = "\(tempCommuteObj.timeFormat(timeString: tempCommuteObj.line_departure_time))(始发) - \(tempCommuteObj.timeFormat(timeString: tempCommuteObj.line_arrival_time))(到达)"
        self.labelDescription.text = tempCommuteObj.routeStateToName()
        if tempCommuteObj.remark != "" {
            self.iconTimeY.constant = 0
            self.imageRemark.isHidden = false
            self.labelRemark.isHidden = false
            self.labelRemark.text = tempCommuteObj.remark
        }
        else {
            self.iconTimeY.constant = 10
            self.imageRemark.isHidden = true
            self.labelRemark.isHidden = true
        }
        
        
        
        switch CommuteRouteState(rawValue:tempCommuteObj.route_state)!  {
        case .Bought:
            self.imageDescription.isHidden = false
            self.imageDescription.image = UIImage.init(named: "icon_box_orange")
            self.viewMark.backgroundColor = UIColorFromRGB(0xFE6E35)
        case .Nearby:
            self.imageDescription.isHidden = false
            self.imageDescription.image = UIImage.init(named: "icon_box_blue")
            self.viewMark.backgroundColor = UIColorFromRGB(0x28BCFF)
        default:
            self.imageDescription.isHidden = true
            self.viewMark.backgroundColor = UIColorFromRGB(0xD0D0D4)
        }
        //原价
        let price:Int = tempCommuteObj.price
        let string:String = NSString.calculatePrice(price)
        if tempCommuteObj.discount > 0 {
            self.originalPrice.text = string
        }
        else {
            self.originalPrice.text = ""
        }
        //折后价格
        self.btnBuy.setTitle("\(NSString.calculatePrice(tempCommuteObj.promotion_price)!) 购票", for: UIControlState.normal)
//        self.btnBuy.titleLabel?.adjustsFontSizeToFitWidth = true
        //获取文本宽度
        let length =  NSString.calculatePrice(tempCommuteObj.promotion_price)!.characters.count
        if length > 3 {
            if #available(iOS 8.2, *) {
                self.btnBuy.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightMedium)
            } else {
                self.btnBuy.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            }
        }
        else {
            if #available(iOS 8.2, *) {
                self.btnBuy.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
            } else {
                self.btnBuy.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            }
        }
        
    }
    
}
