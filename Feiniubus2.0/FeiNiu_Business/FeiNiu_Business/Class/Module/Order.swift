//
//  Order.swift
//  FeiNiu_Business
//
//  Created by tianbo on 16/9/7.
//  Copyright © 2016年 tianbo. All rights reserved.
//

import UIKit

class Order: NSObject {

    //订单状态
    enum EmOrderStatus:NSInteger {
        case EmOrderStatus_Finished  = 0
        case EmOrderStatus_Failed
        case EmOrderStatus_Cancelled
        case EmOrderStatus_WaitPay
        case EmOrderStatus_WaitCar
        case EmOrderStatus_Ongoing
        case EmOrderStatus_ReserveSuccess
    }
    
    
    var id:NSString?
}
