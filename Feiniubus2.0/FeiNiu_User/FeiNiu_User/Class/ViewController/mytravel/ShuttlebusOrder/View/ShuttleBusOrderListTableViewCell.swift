//
//  ShuttleBusOrderListTableViewCell.swift
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/11/22.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit
import FNUIView

class ShuttleBusOrderListTableViewCell: SWTableViewCell {

    @IBOutlet weak var useTimeLabel: UILabel!
    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var startOriginLabel: UILabel!
    @IBOutlet weak var endOriginLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    //设置界面显示
    func setInterface(shuttleOrderList:ShuttleOrderObj) -> Void {
        //时间
        let useDate:Date = DateUtils.string(toDate: shuttleOrderList.use_time!)
        self.useTimeLabel.text = "\(DateUtils.formatDate(useDate, format: "yyyy-MM-dd HH:mm")!)(\(shuttleOrderList.people_number)人拼车)"
        //状态
        if let orderState:ShuttleOrderState = ShuttleOrderState(rawValue: shuttleOrderList.order_state) {
            self.orderStatusLabel.text = " \(orderState.toString()) "
            self.orderStatusLabel.backgroundColor = orderState.toColor()
        }
        
        //出发地
        self.startOriginLabel.text = shuttleOrderList.starting
        //目的地
        self.endOriginLabel.text = shuttleOrderList.destination

    }
    
}
