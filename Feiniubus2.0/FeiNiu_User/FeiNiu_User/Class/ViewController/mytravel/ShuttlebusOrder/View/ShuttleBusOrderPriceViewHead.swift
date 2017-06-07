//
//  ShuttleBusOrderDetailView.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/10/13.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class ShuttleBusOrderPriceViewHead: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var payPrice: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.backgroundColor = UIColor_Background
    }
    
}
