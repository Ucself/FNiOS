//
//  UrlMaps.m
//  FNNetInterface
//
//  Created by tianbo on 16/1/18.
//  Copyright © 2016年 feiniu.com. All rights reserved.
//

#import "UrlMaps.h"
#import <FNCommon/Constants.h>

#define REQUESTURL(X) [NSString stringWithFormat:@"%@%@", KServerAddr, X]
#define REQUESTURL2(A, B) [NSString stringWithFormat:@"%@%@", A, B]

@interface UrlMaps ()


@property (nonatomic, strong) NSDictionary *urlDict;
@end

@implementation UrlMaps

-(instancetype)init
{
    self = [super init];
    if (self) {
        _urlDict = @{@(KRequestType_Login):                  REQUESTURL(KUrl_Login),
                     @(KRequestType_Register):               REQUESTURL(KUrl_Register),
                     @(KRequestType_Password):               REQUESTURL(KUrl_Password),
                     @(KRequestType_GetVerifyCode):          REQUESTURL(KUrl_VerifyCode),
                     @(KRequestType_GetCache):               REQUESTURL(KUrl_Cache),
                     @(KRequestType_GetBusinessScope):       REQUESTURL(KUrl_BusinessScope),
                     @(KRequestType_GetVehicleLevel):        REQUESTURL(KUrl_VehicleLevel),
                     @(KRequestType_GetVehicleType):         REQUESTURL(KUrl_VehicleType),
                     @(KRequestType_GetFuelType):            REQUESTURL(KUrl_FuelType),
                     @(FNUserRequestType_GetUserInfo):       REQUESTURL(KUrl_MemberInfo),
                     @(FNUserRequestType_SetUserInfo):       REQUESTURL(KUrl_MemberInfo),
                     
                     
                     //用户端类型
                     @(KRequestType_sharingvehicleorder):     REQUESTURL(Kurl_sharingvehicleprice),
                     @(KRequestType_sharingvehicleorderpost): REQUESTURL(Kurl_sharingvehicleprice),
                     @(KRequestType_sharingvehicleorderget):  REQUESTURL(Kurl_sharingvehicleorder),
                     @(KRequestType_rentvehicleprice):        REQUESTURL(Kurl_rentvehicleprice),
                     @(KRequestType_submitrentvehicleorder):  REQUESTURL(Kurl_charterOrder),
                     @(KRequestType_sharinvehicleorder):      REQUESTURL(Kurl_submitrentvehicleorder),
                     @(KRequestType_sharinvehicleorderrob):   REQUESTURL(Kurl_sharinvehicleorderrob),
                     @(KRequestType_cancelorder):             REQUESTURL(Kurl_cancelorder),
                     @(KRequestType_coupons):                 REQUESTURL(Kurl_coupons),
                     @(KRequestType_paysubmit):               REQUESTURL(Kurl_paysubmit),
                     @(KRequestType_membermessage):           REQUESTURL(Kurl_membermessage),
                     @(KRequestType_htcorder):                REQUESTURL(Kurl_htcorder),
                     @(KRequestType_complaints):              REQUESTURL(Kurl_complaints),
                     @(KRequestType_advice):                  REQUESTURL(Kurl_cadvice),
                     @(KRequestType_invoice):                 REQUESTURL(Kurl_invoice),
                     @(KRequestType_invoiceprice):            REQUESTURL(Kurl_invoiceprice),
                     @(KRequestType_memberexpmessage):        REQUESTURL(Kurl_memberexpmessage),
                     //整理控制器接口
                     @(KRequestType_FerryOrder):                    REQUESTURL(Kurl_FerryOrder),
                     @(KRequestType_FerryOrderCheck):               REQUESTURL(Kurl_FerryOrderCheck),
                     @(KRequestType_FerryReviewsGet):               REQUESTURL(Kurl_FerryReviews),
                     @(KRequestType_FerryReviewsPost):              REQUESTURL(Kurl_FerryReviews),
                     @(KRequestType_FerryLocationGet):              REQUESTURL2(KLocationAddr, Kurl_FerryLocation),
                     @(KRequestType_FerryLocationPost):             REQUESTURL2(KLocationAddr, Kurl_FerryLocation),
                     @(KRequestType_FerryOrder_DelectedOrder):      REQUESTURL(Kurl_FerryOrder),
                     @(FNUserRequestType_CityCarpoolOrderList):     REQUESTURL(Kurl_FerryOrder),
                     @(FNUserRequestType_CityCarpoolOrderListItemWithIndex): REQUESTURL(Kurl_FerryOrder),
                     @(FNUserRequestType_CharterOrderMain):                  REQUESTURL(Kurl_CharteOrderMain),
                     @(FNUserRequestType_CharterOrderListItemWithIndex):     REQUESTURL(Kurl_CharteOrderMain),
                     @(FNUserRequestType_Login):                    REQUESTURL(KUrl_Login),
                     @(FNUserRequestType_CharterOrderDetail):       REQUESTURL(Kurl_CharterOrderMainDetaile),
                     @(FNUserRequestType_CharterSubOrderDetail):    REQUESTURL(Kurl_CharterOrderSubDetaile),
                     @(FNUserRequestType_CharterOrderCancel):       REQUESTURL(Kurl_charterOrder),
                     @(FNUserRequestType_CharterOrderContinue):     REQUESTURL(Kurl_charterOrder),
                     @(FNUserRequestType_CharterOrderDelete):       REQUESTURL(Kurl_charterOrder),
                     @(FNUserRequestType_CharterOrderRefundPrice):  REQUESTURL(Kurl_CharterOrderRefundPrice),
                     @(FNUserRequestType_CharterOrderReviewsList):  REQUESTURL(Kurl_Reviews),
                     @(FNUserRequestType_GetVIPPrice):              REQUESTURL(Kurl_CharterOrderPrice),
                     @(FNUserRequestType_CarpoolOrderList):         REQUESTURL(Kurl_CarpoolOrder),
                     @(FNUserRequestType_CarpoolOrderListItemWithIndex): REQUESTURL(Kurl_CarpoolOrder),
                     @(FNUserRequestType_CarpoolStartingCitys):     REQUESTURL(Kurl_CarpoolStartingCitys),
                     @(FNUserRequestType_CarpoolDestinationCitys):     REQUESTURL(Kurl_CarpoolDestinationCitys),
                     @(FNUserRequestType_CarpoolOrderDetail):            REQUESTURL(Kurl_CarpoolOrder),
                     @(FNUserRequestType_CarpoolOrderCancel):            REQUESTURL(Kurl_CarpoolOrder),
                     @(FNUserRequestType_CarpoolOrderTickets):           REQUESTURL(Kurl_CarpoolOrderTickets),
                     @(FNUserRequestType_CarpoolRefundCharge):           REQUESTURL(Kurl_CarpoolOrderRefundPrice),
                     @(FNUserRequestType_Fence):                REQUESTURL2(KLocationAddr, Kurl_Fence),
                     @(FNUserRequestType_Coupons):              REQUESTURL(Kurl_coupons),
                     @(FNUserRequestType_Invoince):             REQUESTURL(Kurl_Reviews),
                     @(FNUserRequestType_Rating):               REQUESTURL(Kurl_Reviews),
                     @(FNUserRequestType_PayOfflineTransfer):   REQUESTURL(Kurl_OfflineTransfer),
                     @(FNUserRequestType_GetShareContent):      REQUESTURL(Kurl_Share),
                     @(RequestType_ComputePrice):               REQUESTURL(Kurl_CarpoolOrderPrice),
                     @(RequestType_SubmitOrder):                REQUESTURL(Kurl_CarpoolOrder),
                     @(RequestType_checkOrderSuccess):          REQUESTURL(Kurl_CarpoolOrderCheck),
                     @(RequestType_CarpoolBusShift):            REQUESTURL(Kurl_CarpoolBusShift),
                     @(RequestType_SubmitCharteredOrder):       REQUESTURL(Kurl_charterOrder),
                     @(RequestType_CharterOrderTime):           REQUESTURL(Kurl_CharterOrderTime),
                     @(FNUserRequestType_GetCarouselindex):     REQUESTURL(Kurl_Carouselindex),
                     @(FNUserRequestType_HideOrder):            REQUESTURL(Kurl_HideOrder)
                     
//                     //车主端
//                     @(KRequestType_ownersstatistical): REQUESTURL(<#B#>),
//                     @(KRequestType_getvehicle): REQUESTURL(<#B#>),
//                     @(KRequestType_postvehicle): REQUESTURL(<#B#>),
//                     @(KRequestType_getvehiclefree): REQUESTURL(<#B#>),
//                     @(KRequestType_ownersdriver): REQUESTURL(<#B#>),
//                     @(KRequestType_getDriver): REQUESTURL(<#B#>),
//                     @(KRequestType_postDriver): REQUESTURL(<#B#>),
//                     @(KRequestType_getdriverfree): REQUESTURL(<#B#>),
//                     @(KRequestType_getCharterOrderGrab): REQUESTURL(<#B#>),
//                     @(KRequestType_postCharterOrderGrab): REQUESTURL(<#B#>),
//                     @(KRequestType_getCharterGrab): REQUESTURL(<#B#>),
//                     @(KRequestType_ownerstask): REQUESTURL(<#B#>),
//                     @(KRequestType_charterOrderOwnersTask): REQUESTURL(<#B#>),
//                     @(KRequestType_ownerstaskdetails): REQUESTURL(<#B#>),
//                     @(KRequestType_roborderget): REQUESTURL(<#B#>),
//                     @(KRequestType_roborderpost): REQUESTURL(<#B#>),
//                     @(KRequestType_company): REQUESTURL(<#B#>),
//                     @(KRequestType_scope): REQUESTURL(<#B#>),
//                     @(KRequestType_auditreason): REQUESTURL(<#B#>),
//                     @(KRequestType_startTask): REQUESTURL(<#B#>),
//                     @(KRequestType_taskReason): REQUESTURL(<#B#>),
//                     @(KRequestType_taskstatistics): REQUESTURL(<#B#>),
//                     @(KRequestType_driverdetaile): REQUESTURL(<#B#>),
//                     @(KRequestType_ownersStatistics): REQUESTURL(<#B#>),
//                     @(KRequestType_vehicleStatistics): REQUESTURL(<#B#>),
//                     @(KRequestType_vehicleStatus): REQUESTURL(<#B#>),
//                     @(KRequestType_vehiclePrice): REQUESTURL(<#B#>),
//                     @(KRequestType_charterOrderVehicleTask): REQUESTURL(<#B#>),
//                     @(KRequestType_driverAuditReason): REQUESTURL(<#B#>),
//                     
//                     //司机端
//                     @(KRequestType_driverStatistics): REQUESTURL(<#B#>),
//                     @(KRequestType_drivertask): REQUESTURL(<#B#>),
//                     @(KRequestType_drivertaskdetails): REQUESTURL(<#B#>),
//                     @(KRequestType_orderpassengers): REQUESTURL(<#B#>),
//                     @(KRequestType_ticketget): REQUESTURL(<#B#>),
//                     @(KRequestType_ticketpost): REQUESTURL(<#B#>),
//                     @(KRequestType_charterOrderDriverTask): REQUESTURL(<#B#>),
//                     @(KRequestType_driverStartTask): REQUESTURL(<#B#>),
//                     @(KRequestType_driverEndTask): REQUESTURL(<#B#>),
//                     @(KRequestType_driverGetCarpoolingTask): REQUESTURL(<#B#>),
//                     @(KRequestType_driverCarpoolingTask): REQUESTURL(<#B#>),
//                     @(KRequestType_carpoolOrdeMember): REQUESTURL(<#B#>),
//                     @(KRequestType_carpoolrderDriverTask): REQUESTURL(<#B#>),
//                     @(KRequestType_postCharterLocation): REQUESTURL(<#B#>),
//                     @(KRequestType_getCharterLocation): REQUESTURL(<#B#>),
//                     @(KRequestType_postCarpoolLocation): REQUESTURL(<#B#>),
//                     @(KRequestType_getCarpoolLocation): REQUESTURL(<#B#>)
                     };
    }
    return self;
}

-(NSString*)urlWithType:(int)type
{
    return _urlDict[@(type)];
    return nil;
}
@end
