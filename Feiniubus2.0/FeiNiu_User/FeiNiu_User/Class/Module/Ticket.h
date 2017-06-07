//
//  Ticket.h
//  FeiNiu_User
//
//  Created by tianbo on 16/3/24.
//  Copyright © 2016年 tianbo. All rights reserved.
//
// 车票数据模型

#import <FNDataModule/FNDataModule.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(int, TicketStatus) {
    EmTicketStatus_Invalid = 2,
    EmTicketStatus_NotTake = 3,         //未取票
    EmTicketStatus_HasTake = 5,         //已取票
    EmTicketStatus_refunding = 14,      //退票中
    EmTicketStatus_Redunnd   = 4,       //已退票
};

typedef NS_ENUM(int, TicketType) {
    EmTicketType_Standard   = 1,
    EmTicketType_Half       = 3,
};

@interface Ticket : BaseModel


@property (nonatomic, strong) NSString *ticketId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userIdCardNumber;        //身份证
@property (nonatomic, strong) NSString *serialNumber;      //车票编码
@property (nonatomic, assign) int       ticketState;       //状态:  未生效2 未取票3 已取票5 退票中14 已退票4
@property (nonatomic, assign) int       ticketType;        //类型:  成人票:1 半票3

@property (nonatomic, strong, readonly) UIImage *qrImage;


@property (nonatomic, assign) BOOL flag;    //页面操作标记

- (void)qrImageStartBlock:(void (^)(void))start complete:(void (^)(UIImage *qrImage))completion;
@end
