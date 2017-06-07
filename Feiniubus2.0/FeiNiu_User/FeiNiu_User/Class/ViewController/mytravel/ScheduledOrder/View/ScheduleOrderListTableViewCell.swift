//
//  ShuttleBusOrderListTableViewCell.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/11/22.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNUIView

class ScheduleOrderListTableViewCell: SWTableViewCell {

    @IBOutlet weak var useTimeLabel: UILabel!
    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var startOriginLabel: UILabel!
    @IBOutlet weak var endOriginLabel: UILabel!
    @IBOutlet weak var lineInforLabel: UILabel!
    
    @IBOutlet weak var onLabel: UILabel!
    @IBOutlet weak var offLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    //设置界面显示
    func setInterface(order:CommuteOrderObj) -> Void {
        
        //self.lineInforLabel.text = "\(order.start_station_name!)--\(order.destination_station_name!)"
        self.onLabel.text = order.start_station_name ?? ""
        self.offLabel.text = order.destination_station_name ?? ""
        //时间
        let useDate:Date = DateUtils.string(toDate: order.on_station_time!)
        self.useTimeLabel.text = "\(DateUtils.formatDate(useDate, format: "yyyy-MM-dd HH:mm")!)"
        //状态
        self.orderStatusLabel.text = CommuteOrderState.toStringNew(enumName:order.order_state)
        self.orderStatusLabel.backgroundColor = CommuteOrderState.toColor(enumName:order.order_state)
        //出发地
        let onDate:Date = DateUtils.string(toDate: order.on_station_time!)
        self.startOriginLabel.text = "\(order.on_station_name!) (\(DateUtils.formatDate(onDate, format: "HH:mm")!))"
        //目的地
        let offDate:Date = DateUtils.string(toDate: order.off_station_time!)
        self.endOriginLabel.text = "\(order.off_station_name!) (\(DateUtils.formatDate(offDate, format: "HH:mm")!))"
        
        //线路信息
    }
    
}
