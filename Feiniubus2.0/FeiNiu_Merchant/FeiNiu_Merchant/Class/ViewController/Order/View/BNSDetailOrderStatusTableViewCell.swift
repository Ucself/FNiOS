//
//  BNSDetailOrderStatusTableViewCell.swift
//  FeiNiu_Merchant
//
//  Created by lbj@feiniubus.com on 16/9/19.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class BNSDetailOrderStatusTableViewCell: UITableViewCell {

    @IBOutlet weak var order_typeName: UILabel!
    @IBOutlet weak var use_time: UILabel!
    @IBOutlet weak var flight_numberName: UILabel!
    @IBOutlet weak var flight_number: UILabel!
    @IBOutlet weak var flight_time: UILabel!
    @IBOutlet weak var order_state: UILabel!
    @IBOutlet weak var stateAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
