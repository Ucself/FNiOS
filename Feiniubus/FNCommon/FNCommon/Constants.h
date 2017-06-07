//
//  Constants.h
//  XinRanApp
//
//  Created by tianbo on 14-12-5.
//  Copyright (c) 2014年 feiniu.com All rights reserved.
//
// 54.223.236.158
//  通信协议基础定义

#ifndef XinRanApp_Constants_h
#define XinRanApp_Constants_h

#pragma mark- url 定义

#ifdef DEBUG    // 调试阶段
#define KTestServer
#else           // 发布阶段
#define KFinalServer
#endif

//#define KTestServer
//#define KFinalServer
//#define KQAServer

//测试环境地址
#ifdef KTestServer
#define KLocationAddr              @"http://dev.feiniubus.com:8010/api/v1/"
#define KServerAddr                @"http://dev.feiniubus.com:8000/api/v1/"
#define KPayServerAddr             @"http://dev.feiniubus.com:8020/api/v1/"
#define KAboutServerAddr           @"http://about.feiniubus.com/"
#define KImageDonwloadAddr         @"http://dev.feiniubus.com:8000/api/v1/Resources?url="
#define KTopLevelDomainAddr        @"http://www.feiniubus.com/"
#endif

//QAserver
#ifdef KQAServer
#define KLocationAddr              @"http://location.feiniubus.com:8000/api/v1/"
#define KServerAddr                @"http://172.16.1.135:8001/api/v1/"
#define KImageDonwloadAddr         @"http://172.16.1.135:8001"
#endif

//正式地址
#ifdef KFinalServer
#define KLocationAddr              @"http://location.feiniubus.com:8000/api/v1/"
#define KServerAddr                @"http://api.feiniubus.com:8000/api/v1/"
#define KPayServerAddr             @"http://pay.feiniubus.com:8000/api/v1/"
#define KAboutServerAddr           @"http://about.feiniubus.com/"
#define KImageDonwloadAddr         @"http://api.feiniubus.com:8000/api/v1/Resources?url="
#define KTopLevelDomainAddr        @"http://www.feiniubus.com/"
#endif




/******************************************************
 *  v1.0 接口
 ******************************************************/

#define Kurl_UploadImage           @"resources"

#define KUrl_Login                 @"account"
#define KUrl_VerifyCode            @"verificationcode"
#define KUrl_Register              @"register"
#define KUrl_Password              @"lostpassword"
#define KUrl_Cache                 @"cache"
#define KUrl_BusinessScope         @"businessScope"
#define KUrl_VehicleLevel          @"vehicleLevel"
#define KUrl_VehicleType           @"vehicleType"
#define KUrl_FuelType              @"fuelType"
#define KUrl_MemberInfo            @"memberinfo"

///////////////用户端接口///////////////
//拼车价格计算
#define Kurl_sharingvehicleprice         @"sharingvehicleprice"
//POST 拼车发布    GET当前拼车订单
#define Kurl_sharingvehicleorder         @"sharingvehicleorder"
//包车价格计算
#define Kurl_rentvehicleprice            @"rentvehicleprice"
//包车发布
#define Kurl_submitrentvehicleorder      @"submitrentvehicleorder"
//未有车包车订单
#define Kurl_sharinvehicleorder          @"sharinvehicleorder"
//已有车包车订单
#define Kurl_sharinvehicleorderrob       @"sharinvehicleorderrob"
//取消包车订单
#define Kurl_cancelorder                 @"cancelorder"
//取优惠券
#define Kurl_coupons                     @"coupons"
//支付
#define Kurl_paysubmit                   @"paysubmit"
//用户消息    GET获取  DELETE删除
#define Kurl_membermessage               @"membermessage"
//行程列表
#define Kurl_htcorder                    @"htcorder"
//用户基本信息   GET获取  PUT修改
#define Kurl_memberinfo                  @"memberinfo"
//用户投诉
#define Kurl_complaints                  @"complaints"
//用户建议
#define Kurl_cadvice                     @"cadvice"
//发票
#define Kurl_invoice                     @"invoice"
//发票额度
#define Kurl_invoiceprice                @"invoiceprice"
//用户其它信息
#define Kurl_memberexpmessage            @"memberexpmessage"

