//
//  LoginInputView.swift
//  FeiNiu_Merchant
//
//  Created by tianbo on 16/9/8.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import SnapKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class BNSLoginInputView: UIView, UITextFieldDelegate{
    
    var limit:Int = 0
    var rightViewAlway:Bool = false
    var secureEntry:Bool = false {
        didSet {
            self.textField?.isSecureTextEntry = secureEntry
        }
    }
    var text:String? {
        didSet {
            self.textField?.text = text
        }
    }
    var placeholder:String = "" {
        didSet {
            self.textField?.placeholder = placeholder
        }
    }

    internal var textField:UITextField?
    fileprivate var rightView:UIView?
    fileprivate var imgView:UIImageView?
    fileprivate var imgNormal:UIImage?
    fileprivate var imgHigh:UIImage?
    
    
    //MARK: -
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initControl()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initControl()
    }
    
    
    func setLeftImage(_ normal:UIImage?, high:UIImage?) {
        imgNormal = normal
        imgHigh = high
        imgView?.image = normal
    }
    
    func setRightButton(_ button:UIButton, width:CGFloat, height:CGFloat) {
        guard let btn:UIButton = button else { return }
        
        rightView = btn
        self.addSubview(rightView!)
        
        rightView?.snp.makeConstraints({ (make) in
            make.right.equalTo(self.snp.right).offset(-10)
            make.centerY.equalTo(self)
            make.width.equalTo(width)
            make.height.equalTo(height)
        })
        
        textField?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.imgView!.snp_right).offset(5)
            make.centerY.equalTo(self)
            make.height.equalTo(30)
            make.right.equalTo(self.rightView!.snp_right).offset(-10)
        })
    }
    
    func initControl() {
        self.layer.borderWidth = 0.7
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.lightGray.cgColor
        
        limit = 20
        rightViewAlway = true
        
        self.imgView = UIImageView()
        self.addSubview(self.imgView!)
        
        imgView?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.snp.left).offset(5)
            make.centerY.equalTo(self)
            make.width.equalTo(25)
            make.height.equalTo(25)
        })
        
        
        textField = UITextField()
        textField?.clearButtonMode = .whileEditing
        textField?.leftViewMode = .always
        textField?.keyboardType = .numberPad
        textField?.clearsOnBeginEditing = true
        textField?.delegate = self
        textField?.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(textField!)
        
        textField?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.imgView!.snp.right).offset(5)
            make.centerY.equalTo(self)
            make.height.equalTo(30)
            make.right.equalTo(self.snp.right).offset(-5)
        })
    }
    
    
    //MARK: - textfiled delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.layer.borderColor = UIColor_DefOrange.cgColor
        
        rightView?.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.layer.borderColor = UIColor.lightGray.cgColor
        imgView?.image = self.imgNormal
        
        if self.rightViewAlway != true {
            rightView?.isHidden = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if  textField.text?.characters.count > limit {
            return false
        }
        
        text = textField.text
        
        return true
    }
    
    
    func resignFirstResponderS()  {
        textField?.resignFirstResponder()
    }
    
    func becomeFirstResponderS() {
        textField?.becomeFirstResponder()
    }
}

