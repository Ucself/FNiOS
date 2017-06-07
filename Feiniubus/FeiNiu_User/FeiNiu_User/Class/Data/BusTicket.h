//
//  BusTicket.h
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/10.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import <FNDataModule/FNDataModule.h>

typedef NS_ENUM(NSInteger, TicketState) {
    TicketStatePrepare = 1,     // 等待确认
    TicketStateInvalid = 2,     // 未生效
    TicketStateValid = 3,       // 有效
    TicketStateRefund = 4,      // 退票
    TicketStateUsed = 5,        // 已使用
    TicketStateCancel = 6,      // 取消
};

typedef NS_ENUM(NSInteger, TicketType) {
    TicketTypeAdult = 1,        // 成人票
    TicketTypeChild,            // 儿童票
//    TicketTypeHalf,             // 半票
};
@interface BusTicket : BaseModel
@property (nonatomic, strong) NSString *ticketId;
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, assign) TicketState state;
@property (nonatomic, assign) TicketType type;
@property (nonatomic, strong, readonly) UIImage *qrImage;
- (void)qrImageStartBlock:(void (^)(void))start complete:(void (^)(UIImage *qrImage))completion;

@end
