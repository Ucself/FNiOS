//
//  IFConstanst.h
//  FeiNiu_User
//
//  Created by tianbo on 16/7/4.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#ifndef IFConstanst_h
#define IFConstanst_h


#ifdef DEBUG                  // 调试阶段
    #define KDevServer
#else
    #ifdef ADHOC              // 测试阶段
    #define KTestServer
    #else                     // 发布阶段
    #define KReleaseServer
    #endif
#endif

//#define KDevServer
//#define KReleaseServer

#pragma mark - 地址

#ifdef KDevServer     //使用测试环境 地址
    //开发地址
    #define KPassportServer             @"http://staging.feelbus.cn:83/"
    #define KGatewayServer              @"http://staging.feelbus.cn:81/"
    #define KLocationServer             @"http://staging.feelbus.cn:84/"

    //更新地址
    #define KUpdateServer               @"http://staging.feelbus.cn:85/app/"
    #define KUpdateAppKey               @"0E51E23784ED85FFF09832FDE596F323"

    //鉴权参数
    #define KClient_id                  @"cc95370ca37c409eb399ba7ad210ddd7"
    #define KClient_secret              @"bTlvIMNsMDvdnk8EiLO3uDql5DoceHHHD5b7rrknlco"

#endif


#ifdef KTestServer
    //测试地址
    #define KPassportServer             @"http://staging.feelbus.cn:83/"
    #define KGatewayServer              @"http://staging.feelbus.cn:81/"
    #define KLocationServer             @"http://staging.feelbus.cn:84/"

    //更新地址
    #define KUpdateServer               @"http://staging.feelbus.cn:85/app/"
    #define KUpdateAppKey               @"0E51E23784ED85FFF09832FDE596F323"

    //鉴权参数
    #define KClient_id                  @"cc95370ca37c409eb399ba7ad210ddd7"
    #define KClient_secret              @"bTlvIMNsMDvdnk8EiLO3uDql5DoceHHHD5b7rrknlco"
#endif


#ifdef KReleaseServer
    //正式地址
    #define KPassportServer             @"https://passport.feiniubus.com/"
    #define KGatewayServer              @"https://igw.feiniubus.com/"
    #define KLocationServer             @"https://location.feiniubus.com/"

    //更新地址
    #define KUpdateServer               @"https://seenew.feiniubus.com:85/app/"
    #define KUpdateAppKey               @"CDC836F525282400E6FA8CCA9027B84E"

    //鉴权参数
    #define KClient_id                  @"55d584fa0d074d71bebcaeea613013c3"
    #define KClient_secret              @"gYI5t8vvCxFnzBqKtZ_5NaK8PHGMhIwqDAzIT5sjKR0"

#endif

#define KAboutServerAddr                @"http://about.feiniubus.com/"



/******************************************************
 *  v4.0 接口
 ******************************************************/
//////////////////鉴权接口//////////////////////
#pragma mark - 鉴权接口
//鉴权接口
#define UNI_Login                 @"connect/token"      //登录
#define UNI_RefreshToken          @"connect/token"      //刷新令牌
#define UNI_VerifyCode            @"phone/code"         //获取验证码
//////////////////////////////////////////////



//////////////////网关接口//////////////////////
#pragma mark - 网关接口
//个人中心
#define UNI_CouponList            @"payment/CouponList"                     //优惠券
#define UNI_CouponAll             @"payment/coupon/all"                     //优惠券
#define UNI_EditAccount           @"passenger/account/update"               //修改帐户信息
#define UNI_GetAccount            @"passenger/account/get"                  //获取帐户信息
#define UNI_Feedback              @"passenger/dedicated/order/feedback"     //反馈
#define UNI_Invite                @"passenger/account/share"                //获取邀请详情

