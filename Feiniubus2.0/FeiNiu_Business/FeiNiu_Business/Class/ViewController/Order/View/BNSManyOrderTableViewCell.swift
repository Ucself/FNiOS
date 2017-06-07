//
//  BNSManyOrderTableViewCell.swift
//  FeiNiu_Business
//
//  Created by lbj@feiniubus.com on 16/9/6.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class BNSManyOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var labelNum: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelSrartAddr: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
