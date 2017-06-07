//
//  BNSDetailOrderPassengerTableViewCell.swift
//  FeiNiu_Merchant
//
//  Created by lbj@feiniubus.com on 16/9/19.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class BNSDetailOrderPassengerTableViewCell: UITableViewCell {

    @IBOutlet weak var people_number: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var _description: UILabel!
    @IBOutlet weak var address: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
