//
//  DriverCarpoolOrdeMember.h
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/10/8.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriverCarpoolOrdeMember : NSObject

//乘客id
@property (nonatomic,strong) NSString* memberId;
//乘客名称
@property (nonatomic,strong) NSString* memberName;
//乘客电话
@property (nonatomic,strong) NSString* memberPhone;
//订单id
@property (nonatomic,strong) NSString* orderId;
//票数
@property (nonatomic,assign) int ticketsAmount;
//已检票数
@property (nonatomic,assign) int checkedicketsAmount;
//检票状态
@property (nonatomic,assign) int ticketsStatus;
//乘客头像
@property (nonatomic,strong) NSString* memberAvatar;

-(id)initWithDictionary:(NSDictionary*)dictionary;


@end
