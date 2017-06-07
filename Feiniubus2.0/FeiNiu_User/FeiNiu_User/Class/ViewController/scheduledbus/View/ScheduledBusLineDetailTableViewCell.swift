//
//  ScheduledBusLineDetailTableViewCell.swift
//  FeiNiu_User
//
//  Created by tianbo on 2016/12/12.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class ScheduledBusLineDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var lablelStation: UILabel!
    
    @IBOutlet weak var leftLine: UIView!
    @IBOutlet weak var rightLine: UIView!
    @IBOutlet weak var imgDot: UIImageView!
    
    @IBOutlet weak var upLineView: UIView!
    @IBOutlet weak var underLineView: UIView!
    
    @IBOutlet weak var dotTopCons: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //设置界面
    func setWithStationInfo(tempStationInfo:StationInfo?,isOffStation:Bool){
        
        if tempStationInfo == nil {
            self.imgDot.image = UIImage.init(named: "icon_arrow")
            self.labelTime.isHidden = true
            self.lablelStation.isHidden = true
        }
        else{
            self.imgDot.image = UIImage.init(named: "icon_start_or_end_20*20")
            self.labelTime.isHidden = false
            self.lablelStation.isHidden = false
            
        }
        //设置显示值
        if isOffStation {
            self.labelTime.text = "预计" + (tempStationInfo?.timeFormat(timeString: tempStationInfo?.time))!
        }
        else{
            self.labelTime.text = tempStationInfo?.timeFormat(timeString: tempStationInfo?.time)
        }
        self.lablelStation.text = tempStationInfo?.name
    }
    
    //竖线显示方法
    func setVerticalLine(type:Int) {
        if type == 0 {
            self.upLineView.isHidden = true
            self.underLineView.isHidden = false
        }
        else if type == 1 {
            self.upLineView.isHidden = false
            self.underLineView.isHidden = true
        }
        else if type == 2 {
            self.upLineView.isHidden = false
            self.underLineView.isHidden = false
        }
    }
    
    //横线显示方法
    func setHorizontalLine(type:Int) {
        if type == 0 {
            leftLine.isHidden = true
            rightLine.isHidden = true
        }
        else if type == 1 {
            leftLine.isHidden = false
            rightLine.isHidden = false
        }
    }
}
