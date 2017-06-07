//
//  ShuttleBusDriverInforHeadView.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/12/1.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class ShuttleBusDriverInforHeadView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //驾驶员头像
    @IBOutlet weak var headImageView: UIImageView!
    //名字
    @IBOutlet weak var driverNameLabel: UILabel!
    //得分
    @IBOutlet weak var scoreLabel: UILabel!
    //星级得分
    @IBOutlet weak var ratingBar: ShuttleBusRatingBar!
    //车辆信息
    @IBOutlet weak var carInfor: UILabel!
    //这个订单第几个驾驶员
    @IBOutlet weak var sortingDriverLabel: UILabel!
    //分数背景图
    @IBOutlet weak var scoreBgImage: UIImageView!
    
    @IBOutlet weak var phoneRightCons: NSLayoutConstraint!
    
    
    @IBOutlet weak var labelHint: UILabel!
    //电话号码
    var phoneNum:String?
    
    @IBOutlet weak var headImageLeft: NSLayoutConstraint!
    @IBOutlet weak var sortingDriverRight: NSLayoutConstraint!
    
    
    
    override func awakeFromNib() {
        //设置星图片
        self.ratingBar.isIndicator = true
        self.ratingBar.setImageDeselected("icon_star_hui", halfSelected: "icon_star_0.5", fullSelected: "icon_star_cheng", andDelegate: nil)
        //iPhone5 宽度的时候减少边距
        if deviceWidth <= 320.0 {
            headImageLeft.constant = 12
            sortingDriverRight.constant = 12
        }
    }
    
    @IBAction func phoneClick(_ sender: Any) {
        if self.phoneNum != nil {
            UIApplication.shared.openURL(URL.init(string: "telprompt://\(self.phoneNum!)")!)
        }
    }
    
}
