//
//  customClearButtonTextField.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 2017/5/24.
//  Copyright © 2017年 tianbo. All rights reserved.
//

import UIKit

class CustomClearButtonTextField: UITextField {

    
    /*// Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        
    }*/
 
    override func awakeFromNib() {
        //自定义晴空按钮
        let clearButton:UIButton = self.value(forKey: "_clearButton") as! UIButton
        clearButton.setImage(UIImage.init(named: "icon_delete"), for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //自定义晴空按钮
        let clearButton:UIButton = self.value(forKey: "_clearButton") as! UIButton
        clearButton.setImage(UIImage.init(named: "icon_delete"), for: .normal)
    }
}
