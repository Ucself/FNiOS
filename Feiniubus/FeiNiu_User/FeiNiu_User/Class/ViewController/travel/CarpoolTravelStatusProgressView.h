//
//  CarpoolTravelStatusProgressView.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/4.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, OrderState){
    OrderStateSystem,
    OrderStateWaitingForPay,
    OrderStateIsPay,
    OrderStateStartTravel,
    OrderStateEndTravel,
};



@interface CarpoolTravelStatusProgressView : UIView
@property (nonatomic, assign) NSInteger state;

@end