///////////////车主端接口///////////////
//获取车主运营统计信息-GET
#define Kurl_ownersStatistical           @"ownersstatistical"
//获取车主车辆列表-GET，添加车辆-POST
#define Kurl_vehicle                     @"vehicle"
//获取空闲车辆列表
#define Kurl_vehiclefree                 @"vehiclefree"
//获取车主的司机列表-GET
#define Kurl_ownersDriver                @"ownersDriver"
//添加司机-POST
#define Kurl_driver                      @"driver"
//修改司机
#define Kurl_vdriver                      @"vdriver"
//获取空闲车辆列表
#define Kurl_driverfree                  @"driverfree"
//抢单列表get获取列表 post 抢单
#define Kurl_charterOrderGrab            @"charterOrderGrab"
//获取抢单结果
#define Kurl_charterOrder                @"charterOrder"
//获取车主任务列表-GET CharterOrderGrab
#define Kurl_ownersTask                  @"ownersTask"
//获取车主任务详情-GET
#define Kurl_ownersTaskDetails           @"ownersTaskDetails"
//获取抢单列表-GET  提交抢单信息-POST
#define Kurl_roborder                    @"roborder"
//获取运营公司-GET
#define Kurl_company                     @"company"
//获取经营范围-GET
#define Kurl_scope                       @"scope"
//车辆未审核通过原因-put
#define Kurl_auditreason                 @"vehicleAuditReason"
//司机未审核通过原有
#define Kurl_driverAuditReason           @"driverAuditReason"
//开始任务 post
#define Kurl_starttask                   @"starttask"
//任务失败原因-GET
#define Kurl_taskreason                  @"taskreason"
//获取已完成任务统计信息-GET
#define Kurl_taskstatistics              @"taskstatistics"
//车主任务列表
#define Kurl_charterOrderOwnersTask      @"charterOrderOwnersTask"
//获取车主详情
#define Kurl_driverdetaile               @"driverdetaile"
//获取车主运营统计信息
#define Kurl_ownersStatistics            @"ownersStatistics"
//获取车辆统计信息
#define Kurl_vehicleStatistics           @"vehicleStatistics"
//修改车辆状态
#define Kurl_vehicleStatus               @"vehicleStatus"
//修改车辆单日期望毛利
#define Kurl_vehiclePrice                @"vehiclePrice"
//获取车辆的任务列表
#define Kurl_charterOrderVehicleTask     @"charterOrderVehicleTask"

///////////////司机端接口///////////////
//获取司机运营统计信息-GET
#define Kurl_driverStatistics            @"driverStatistics"
//获取司机任务列表-GET
#define Kurl_drivertask                  @"drivertask"
//获取司机任务详情-GET
#define Kurl_drivertaskdetails           @"drivertaskdetails"
//获取拼车任务乘客明细-GET
#define Kurl_orderpassengers             @"orderpassengers"
//验票-POST  司机开始-POST
#define Kurl_ticket                      @"ticket"
//获取驾驶员任务列表
#define Kurl_charterOrderDriverTask      @"CharterOrderDriverTask"
//拼车的请求
#define Kurl_carpoolOrderDriverTask      @"CarpoolOrderDriverTask"
//获取瓶车乘客列表
#define Kurl_carpoolOrdeMember           @"CarpoolOrderMember"
//验票请求
#define Kurl_CarpoolOrderDriverTask      @"CarpoolOrderDriverTask"
//提交包车定位信息 或者获取
#define Kurl_CharterLocation             @"CharterLocation"
//提交拼车定位信息 或者获取
#define Kurl_CarpoolLocation             @"CarpoolLocation"


///////////////整理控制器请求///////////////
//天府专车下单、取消订单。。
#define Kurl_FerryOrder                 @"FerryOrder"
//Delete- 拼车-退票（取消订单）拼车-订单详情（列表）	POST-拼车订单提交
#define Kurl_CarpoolOrder               @"CarpoolOrder"
//orderId天府专车-订单是否提交成功	type天府专车-查询是否有未完成的订单
#define Kurl_FerryOrderCheck            @"FerryOrderCheck"
//天府专车-获取专车位置集合（下订单以前）	天府专车-获取专车位置集合（下订单以前）
#define Kurl_FerryLocation              @"FerryLocation"