//接送机接口与公共接口
#define UNI_CommuteOpenCity       @"passenger/business/opencity/commute"    //通勤车开通城市列表
#define UNI_OpenCity              @"passenger/business/opencity"            //开通城市列表
#define UNI_CityBusiness          @"business/open"                          //城市开通业务 【废除】
#define UNI_StationInfo           @"passenger/station/info"                 //航站车站列表
#define UNI_GetFence              @"passenger/fence/list"                   //地图围栏
#define UNI_Flightinfo            @"common/query/flight"                    //航班信息查询
#define UNI_ConfigSendtime        @"passenger/config/sendtime"              //获取时间配置
#define UNI_CommuteShare          @"passenger/commute/line/share"           //获取线路分享信息
#define UNI_ComputePrice          @"passenger/price/calculate"              //计算价格

//接送机支付
#define UNI_PaymentCharge         @"payment/create"                     //支付接口
#define UNI_PaymentQuery          @"payment/GetByNum"                   //支付状态查询
#define UNI_PayRefund             @"payment/refund"                     //退款<-
#define UNI_PayRefundQuery        @"payment/refund/state"               //退款状态查询<-
#define UNI_PayRefundDetail       @"passenger/dedicated/order/refund"   //退款详情

//接送机订单
#define UNI_CreateOrder           @"passenger/dedicated/order/create"              //创建订单
#define UNI_OrderDetail           @"passenger/dedicated/order/get"                 //订单详情
#define UNI_OrderList             @"passenger/dedicated/order/list"                //订单列表
#define UNI_Order_Delete          @"passenger/dedicated/order/delete"              //和2.0 有冲突 加下划线
#define UNI_OrderCancel           @"passenger/dedicated/order/cancel"
#define UNI_OrderReason           @"passenger/dedicated/order/cancel_reason"
#define UNI_EvaluateGet           @"passenger/dedicated/order/appraise"
#define UNI_EvaluatePost          @"passenger/dedicated/order/appraise"
#define UNI_ComplaintAdd          @"passenger/dedicated/order/complaint"
#define UNI_BillDetail            @"passenger/dedicated/order/price"                //账单详情

//定制通勤
#define UNI_CommuteList           @"passenger/commute/line/list"                //通勤车线路列表
#define UNI_CommuteDetail         @"passenger/commute/line/get"                 //通勤车线路详情
#define UNI_CommuteSearch         @"passenger/commute/line/search"              //通勤车线路搜索
#define UNI_CommuteTicket         @"passenger/commute/line/remain"              //站点和余票
#define UNI_ConfigAdvertisement   @"passenger/config/custom"                    //首页广告
#define UNI_CouponBest            @"payment/BestCoupon"                         //获取最优优惠劵
#define UNI_ConfigActivity        @"passenger/config/activity"                  //获取活动列表

//定制通勤订单
#define UNI_CommuteOrderPost            @"commute/order/create"             //通勤车下单
#define UNI_CommuteOrderTicket          @"commute/order/get"                //车票详情接口
#define UNI_CommuteOrderRefund          @"commute/order/refund"             //车票退票接口
#define UNI_CommuteOrderList            @"commute/order/GetByCreatorId"     //通勤车行程列表
#define UNI_CommuteOrderTicketDelete    @"commute/order/hide"               //删除车票接口
#define UNI_CommuteOrderCancel          @"commute/order/update_state"       //取消订单
#define UNI_CommuteTicketReason         @"commute/order/CancelReason"       //退票取消原因
#define UNI_CommuteTicketComplaint      @"commute/order/complaint"          //投诉原因
#define UNI_CommuteTicketRefund         @"commute/order/refund_detail"      //退款详情
#define UNI_CommuteTicketEvaluate       @"commute/order/appraise"           //评价
#define UNI_CommuteTicketGetEvaluate    @"commute/order/get_appraise"       //获取评价

#define UNI_CommutePaymentCharge        @"payment/create"                   //通勤车支付接口
#define UNI_CommuteMyTickets            @"commute/order/unuse"              //通勤车未验票车票接口
#define UNI_CommuteValidateTicket       @"commute/order/check"              //通勤车乘客验票接口
#define UNI_CommuteApply                @"passenger/commute/line/apply"     //通勤车线路申请
#define UNI_CommuteApplyGet             @"passenger/commute/line/apply_get" //通勤车线路查询

