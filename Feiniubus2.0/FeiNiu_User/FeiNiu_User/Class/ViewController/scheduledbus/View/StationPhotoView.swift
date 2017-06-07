//
//  StationPhotoView.swift
//  FeiNiu_User
//
//  Created by tianbo on 2017/1/6.
//  Copyright © 2017年 tianbo. All rights reserved.
//

import UIKit

class StationPhotoView: UIView {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDetail: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    public func showIn(_ view:UIView) {
        view.addSubview(self)
//        self.snp.makeConstraints { (make) in
//            make.edges.equalTo(view.snp.edges)
//        }
        self.mas_makeConstraints { (make) in
            make?.edges.equalTo()(view)
        }
        
    }

    @IBAction func tap(_ sender: Any) {
        self.removeFromSuperview()
    }
    
}
