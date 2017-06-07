//
//  ShuttleBusTipUIView.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/9/29.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNUIView
//import SnapKit

class ShuttleBusTipUIView: BaseUIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBInspectable var tipTitle:String?{
        get{
            return self.tipTitle
        }
        set(newVal){
            self.tipLabel.text = newVal
        }
    }
    @IBInspectable var tipHigh:Int = 0
    
    var tipLabel:UILabel = UILabel.init()
    var bellImageView:UIImageView = UIImageView.init()
    var closeImageView:UIImageView = UIImageView.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initUI()
    }
    
    // MARK:
    func initUI() {
        self.backgroundColor = UIColorFromRGB(0xFFAA89)
        self.clipsToBounds = true
        //提示铃铛
        bellImageView.image = UIImage.init(named: "icon_ling")
        self.addSubview(bellImageView)
        bellImageView.mas_makeConstraints { (make) in
            make!.centerY.equalTo()(self)?.setOffset(0)
            make!.width.equalTo()(12)
            make!.height.equalTo()(14)
            make!.left.equalTo()(self)?.setOffset(12)
        }
//        bellImageView.snp.makeConstraints { (make) in
//            make.centerY.equalTo(self)
//            make.width.equalTo(12)
//            make.height.equalTo(14)
//            make.left.equalTo(self).offset(12)
//        }
        //关闭提示按钮
        closeImageView.image = UIImage.init(named: "icon_delete_white")
        self.addSubview(closeImageView)
        closeImageView.mas_makeConstraints { (make) in
            make!.centerY.equalTo()(self)?.setOffset(0)
            make!.width.equalTo()(26)
            make!.height.equalTo()(26)
            make!.right.equalTo()(self)?.setOffset(-12)
        }
//        closeImageView.snp.makeConstraints { (make) in
//            make.centerY.equalTo(self)
//            make.width.equalTo(26)
//            make.height.equalTo(26)
//            make.right.equalTo(self).offset(-12)
//        }
        //
        //提示文字
        self.addSubview(tipLabel)
        self.tipLabel.textColor = UIColorFromRGB(0xFFFFFF)
        self.tipLabel.font = UIFont.systemFont(ofSize: 13)
        tipLabel.mas_makeConstraints { (make) in
            make!.top.equalTo()(self)
            make!.bottom.equalTo()(self)
            make!.left.equalTo()(self.bellImageView.right)?.setOffset(10)
            make!.right.equalTo()(self.closeImageView.left)
        }
//        tipLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(self)
//            make.bottom.equalTo(self)
//            make.left.equalTo(self.bellImageView.snp.right).offset(10)
//            make.right.equalTo(self.closeImageView.snp.left)
//        }
    }
    
}
