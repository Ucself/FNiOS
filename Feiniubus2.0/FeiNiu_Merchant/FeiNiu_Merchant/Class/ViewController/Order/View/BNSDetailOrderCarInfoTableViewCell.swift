//
//  BNSDetailOrderCarInfoTableViewCell.swift
//  FeiNiu_Merchant
//
//  Created by lbj@feiniubus.com on 16/9/19.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class BNSDetailOrderCarInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var license: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phone: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