#define UNI_CommuteOrderCalc            @"commute/order/calc"              //通勤车订单计价接口

//////////////////////////////////////////////



//////////////////位置接口//////////////////////
#pragma mark - 位置接口
//////////////////////////////////////////////


//////////////////更新接口//////////////////////
#pragma mark - 更新接口
#define UNI_UpdateCheck                  @"version"
//////////////////////////////////////////////



//#pragma mark - 2.0接口
///******************************************************
// *  v2.0 接口
// ******************************************************/
//
//////登录
////#define UNI_Login                 @"account/login"
//////获取验证码
////#define UNI_VerifyCode            @"account/verificationcode"
////获取设置个人信息
//#define UNI_UserInfo              @"account/accountinfo"
////获取优惠券ß
//#define UNI_GetCounpos            @"account/coupons"
//
////上传文件
//#define UNI_Upload                @"common/Resources"
////获取首页轮播图片
//#define UNI_CarouselIndex         @"Static/CarouselIndex"
////获取分享内容
//#define UNI_ShareContent          @"Static/Share"
////鉴权接口
//#define UNI_CheckToken            @"common/CheckToken"
//
//
//
////获取接送机站点数据
//#define UNI_GetCommonAddress      @"Dedicated/CommonAddress"
////获取接送机时间范围
//#define UNI_GetDateRange          @"Dedicated/DateRange"
////接送机价格计算
//#define UNI_GetPrice              @"Dedicated/price"
////提交专车订单, 获取订单列表, 详情, 取消
//#define UNI_DedicatedOrder        @"Dedicated/order"
////专车坐标集合
//#define UNI_GetDedicatedLocation  @"common/DedicatedLocation"
//
////获取专车当前坐标
//#define UNI_GetFerryBusLocation   @"common/FerryBusLocation"
////提交/获取评价信息
//#define UNI_DedicatedAppraise     @"Dedicated/Appraise"
////提交取消接送订单原因
//#define UNI_DedicatedCancelReason @"Dedicated/Reason"
////退款详细信息
//#define UNI_DedicatedRefundPace   @"Dedicated/RefundPace"
////查询订单状态
//#define UNI_DedicatedOrderState   @"Dedicated/orderstate"
//
//
////获取起点城市
//#define UNI_StartCity               @"booking/StartCity"
////获取终点城市
//#define UNI_DestinationCity         @"booking/DestinationCity"
////获取订票时间范围
//#define UNI_DateRange               @"booking/DateRange"
////获取预班次票列表
//#define UNI_BookingTickets          @"booking/BookingTickets"
////乘车人功能
//#define UNI_PassengerHistory        @"booking/PassengerHistory"
////客票:创建订单, 订单列表, 订单详情,
//#define UNI_Order                   @"booking/order"
////获取订单中车票列表
//#define UNI_TicketInOrder           @"booking/OrderTicket"
////获取退票参数
//#define UNI_TicketRefundRule        @"booking/RefundRule"
////取消, 退票
//#define UNI_TicketCancel            @"booking/Cancel"
////查询退款详细信息
//#define UNI_TicketRefundPace        @"booking/RefundPace"
//
////删除订单
//#define UNI_OrderDelete             @"common/DeleteOrder"
//
////创建支付请求
//#define UNI_PaymentCreate           @"payment/create"
//
////获取支付结果
//#define UNI_PaymentResult           @"payment/PayResult"
//
//
///**********https***************/
//#define Https_Token                 @"api/common/token"
//#define Https_AuthCode              @"api/common/totp"



/******************************************************
 *  请求类型
 ******************************************************/
