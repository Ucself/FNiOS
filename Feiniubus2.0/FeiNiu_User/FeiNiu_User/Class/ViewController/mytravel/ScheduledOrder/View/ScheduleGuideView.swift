//
//  ScheduleTipView.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 17/1/22.
//  Copyright © 2017年 tianbo. All rights reserved.
//

import UIKit

class ScheduleGuideView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var parentView:UIView?
    
    var showTipView:Int = 1
    
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    
    @IBOutlet weak var image3top: NSLayoutConstraint!
    
    @IBOutlet weak var image4Top: NSLayoutConstraint!
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    static func initFromXib() -> ScheduleGuideView {
        let guideView:ScheduleGuideView = Bundle.main.loadNibNamed("ScheduleGuideView", owner: nil, options: nil)?.first as! ScheduleGuideView
        
        return guideView
    }
    
    func showInView(view:UIView) {
        
        if deviceHeight < 667 {
            //iphone 5
            self.image3top.constant = (318.0 - 27.0)
            self.image4Top.constant = 135 + 5
        }
        else if deviceHeight > 667 {
            //iPhone 6p
            self.image3top.constant = (318.0 + 20.0)
            self.image4Top.constant = 135
        }
        
        parentView = view
        //添加到界面
        view.addSubview(self)
//        self.snp.makeConstraints { (maker) in
//            maker.edges.equalTo(view)
//        }
        self.mas_makeConstraints { (maker) in
            maker!.edges.equalTo()(view)
        }
        self.setShowView(fromIndex: showTipView)
    }
    
    func cancelView(){
        self.removeFromSuperview()
    }
    
    
    func setShowView(fromIndex:Int) {
        
        self.image1.isHidden = true
        self.image2.isHidden = true
        self.image3.isHidden = true
        self.image4.isHidden = true
        
        switch fromIndex {
        case 1:
            self.image1.isHidden = false
        case 2:
            self.image2.isHidden = false
        case 3:
            self.image3.isHidden = false
        case 4:
            self.image4.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func viewClick(_ sender: Any) {
        
        switch showTipView {
        case 1,2:
            showTipView = showTipView + 1
            self.setShowView(fromIndex: showTipView)
        case 3:
            self.cancelView()
        case 4:
            self.cancelView()
        default:
            break
        }
    }
    
    
}
