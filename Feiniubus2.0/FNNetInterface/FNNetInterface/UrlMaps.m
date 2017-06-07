//
//  UrlMaps.m
//  FNNetInterface
//
//  Created by tianbo on 16/1/18.
//  Copyright © 2016年 feiniu.com. All rights reserved.
//

#import "UrlMaps.h"
#import <FNCommon/NetConstants.h>

//#define REQUESTURL(X) [NSString stringWithFormat:@"%@%@", KServerAddr, X]
//#define REQUESTURL2(A, B) [NSString stringWithFormat:@"%@%@", A, B]

#define INT2STRING(X)   [NSString stringWithFormat:@"%d", X]

@interface UrlMaps ()

@property (nonatomic, copy) NSDictionary *urlMaps;
@end

@implementation UrlMaps


+(UrlMaps*)sharedInstance
{
    static UrlMaps *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        //[self old];
        [self initUrlMaps];
    }
    return self;
}


-(void)resetUrlMaps:(NSDictionary*)dict
{
    _urlMaps = dict;
}

-(void)initUrlMaps
{
//    _urlMaps = @{@(EmRequestType_Login):                  REQUESTURL(UNI_Login),
//                 @(EmRequestType_GetVerifyCode):          REQUESTURL(UNI_VerifyCode),
//                 @(EmRequestType_GetUserInfo):            REQUESTURL(UNI_UserInfo),
//                 @(EmRequestType_SetUserInfo):            REQUESTURL(UNI_UserInfo),
//                 @(EmRequestType_GetCoupons):             REQUESTURL(UNI_GetCounpos),
//                 @(EmRequestType_CarouselIndex):          REQUESTURL(UNI_CarouselIndex),
//                 @(EmRequestType_ShareContent):           REQUESTURL(UNI_ShareContent),
//                 @(EmRequestType_CheckToken):             REQUESTURL(UNI_CheckToken),
//                 
//                 //接送车
//                 @(EmRequestType_GetCommonAddress):       REQUESTURL(UNI_GetCommonAddress),
//                 @(EmRequestType_GetDateRange):           REQUESTURL(UNI_GetDateRange),
//                 @(EmRequestType_GetPrice):               REQUESTURL(UNI_GetPrice),
//                 @(EmRequestType_Feedback):               REQUESTURL(UNI_Feedback),
//                 @(EmRequestType_GetFerryBusLocation):    REQUESTURL2(KServerLocationAddr, UNI_GetFerryBusLocation),
//                 @(EmRequestType_GetDedicatedLocation):   REQUESTURL2(KServerLocationAddr, UNI_GetDedicatedLocation),
//                 @(EmRequestType_GetFence):               REQUESTURL2(KServerLocationAddr, UNI_GetFence),
//                 @(EmRequestType_PostDedicatedOrder):     REQUESTURL(UNI_DedicatedOrder),
//                 @(EmRequestType_GetDedicatedOrder):      REQUESTURL(UNI_DedicatedOrder),
//                 @(EmRequestType_GetDedicatedList):       REQUESTURL(UNI_DedicatedOrder),
//                 @(EmRequestType_GetDedicatedAppraise):   REQUESTURL(UNI_DedicatedAppraise),
//                 @(EmRequestType_PostDedicatedAppraise):  REQUESTURL(UNI_DedicatedAppraise),
//                 @(EmRequestType_DeleteDedicatedOrder):   REQUESTURL(UNI_DedicatedOrder),
//                 @(EmRequestType_PostCancelReason):       REQUESTURL(UNI_DedicatedCancelReason),
//                 @(EmRequestType_GetDedicateRefundPace):  REQUESTURL(UNI_DedicatedRefundPace),
//                 @(EmRequestType_GetOrderState):          REQUESTURL(UNI_DedicatedOrderState),
//                 
//                 
//                 //订车票块
//                 @(EmRequestType_StartCity):              REQUESTURL(UNI_StartCity),
//                 @(EmRequestType_DestinationCity):        REQUESTURL(UNI_DestinationCity),
//                 @(EmRequestType_DateRange):              REQUESTURL(UNI_DateRange),
//                 @(EmRequestType_BookingTickets):         REQUESTURL(UNI_BookingTickets),
//                 @(EmRequestType_PassengerHistory):       REQUESTURL(UNI_PassengerHistory),
//                 @(EmRequestType_AddPassengerHistory):    REQUESTURL(UNI_PassengerHistory),
//                 @(EmRequestType_DeletePassengerHistory): REQUESTURL(UNI_PassengerHistory),
//                 @(EmRequestType_TicketOrderCreate):      REQUESTURL(UNI_Order),
//                 @(EmRequestType_TicketOrderList):        REQUESTURL(UNI_Order),
//                 @(EmRequestType_TicketOrderDetail):      REQUESTURL(UNI_Order),
//                 @(EmRequestType_TicketRefund):           REQUESTURL(UNI_TicketCancel),
//                 @(EmRequestType_TicketCancel):           REQUESTURL(UNI_TicketCancel),
//                 @(EmRequestType_TicketOrderTickets):     REQUESTURL(UNI_TicketInOrder),
//                 @(EmRequestType_TicketRefundRule):       REQUESTURL(UNI_TicketRefundRule),
//                 @(EmRequestType_TicketRefundPace):       REQUESTURL(UNI_TicketRefundPace),
//                 
//                 @(EmRequestType_DedicateOrderRemove):           REQUESTURL(UNI_OrderDelete),
//                 @(EmRequestType_TicketOrderRemove):            REQUESTURL(UNI_OrderDelete),
//                 
//                 //支付模块
//                 @(EmRequestType_PaymentCreate):          REQUESTURL(UNI_PaymentCreate),
//                 @(EmRequestType_PaymentCharge):          REQUESTURL(UNI_PaymentCharge),
//                 @(EmRequestType_PaymentResult):          REQUESTURL(UNI_PaymentResult),
//                };
}

-(NSString*)urlWithTypeNew:(int)type
{
    return _urlMaps[@(type)];
}
@end