typedef enum {
    
    /******************************************************
     *  v4.0 接口
     ******************************************************/
    
    //用户接口
    EmRequestType_Login = 0,
    EmRequestType_GetVerifyCode =1,
    EMRequestType_RefreshToken =2,
    
    //检查更新
    EmRequestType_UpdateCheck =3,

    
    //个人中心
    EmRequestType_CouponAll =4,
    EmRequestType_CouponList =5,
    EmRequestType_EditAccount =6,
    EmRequestType_GetAccount =7,
    EmRequestType_Feedback = 8,                 //投诉/建议
    EmRequestType_Invite = 9,                   //取邀请详情
    
    //接送机接口与公共接口
    EmRequestType_OpenCity =10,                 //开通城市列表
    EmRequestType_CommuteOpenCity =11,          //通勤车城市列表
    EmRequestType_CityBusiness =12,             //城市开通业务
    EMRequestType_StationInfo =13,              //航站车站列表
    EmRequestType_GetFence =14,                 //地图围栏
    EmRequestType_FlightInfo =15,               //航班查询
    EmRequestType_ConfigSendtime =16,           //获取时间配置
    EmRequestType_CommuteShare =17,             //获取分享内容
    EmRequestType_ComputePrice =18,             //计算价格
    
    //接送机支付
    EmRequestType_PaymentCharge =19,            //支付接口
    EmRequestType_PaymentQuery =20,             //支付查询
    EmRequestType_PayRefund =21,                //退款
    EmRequestType_PayRefundQuery =22,           //退款查询
    EmRequestType_PayRefundDetail =23,          //退款详情
    
    //接送机订单
    EmRequestType_CreateOrder =24,              //生产订单
    EmRequestType_OrderDetail =25,              //订单详情
    EmRequestType_OrderList =26,                //订单列表
    EmRequestType_Order_Delete =27,             //订单删除
    EmRequestType_OrderCancel =28,              //取消订单
    EmRequestType_OrderReason =29,              //提交取消订单原因
    EmRequestType_ComplaintAdd =30,             //提交订单投诉
    EmRequestType_EvaluateGet =31,              //查看订单评价
    EmRequestType_EvaluatePost =32,             //添加订单评价
    EmRequestType_BillDetail =33,               //账单详情
    
    //定制通勤
    EmRequestType_CommuteList =34,              //通勤列表
    EmRequestType_CommuteDetail =35,            //通勤详情
    EmRequestType_CommuteSearch =36,            //通勤搜索
    EmRequestType_CommuteTicket =37,            //余票站点信息
    EmRequestType_ConfigAdvertisement =38,      //广告配置
    EmRequestType_CouponBest =39,               //最优优惠
    EmRequestType_ConfigActivity = 56,               ////获取活动列表
    
    //定制通勤订单
    EmRequestType_CommuteOrderPost=40,          //乘客下单
    EmRequestType_CommuteOrderTicket =41,        //通勤车票行程信息
    EmRequestType_CommuteOrderList =42,          //通勤车行程列表
    EmRequestType_CommuteOrderTicketDelete =43,          //通勤车行程删除
    EmRequestType_CommuteOrderCancel =44,           //取消通勤车订单
    EmRequestType_CommuteTicketReason =45,         //退票取消原因
    EmRequestType_CommuteTicketComplaint =46,         //退票取消原因
    EmRequestType_CommuteTicketRefund =47,         //退款详情
    EmRequestType_CommuteTicketEvaluate =48,          //评价
    EmRequestType_CommutePayment =49,             //通勤车支付
    
    EmRequestType_CommuteMyTickets =50,           //我的车票
    EmRequestType_CommuteValidateTicket =51,     //验票
    EmRequestType_CommuteApply =52,               //线路申请
    EmRequestType_CommuteApplyGet =53,            //申请查询
    EmRequestType_CommuteOrderRefund =54,        //通勤车退票
    EmRequestType_CommuteTicketGetEvaluate =55,          //获取评价
    
    EmRequestType_CommuteOrderCalc =57,          //通勤车订单计价接口
    
    
    
    /******************************************************
     *  v2.0 接口
     ******************************************************/
    
    EmRequestType_GetUserInfo,
    EmRequestType_SetUserInfo,
    EmRequestType_GetCoupons,               //取优惠券
    
    EmRequestType_GetFeedBack,              //取投诉/建议
    EmRequestType_CarouselIndex,            //首页轮播
    EmRequestType_ShareContent,             //获取分享内容
    EmRequestType_CheckToken,               //鉴权
    
    //接送接口
    EmRequestType_GetCommonAddress,            //取接送起/终点
    EmRequestType_GetDateRange,                //取接送时间范围
    EmRequestType_GetPrice,                    //计算价格
    EmRequestType_GetDedicatedLocation,        //获取专车位置
    
    EmRequestType_GetFerryBusLocation,         //获取专车位置
    EmRequestType_PostDedicatedOrder,          //提交专车订单
    EmRequestType_GetDedicatedOrder,           //获取专车订单详情
    EmRequestType_GetDedicatedList,            //获取订单列表
    EmRequestType_GetDedicatedAppraise,        //获取评价信息
    EmRequestType_PostDedicatedAppraise,       //提交评价信息
    EmRequestType_DeleteDedicatedOrder,        //取消接送订单
    EmRequestType_PostCancelReason,            //提交取消原因
    EmRequestType_GetDedicateRefundPace,       //退款详细信息
    EmRequestType_GetOrderState,               //查询订单状态
    EmRequestType_DedicateOrderRemove,       //删除客票订单
    
    //客票接口
    EmRequestType_StartCity,               //取起点城市
    EmRequestType_DestinationCity,         //取终点城市
    EmRequestType_DateRange,               //取车票预售时间范围
    EmRequestType_BookingTickets,          //车票班次列表
    EmRequestType_PassengerHistory,        //常用联系人列表
    EmRequestType_AddPassengerHistory,     //添加常用联系人列表
    EmRequestType_DeletePassengerHistory,  //删除常用联系人列表
    EmRequestType_TicketOrderCreate,       //创建订单
    EmRequestType_TicketOrderList,         //客票订列表
    EmRequestType_TicketOrderDetail,       //客票详情
    EmRequestType_TicketOrderTickets,      //客票订单中的车票列表
    EmRequestType_TicketRefundRule,        //获取退票参数
    EmRequestType_TicketRefundPace,        //查询退款信息
    EmRequestType_TicketRefund,            //退票
    EmRequestType_TicketCancel,            //取消订单
    EmRequestType_TicketOrderRemove,       //删除客票订单
    
    //支付接口
    EmRequestType_PaymentCreate,            //支付请求
    EmRequestType_PaymentResult,            //获取支付结果
    
    
}EMRequestType;


