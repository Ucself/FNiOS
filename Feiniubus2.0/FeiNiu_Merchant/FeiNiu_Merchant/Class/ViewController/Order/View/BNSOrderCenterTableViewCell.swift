//
//  BNSOrderCenterTableViewCell.swift
//  FeiNiu_Business
//
//  Created by lbj@feiniubus.com on 16/9/6.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class BNSOrderCenterTableViewCell: UITableViewCell {

    @IBOutlet weak var people_number: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var order_state: UILabel!
    @IBOutlet weak var flight_number: UILabel!
    @IBOutlet weak var city_name : UILabel!
    @IBOutlet weak var use_time: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
