//
//  UISharePickerView.swift
//  FeiNiu_User
//
//  Created by tianbo on 2017/3/23.
//  Copyright © 2017年 tianbo. All rights reserved.
//

enum EmShareType {
    case Action_WxTimeLine
    case Action_Wx
    case Action_Sina
    case Action_QQ
    case Action_Qzone
    case Action_Cancel
}

import UIKit

class UISharePickerView: BaseUIView {

    typealias selectActionBlock = (_ type:EmShareType ) -> Void
    var selectAction:selectActionBlock?
    @IBOutlet weak var btmViewBtmCons: NSLayoutConstraint!
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UITranslucentBKColor
    }
    
    
    //MARK: -
    func showInView(_ view: UIView) {
        view.addSubview(self)
        self.frame = view.bounds
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.4) {
            self.btmViewBtmCons.constant = 0
            self.layoutIfNeeded()
        }
    }
    
    func hide() {
        
        UIView.animate(withDuration: 0.4, animations: {
            self.btmViewBtmCons.constant = 0 - self.frame.size.height
            self.layoutIfNeeded()
        }) { (completion) in
            self.removeFromSuperview()
        }
    }
    
    
    //MARK: -
    @IBAction func btnWechatTimeLineAction(_ sender: Any) {
        self.selectAction?(.Action_WxTimeLine)
        self.hide()
    }

    @IBAction func btnWechatSessionAction(_ sender: Any) {
        self.selectAction?(.Action_Wx)
        self.hide()
    }
    
    @IBAction func btnSinaAction(_ sender: Any) {
        self.selectAction?(.Action_Sina)
        self.hide()
    }

    @IBAction func btnQQAction(_ sender: Any) {
        self.selectAction?(.Action_QQ)
        self.hide()
    }
    
    @IBAction func btnQzoneAction(_ sender: Any) {
        self.selectAction?(.Action_Qzone)
        self.hide()
    }

    @IBAction func btnCancelAction(_ sender: Any) {
        self.selectAction?(.Action_Cancel)
        self.hide()
    }
    
    
    @IBAction func btnBlankAction(_ sender: Any) {
        self.selectAction?(.Action_Cancel)
        self.hide()
    }

}