#pragma mark -
#define REQUESTURL(X) [NSString stringWithFormat:@"%@%@", KServerAddr, X]
#define REQUESTURL2(A, B) [NSString stringWithFormat:@"%@%@", A, B]
#define HTTPSREQUESTURL(X) [NSString stringWithFormat:@"%@%@", KAuthorizeAddr, X]

#pragma mark - Web URL
// 规则－退款
#define HTMLAddr_CharterRefundRule @"http://about.feiniubus.com/rule1.html"
// 规则－呼叫飞牛计价
#define HTMLAddr_CallFeiniuRule    @"http://about.feiniubus.com/rule7.html"
// 关于
#define HTMLAddr_About             @"http://about.feiniubus.com/about.html"
// 使用协议－乘客
#define HTMLAddr_ProtocolUser      @"http://about.feiniubus.com/agreement1.html"
// 温馨提示－拼车－待支付
#define HTMLAddr_CarpoolWaitPayTip [KAboutServerAddr stringByAppendingString:@"prompt1.html"]
// 温馨提示－拼车－已支付
#define HTMLAddr_CarpoolPaidTip [KAboutServerAddr stringByAppendingString:@"prompt2.html"]
// 功能介绍
#define HTMLAddr_FuncIntroduce     @"http://about.feiniubus.com/introduce.html"
// 常见问题
#define HTMLAddr_FAQ               @"http://about.feiniubus.com/FAQ.html"
//上下车点页面
#define HTMLGetonPage              @"http://about.feiniubus.com/getOn/getOn.html"
//退示规则
#define HTMLRefundExplain          @"http://about.feiniubus.com/refundExplain.html"
//购票说明
#define HTMLTicketExplainn       @"http://about.feiniubus.com/ticketExplain.html"
// 热线电话
#define HOTLINE @"4000820112"



#endif /* IFConstanst_h */
