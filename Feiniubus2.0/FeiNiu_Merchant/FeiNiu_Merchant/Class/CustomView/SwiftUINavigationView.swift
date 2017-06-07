//
//  SwiftUINavigationView.swift
//  FeiNiu_Merchant
//
//  Created by tianbo on 16/9/9.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

protocol SwiftUINavigationViewDelegate {
    func navViewClickBack()
    func navViewClickRight()
}

@IBDesignable
class SwiftUINavigationView: UIView {
    
    var buttonWidth:CGFloat = 40
    
    var labelTitle:UILabel?
    var btnLeft:UIButton?
    var btnRight:UIButton?
    var line:UIView?
    
    var delegate:SwiftUINavigationViewDelegate?

    @IBInspectable var title:String? {
        didSet {
            labelTitle?.text = title
        }
    }
    
    @IBInspectable var leftImage:UIImage? {
        didSet{
            btnLeft?.setImage(leftImage, for: .normal)
        }
    }
    
    @IBInspectable var rightImage:UIImage? {
        didSet {
            btnRight?.setImage(rightImage, for: .normal)
        }
    }
    
    @IBInspectable var rightTitle:String? {
        didSet {
            if let title:String = rightTitle , title.characters.count != 0 {
                btnRight?.setTitle(title, for: .normal)
                
                btnRight?.isUserInteractionEnabled = true
                
                let size = title.boundingRect(with: CGSize(width: 80, height: 30), options: NSStringDrawingOptions.usesFontLeading, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)], context: nil)
                
                buttonWidth = size.width + 1
                setNeedsLayout()
            }
            else {
                btnRight?.isUserInteractionEnabled = false
                btnRight?.setTitle("", for: .normal)
            }
        }
    }
    
    @IBInspectable var rightTitleColor:UIColor? {
        didSet {
            btnRight?.setTitleColor(rightTitleColor, for: .normal)
        }
    }
    

    
    
    
    //MARK: -
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initControls()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        initControls()
    }
    
    func initControls() {
        labelTitle = UILabel()
        labelTitle?.textColor = UIColor_DefOrange
        labelTitle?.font = UIFont.boldSystemFont(ofSize:17)
        labelTitle?.textAlignment = .center
        labelTitle?.backgroundColor = UIColor.clear
        self.addSubview(labelTitle!)
        
        btnLeft = UIButton(type: .custom)
        btnLeft?.contentMode = .scaleAspectFit
        btnLeft?.addTarget(self, action: #selector(btnLeftClick(sender:)), for: .touchUpInside)
        self.addSubview(btnLeft!)
        
        btnRight = UIButton(type: .custom)
        btnRight?.contentMode = .scaleAspectFit
        btnRight?.titleLabel?.font = UIFont.boldSystemFont(ofSize:14)
        btnRight?.addTarget(self, action: #selector(btnRightClick(sender:)), for: .touchUpInside)
        self.addSubview(btnRight!)
        
        line = UIView()
        line?.backgroundColor = UIColor.lightGray
        self.addSubview(line!)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        labelTitle?.frame = CGRect(x: 60, y: 20, width: self.bounds.size.width-120, height: self.bounds.size.height-20)
        
        btnLeft?.frame = CGRect(x: 10, y: 27, width: 50, height: 30)
        
        btnRight?.frame = CGRect(x: self.bounds.size.width-buttonWidth-10, y: 27, width: buttonWidth, height: 30)
        
        line?.frame = CGRect(x: 0, y: self.bounds.size.height-0.5, width: self.bounds.size.width, height: 0.5)
    }
    
    func btnLeftClick(sender:AnyObject) -> Void {
        delegate?.navViewClickBack()
    }
    
    func btnRightClick(sender:AnyObject) -> Void {
        delegate?.navViewClickRight()
    }
}