//天府专车 提交/获取评论
#define Kurl_FerryReviews               @"FerryReviews"
//拼车-是否提交成功
#define Kurl_CarpoolOrderCheck          @"CarpoolOrderCheck"
//拼车-班次列表
#define Kurl_CarpoolBusShift            @"CarpoolBusShift"
//选择地址出发地
#define Kurl_CarpoolStartingCitys       @"CarpoolStartingCitys"
//目的地
#define Kurl_CarpoolDestinationCitys    @"CarpoolDestinationCitys"
//包车-主订单列表-会员
#define Kurl_CharteOrderMain            @"CharterOrderMain"
//主订单详情
#define Kurl_CharterOrderMainDetaile    @"CharterOrderMainDetaile"
// 包车-子订单-会员(与子订单详情一样)
#define Kurl_CharterOrderSubDetaile     @"CharterOrderSubDetaile"
// 包车退款手续费				
#define Kurl_CharterOrderRefundPrice    @"CharterOrderRefundPrice"
//GET-评论列表 ----POST 包车开发票
#define Kurl_Reviews                    @"Reviews"
//GET-包车-VIP价格   POST-包车-价格计算-会员
#define Kurl_CharterOrderPrice          @"CharterOrderPrice"
//拼车-订单-获取车票集合（用于生成二维+A144:E176码）
#define Kurl_CarpoolOrderTickets        @"CarpoolOrderTickets"
// 拼车-退款手续费
#define Kurl_CarpoolOrderRefundPrice    @"CarpoolOrderRefundPrice"
//地图栅栏
#define Kurl_Fence                      @"Fence"

#define Kurl_OfflineTransfer            @"OfflineTransfer"
//分享
#define Kurl_Share                      @"share"

#define Kurl_CarpoolOrderPrice          @"carpoolOrderPrice"

//包车-时间范围获取
#define Kurl_CharterOrderTime           @"CharterOrderTime"

//请求服务器banner获取地址
#define Kurl_Carouselindex              @"carouselindex"


//隐藏订单
#define Kurl_HideOrder                  @"HideOrder"

///////////////摆渡端接口///////////////
//iOS暂时不做

//****************************************************************
#define KResultCode                @"resultcode"
#define KResultInfo                @"errorinfo"
#define KDevicesType               @"2"

//请求类型
typedef enum {
    KRequestType_Login = 0,
    KRequestType_Register,
    KRequestType_Password,
    KRequestType_CarOwnerRegister,
    KRequestType_GetVerifyCode,
    KRequestType_GetCache,
    KRequestType_GetBusinessScope,
    KRequestType_GetVehicleLevel,
    KRequestType_GetVehicleType,
    KRequestType_GetFuelType,
    FNUserRequestType_GetUserInfo,
    FNUserRequestType_SetUserInfo,
    
    
    //用户端类型
    KRequestType_sharingvehicleorder,
    KRequestType_sharingvehicleorderpost,
    KRequestType_sharingvehicleorderget,
    KRequestType_rentvehicleprice,
    KRequestType_submitrentvehicleorder,
    KRequestType_sharinvehicleorder,
    KRequestType_sharinvehicleorderrob,
    KRequestType_cancelorder,
    KRequestType_coupons,
    KRequestType_paysubmit,
    KRequestType_membermessage,
    KRequestType_htcorder,
    KRequestType_complaints,
    KRequestType_advice,
    KRequestType_invoice,
    KRequestType_invoiceprice,
    KRequestType_memberexpmessage,
    //整理控制器接口
    KRequestType_FerryOrder,
    KRequestType_FerryOrderCheck,
    KRequestType_FerryLocationGet,
    KRequestType_FerryLocationPost,
    KRequestType_FerryOrder_DelectedOrder,
    KRequestType_FerryReviewsGet,
    KRequestType_FerryReviewsPost,
    FNUserRequestType_CityCarpoolOrderList,
    FNUserRequestType_CityCarpoolOrderListItemWithIndex,
    FNUserRequestType_CharterOrderMain,
    FNUserRequestType_CharterOrderListItemWithIndex,
    FNUserRequestType_Login,
    FNUserRequestType_CharterOrderDetail,
    FNUserRequestType_CharterSubOrderDetail,
    FNUserRequestType_CharterOrderCancel,
    FNUserRequestType_CharterOrderContinue,
    FNUserRequestType_CharterOrderRefundPrice,
    FNUserRequestType_CharterOrderReviewsList,
    FNUserRequestType_CharterOrderDelete,
    FNUserRequestType_GetVIPPrice,
    FNUserRequestType_CarpoolOrderList,
    FNUserRequestType_CarpoolOrderListItemWithIndex,
    FNUserRequestType_CarpoolOrderDetail,
    FNUserRequestType_CarpoolOrderCancel,
    FNUserRequestType_CarpoolOrderTickets,
    FNUserRequestType_CarpoolRefundCharge,
    FNUserRequestType_Fence,
    FNUserRequestType_Coupons,
    FNUserRequestType_Invoince,
    FNUserRequestType_Rating,
    FNUserRequestType_PayOfflineTransfer,
    FNUserRequestType_GetShareContent,
    RequestType_ComputePrice,
    RequestType_SubmitOrder,
    RequestType_checkOrderSuccess,
    RequestType_CarpoolBusShift,
    RequestType_SubmitCharteredOrder,
    RequestType_CharterOrderTime,
    FNUserRequestType_HideOrder,
    FNUserRequestType_GetCarouselindex,
    FNUserRequestType_CarpoolStartingCitys,
    FNUserRequestType_CarpoolDestinationCitys,

    //车主端
    KRequestType_ownersstatistical,
    KRequestType_getvehicle,
    KRequestType_postvehicle,
    KRequestType_getvehiclefree,
    KRequestType_ownersdriver,
    KRequestType_getDriver,
    KRequestType_postDriver,
    KRequestType_getdriverfree,
    KRequestType_getCharterOrderGrab,
    KRequestType_postCharterOrderGrab,
    KRequestType_getCharterGrab,
    KRequestType_ownerstask,
    KRequestType_charterOrderOwnersTask,
    KRequestType_ownerstaskdetails,
    KRequestType_roborderget,
    KRequestType_roborderpost,
    KRequestType_company,
    KRequestType_scope,
    KRequestType_auditreason,
    KRequestType_startTask,
    KRequestType_taskReason,
    KRequestType_taskstatistics,
    KRequestType_driverdetaile,
    KRequestType_ownersStatistics,
    KRequestType_vehicleStatistics,
    KRequestType_vehicleStatus,
    KRequestType_vehiclePrice,
    KRequestType_charterOrderVehicleTask,
    KRequestType_driverAuditReason,
    
    //司机端
    KRequestType_driverStatistics,
    KRequestType_drivertask,
    KRequestType_drivertaskdetails,
    KRequestType_orderpassengers,
    KRequestType_ticketget,
    KRequestType_ticketpost,
    KRequestType_charterOrderDriverTask,
    KRequestType_driverStartTask,
    KRequestType_driverEndTask,
    KRequestType_driverGetCarpoolingTask,
    KRequestType_driverCarpoolingTask,
    KRequestType_carpoolOrdeMember,
    KRequestType_carpoolrderDriverTask,
    KRequestType_postCharterLocation,
    KRequestType_getCharterLocation,
    KRequestType_postCarpoolLocation,
    KRequestType_getCarpoolLocatio,
    KRequestType_memberinfo,
    KRequestType_getCarpoolLocation,
    
}RequestType;

//登示类型
typedef enum{
    LoginType_Phone = 0,
    LoginType_Email,
}LoginType;


//用户角色定议
typedef enum{
    EMUserRole_User = 1,    //用户
    EMUserRole_Driver,      //司机
    EMUserRole_CarOwner     //车主
    
}EMUserRole;

typedef enum {
    ImageTypeCommon = 1,
    ImageTypeCertificate,
}EMImageType;

#pragma mark- 回调消息通知
//请求回调消息通知
#define KNotification_RequestFinished     @"HttpRequestFinishedNoitfication"
#define KNotification_RequestFailed       @"HttpRequestFailedNoitfication"
#define KNotification_UserLoginDone       @"HttpRequestUserLoginDoneNoitfication"
#define KNotification_GotoLoginControl    @"GotoLoginControlNoitfication"

//注册抢单通知 KNotification_GrabOrderResult
#define KNotification_PushGrabOrder       @"PushGrabOrderNoitfication"
#define KNotification_GrabOrderResult     @"GrabOrderResultNoitfication"
#define KNotification_OrderPayResult      @"OrderPayResultNoitfication"

//注册开始任务，结束任务通知
#define KNotification_DriverStartTask       @"DriverStartTaskNoitfication"
#define KNotification_DriverEndTask         @"DriverEndTaskNoitfication"

//注册3DTouch 通点击知
#define KNotification_shortcutItem          @"ShortcutItemKNotification"

#endif


