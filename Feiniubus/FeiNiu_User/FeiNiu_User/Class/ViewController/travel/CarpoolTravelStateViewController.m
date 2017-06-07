//
//  CarpoolTravelStateViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/5.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CarpoolTravelStateViewController.h"
#import "SubmitStyleButton.h"
#import "BorderButton.h"
#import "CarpoolOrderItem.h"
#import "UIColor+Hex.h"
#import "CarpoolPayViewController.h"
#import "UserTicketsViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "BaiDuCarViewController.h"
#import <WebImage/WebImage.h>
#import "OrderReview.h"
#import "UserWebviewController.h"
#import "BaiDuCarWaitOrder.h"
#import "BaiDuCarWaitOwner.h"
#import "BaiDuCarRouting.h"
#import "TFCarEvaluationVC.h"
#import "TFCarOrderDetailModel.h"

#import "UserCustomAlertView.h"

static inline BOOL CLLocationCoordinate2DIsSame(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2){
    BOOL isSame = NO;
    
    if ( ABS(c1.latitude - c2.latitude) < 0.0001
        && ABS(c1.longitude - c2.longitude) < 0.0001 )
    {
        isSame = YES;
    }
    
    return isSame;
}

@interface CarpoolTravelStateViewController ()
- (IBAction)OnClickWarmPromptBtn:(id)sender;
- (IBAction)onClickPhoneBtn:(id)sender;
@end

@implementation CarpoolTravelStateViewController
+ (instancetype)instaceWithState:(OrderState)state{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"CarpoolTravelStateViewController_%@", @(state)]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)OnClickWarmPromptBtn:(id)sender {
    
//    RuleViewController *ruleVC = [[UIStoryboard storyboardWithName:@"TakeBus" bundle:nil] instantiateViewControllerWithIdentifier:@"rulevc"];
//    ruleVC.vcTitle = @"温馨提示";
//    ruleVC.urlString = [NSString stringWithFormat:@"%@prompt2.html",KAboutServerAddr];
//    [self.navigationController pushViewController:ruleVC animated:YES];
}


- (IBAction)onClickPhoneBtn:(id)sender {
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

#pragma mark - 系统确认
@interface CarpoolTravelWaitConfirmViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *ivState;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;

@end
@implementation CarpoolTravelWaitConfirmViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    [self updateUI];

}

- (void)updateUI{
    if (!self.carpoolOrder) {
        return;
    }
    if (self.carpoolOrder.orderStatus == CarpoolOrderStatusReserveFail) {
        self.ivState.image = [UIImage imageNamed:@"carpool_reservfail"];

        self.lblDesc.text = [NSString stringWithFormat:@"尊敬的乘客，您定的 %@ 到 %@ 的车预约失败。%@。给您带来的不便敬请谅解！",self.carpoolOrder.startName, self.carpoolOrder.destinationName, self.carpoolOrder.comment];
    }else if (self.carpoolOrder.orderStatus == CarpoolOrderStatusReserveSuccess) {
        self.ivState.image = [UIImage imageNamed:@"carpool_systemconfirm"];
        self.lblDesc.text = @"尊敬的乘客，您提交的订单已经预定成功！";
    }else{
        self.ivState.image = [UIImage imageNamed:@"carpool_waiting"];
        self.lblDesc.text = @"尊敬的乘客，您提交了订单，请等待系统确认！";
    }
}
- (void)httpRequestFinished:(NSNotification *)notification{
    
}
@end

#pragma mark -
@interface CarpoolTravelWaitPayViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblStartName;
@property (weak, nonatomic) IBOutlet UILabel *lblEndName;
@property (weak, nonatomic) IBOutlet UILabel *lblSmallPrice;
@property (weak, nonatomic) IBOutlet UITextField *tfStartTime;
@property (weak, nonatomic) IBOutlet UITextField *tfStartPlace;
@property (weak, nonatomic) IBOutlet UILabel *lblTicketsDes;
@property (weak, nonatomic) IBOutlet UILabel *lblBigPrice;
@property (weak, nonatomic) IBOutlet UIImageView *ivArrow;

@end
@implementation CarpoolTravelWaitPayViewController

#pragma mark - LifeCycle
- (void)viewDidLoad{
    [super viewDidLoad];
    self.lblStartName.text = self.carpoolOrder.startName;
    self.lblEndName.text = self.carpoolOrder.destinationName;
//    self.lblSmallPrice.text = [NSString stringWithFormat:@"￥%@", @(self.carpoolOrder.price / 100.0f)];

    @try {
        self.ivArrow.animationImages = @[[UIImage imageNamed:@"carpool_light1"],[UIImage imageNamed:@"carpool_light2"],[UIImage imageNamed:@"carpool_light3"],[UIImage imageNamed:@"carpool_light4"],[UIImage imageNamed:@"carpool_light5"],];
        self.ivArrow.animationDuration = 0.7;
        [self.ivArrow startAnimating];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    if (self.carpoolOrder.type == CarpoolBusTypeGundong ||
        self.carpoolOrder.type == CarpoolBusTypeGundong2) {
        self.tfStartTime.text = [NSString stringWithFormat:@"%@ %@-%@", [self.carpoolOrder.departure timeStringByFormat:@"yyyy年MM月dd日"], self.carpoolOrder.startTime, self.carpoolOrder.endTime];
    }else{
        self.tfStartTime.text = [NSString stringWithFormat:@"%@ %@", [self.carpoolOrder.departure timeStringByFormat:@"yyyy年MM月dd日"], self.carpoolOrder.departureTime];
    }
    self.tfStartPlace.text = self.carpoolOrder.station;
    
    NSMutableAttributedString *ticketsDes = [[NSMutableAttributedString alloc]init];
    NSDictionary *brownAttr = @{NSForegroundColorAttributeName:[UIColor colorWithHex:GloabalTintColor]};

    if (self.carpoolOrder.adultsTicketsNumber > 0) {
//        [ticketsDes appendAttributedString:[[NSAttributedString alloc]initWithString:@"成人票" ]];
        
        [ticketsDes appendAttributedString:[[NSAttributedString alloc]initWithString:@"" ]];
        [ticketsDes appendAttributedString:[[NSAttributedString alloc]initWithString:@(self.carpoolOrder.adultsTicketsNumber).stringValue attributes:brownAttr]];
        [ticketsDes appendAttributedString:[[NSAttributedString alloc]initWithString:@"张    "]];
    }
    if(self.carpoolOrder.childTicketsNumber > 0){
        [ticketsDes appendAttributedString:[[NSAttributedString alloc]initWithString:@"儿童票"]];
        [ticketsDes appendAttributedString:[[NSAttributedString alloc]initWithString:@(self.carpoolOrder.childTicketsNumber).stringValue attributes:brownAttr]];
        [ticketsDes appendAttributedString:[[NSAttributedString alloc]initWithString:@"张"]];
    }
    self.lblTicketsDes.attributedText = ticketsDes;
    
    self.lblBigPrice.text = [NSString stringWithFormat:@"￥%@元", @(self.carpoolOrder.price / 100.0f)];
}
#pragma mark - Actions

- (IBAction)actionKefu:(BorderButton *)sender {
    [self takeAPhoneCallTo:HOTLINE];
//    NSString * str=[[NSString alloc] initWithFormat:@"tel:%@", KEFU_PHONE];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
- (IBAction)actionTips:(BorderButton *)sender {
    UserWebviewController *webVC = [[UserWebviewController alloc]initWithUrl:HTMLAddr_CarpoolWaitPayTip];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toCarpoolPay"]) {
        // to pay
        ((CarpoolPayViewController *)segue.destinationViewController).carpoolOrder = self.carpoolOrder;
    }
}
@end

#pragma mark - 拼车已支付状态
@interface CarpoolTravelIsPayViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblStartPlace;
@property (weak, nonatomic) IBOutlet UILabel *lblEndPlace;
@property (weak, nonatomic) IBOutlet UILabel *lblPriceSmall;
@property (weak, nonatomic) IBOutlet UITextField *tfStartTime;
@property (weak, nonatomic) IBOutlet UITextField *tfStartStation;
@property (weak, nonatomic) IBOutlet UIButton *btnOk;
@property (weak, nonatomic) IBOutlet UIImageView *ivArrow;
@property (weak, nonatomic) IBOutlet UIButton *btnTelephone;

@end
@implementation CarpoolTravelIsPayViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.lblStartPlace.text = self.carpoolOrder.startName;
    self.lblEndPlace.text = self.carpoolOrder.destinationName;
    self.lblPriceSmall.text = [NSString stringWithFormat:@"￥%@", @(self.carpoolOrder.price / 100)];
    
    @try {
        self.ivArrow.animationImages = @[[UIImage imageNamed:@"carpool_light1"],[UIImage imageNamed:@"carpool_light2"],[UIImage imageNamed:@"carpool_light3"],[UIImage imageNamed:@"carpool_light4"],[UIImage imageNamed:@"carpool_light5"],];
        self.ivArrow.animationDuration = 0.7;
        [self.ivArrow startAnimating];
        if (self.carpoolOrder.telephone && [self.carpoolOrder.telephone isKindOfClass:[NSString class]]) {
            NSString *telephoneTitle = [NSString stringWithFormat:@"站务人员电话：%@", self.carpoolOrder.telephone];
            NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:telephoneTitle attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
            [attString addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:GloabalTintColor]} range:[telephoneTitle rangeOfString:self.carpoolOrder.telephone]];
            [self.btnTelephone setAttributedTitle:attString forState:UIControlStateNormal];
        }else{
            [self.btnTelephone setTitle:@"" forState:UIControlStateNormal];
        }
    }
    @catch (NSException *exception) {
        [self.btnTelephone setTitle:@"" forState:UIControlStateNormal];
    }
    @finally {
        
    }
   
    if (self.carpoolOrder.type == CarpoolBusTypeGundong ||
        self.carpoolOrder.type == CarpoolBusTypeGundong2) {
        self.tfStartTime.text = [NSString stringWithFormat:@"%@ %@-%@", [self.carpoolOrder.departure timeStringByFormat:@"yyyy年MM月dd日"], self.carpoolOrder.startTime, self.carpoolOrder.endTime];
    }else{
        self.tfStartTime.text = [NSString stringWithFormat:@"%@ %@", [self.carpoolOrder.departure timeStringByFormat:@"yyyy年MM月dd日"], self.carpoolOrder.departureTime];
    }
    
    if (![self.carpoolOrder.station isKindOfClass:[NSNull class]]) {
       self.tfStartStation.text = self.carpoolOrder.station;
    }
    
    
    [self.btnOk addTarget:self action:@selector(callBaiDuCarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark -- button event

- (void)callBaiDuCarButtonClick{
    
    //本地保存的订单状态
//    id object = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"CurrentOrderIdUserDefault_%@",self.carpoolOrder.orderId]];
    
    NSString* orderId = self.carpoolOrder.ferryOrder[@"orderId"];

    if (orderId && [orderId isKindOfClass:[NSString class]]) {
        
        [self startWait];
        [NetManagerInstance sendRequstWithType:KRequestType_FerryOrderCheck params:^(NetParams *params) {
            params.data = @{@"orderId":orderId};
        }];

    }else{
        BaiDuCarViewController *baiducarVC = [[UIStoryboard storyboardWithName:@"BaiDuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"baiducar"];
        baiducarVC.orderDetail     = self.carpoolOrder;
        [self.navigationController pushViewController:baiducarVC animated:YES];
    }
}

- (IBAction)OnClickWarmPromptBtn:(id)sender{
    UserWebviewController *webVC = [[UserWebviewController alloc]initWithUrl:HTMLAddr_CarpoolPaidTip];
    [self.navigationController pushViewController:webVC animated:YES];
}
- (IBAction)onClickPhoneBtn:(id)sender{
    [self takeAPhoneCallTo:HOTLINE];
}
- (IBAction)actionHotLine:(UIButton *)sender {
    NSString *phone = self.carpoolOrder.telephone;
    NSString *message = @"确定拨打站务人员电话吗？";
    
    if (!phone || ![phone isKindOfClass:[NSString class]]) {
        return;
    }
    [self takeAPhoneCallTo:phone alertMessage:message];
}

#pragma mark - Private Methods
- (void)pushToTicketsVC{
    UserTicketsViewController *ticketsVC = [UserTicketsViewController instanceFromStoryboard];
    ticketsVC.tickets = self.carpoolOrder.tickets;
    [ticketsVC showInViewController:self.navigationController];

//    [self.navigationController pushViewController:ticketsVC animated:YES];
}
#pragma mark - RequestMethods
- (void)requestTickets{

    [NetManagerInstance sendRequstWithType:FNUserRequestType_CarpoolOrderTickets params:^(NetParams *params) {
        params.data = @{@"orderId":self.carpoolOrder.orderId};
    }];
}
#pragma mark - Request CallBack
- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    NSString* orderId = self.carpoolOrder.ferryOrder[@"orderId"];

    
    if (type == FNUserRequestType_CarpoolOrderTickets) {
        NSMutableArray *array =[NSMutableArray array];
        NSArray *list = resultData.data[@"list"];
        for (NSDictionary *dic in list) {
            BusTicket *ticket = [[BusTicket alloc] initWithDictionary:dic];
            [array addObject:ticket];
        }
        self.carpoolOrder.tickets = [NSArray arrayWithArray:array];
        [self pushToTicketsVC];
        
    }else if (type == KRequestType_FerryOrderCheck){
    
        [self stopWait];
        
        if (resultData.resultCode == 0) {
            
            if (![resultData.data[@"order"] isKindOfClass:[NSDictionary class]]) {
                [self showTipsView:@"数据异常"];
                return ;
            }
            
            NSLog(@"--订单状态1.待确认 2.等待司机接送 3.行程开始 4.行程完成 5.取消--当前state=%d",[resultData.data[@"order"][@"state"] intValue]);
            
            TFCarOrderDetailModel* orderModel = [[TFCarOrderDetailModel alloc] initWithDictionary:resultData.data[@"order"]];
            
            switch (orderModel.state) {
                    
                case 1:
                {
                    //等待排单
                    BaiDuCarWaitOrder *waitOrderVC = [[UIStoryboard storyboardWithName:@"BaiDuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"waitorder"];
                    waitOrderVC.userLatitude  = orderModel.boardingLatitude;
                    waitOrderVC.userLongitude = orderModel.boardingLongitude;
                    waitOrderVC.orderId       = orderId;
                    waitOrderVC.typeId        = orderModel.type;
                    waitOrderVC.carpoolOrderId = self.carpoolOrder.orderId;
                    [self.navigationController pushViewController:waitOrderVC animated:YES];
                }
                    break;
                    
                case 2:{
                    //等待司机
                    BaiDuCarWaitOwner *ownerVC = [[UIStoryboard storyboardWithName:@"BaiDuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"waitowner"];
                    ownerVC.orderId = orderId;
                    ownerVC.waitTypeId = orderModel.type;
                    [self.navigationController pushViewController:ownerVC animated:YES];
                }
                    
                    break;
                    
                case 3:{
                    //行程中
                    BaiDuCarRouting *carRouting = [[UIStoryboard storyboardWithName:@"BaiDuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"carrouting"];
                    carRouting.orderId = orderId;
                    carRouting.routingTypeId = orderModel.type;
                    [self.navigationController pushViewController:carRouting animated:YES];
                }
                    break;
                    
                case 4:{
                    //评价
                    BOOL hasEvaluation = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"HaveEvaluation_%@",orderId]] boolValue];
                    
                    TFCarEvaluationVC *evaluationVC = [[UIStoryboard storyboardWithName:@"TianFuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"evaluationvc"];
                    evaluationVC.orderId = orderId;
                    evaluationVC.evaluationTypeId = orderModel.type;
                    evaluationVC.isTianFuCar = NO;
                    evaluationVC.isLook = hasEvaluation;
                    [self.navigationController pushViewController:evaluationVC animated:YES];
                }
                    break;
                    
                    
                    
                default:{
                    BaiDuCarViewController *baiducarVC = [[UIStoryboard storyboardWithName:@"BaiDuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"baiducar"];
                    baiducarVC.orderDetail     = self.carpoolOrder;
                    [self.navigationController pushViewController:baiducarVC animated:YES];
                }
                    break;
            }
        }else{
            [MBProgressHUD showTip:@"查询订单失败!" WithType:FNTipTypeFailure];
        }
    }
}
#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTicketsIdentifier"];
    UILabel *lblCount = (UILabel *)[cell.contentView viewWithTag:201];
    lblCount.text = [NSString stringWithFormat:@"%@张", @(self.carpoolOrder.tickets.count)];
    return cell;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.carpoolOrder.tickets && self.carpoolOrder.tickets.count > 0) {
        [self pushToTicketsVC];
    }else{
        [self startWait];
        [self requestTickets];
    }
    return nil;
}

@end

#pragma mark -
@interface CarpoolTravelPendingViewController ()
//<FNMapViewDelegate, FNMapSearchDelegate>{
//    FNMapAnnotation *_userAnnotation;
//    FNMapAnnotation *_destinationAnnotation;
//}
//@property (nonatomic, strong) FNMapView *mapView;
@end

@implementation CarpoolTravelPendingViewController

- (void)viewDidLoad{
    [super viewDidLoad];
//    self.mapView = [[FNMapView alloc]initWithFrame:self.view.bounds];
//    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    [self.view addSubview:self.mapView];
//    self.mapView.delegate = self;
//    [self.mapView setUserLocation:YES userTrackingModeType:0 annotationImage:[UIImage imageNamed:@"coord_2"]];
//    self.mapView.destinationImage = [UIImage imageNamed:@"coord_1"];
//    [self searchDestination];
}

- (void)dealloc{
//    [FNMapSearch sharedInstance].delegate = nil;
}

#pragma mark - PrivateMethods
- (void)searchDestination{
//    [FNMapSearch sharedInstance].delegate = self;
//    [[FNMapSearch sharedInstance] geocodeSearch:self.carpoolOrder.destinationName city:@"028"];
}
#pragma mark - FNMapViewDelegate
//- (void)userLocationInfor:(MAMapView *)mapView location:(CLLocationCoordinate2D)location success:(BOOL)success{
//    if (!_userAnnotation) {
//        _userAnnotation = [[FNMapAnnotation alloc]init];
//    }
//    if (success && !CLLocationCoordinate2DIsSame(_userAnnotation.coordinate, location)) {
//        _userAnnotation.coordinate = location;
//        if (_destinationAnnotation) {
//            [self.mapView drawingPathPlan:@[_userAnnotation, _destinationAnnotation] isClearMap:NO];
//        }
//    }
//}
#pragma mark - GEOSearchDelegate
//- (void)geocodeSearchDone:(NSArray<FNMapAnnotation *> *)annotations{
//    _destinationAnnotation = [annotations firstObject];
//    [self.mapView addAnnotations:@[_destinationAnnotation]];
//    if (_userAnnotation) {
//        [self.mapView drawingPathPlan:@[_userAnnotation, _destinationAnnotation] isClearMap:NO];
//    }
//}
- (void)navigationSearchDone:(NSDictionary *)dcit{
    
}
@end

#pragma mark - 已取消
@interface CarpoolTravelCancelViewController()

@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UILabel *lblStartName;
@property (weak, nonatomic) IBOutlet UILabel *lblDestinationName;
@property (weak, nonatomic) IBOutlet UITextField *tfStartTime;
@property (weak, nonatomic) IBOutlet UITextField *tfStation;
@property (weak, nonatomic) IBOutlet UILabel *lblPassengersNum;

@end
@implementation CarpoolTravelCancelViewController
+ (instancetype)instanceFromStoryboard{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"CarpoolTravelCancelViewController"];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"已关闭";
    [self updateUI];
    [self requestOrderDetail];
}
- (void)updateUI{
    if (self.carpoolOrder.comment && [self.carpoolOrder.comment isKindOfClass:[NSString class]] && self.carpoolOrder.comment.length > 0) {
        self.lblDesc.text = self.carpoolOrder.comment;
    }else{
        self.lblDesc.text = @"由于您改变订单，所以自行取消订单。";
    }
    self.lblStartName.text = self.carpoolOrder.startName;
    self.lblDestinationName.text = self.carpoolOrder.destinationName;
    if (self.carpoolOrder.type == CarpoolBusTypeGundong ||
        self.carpoolOrder.type == CarpoolBusTypeGundong2) {
        self.tfStartTime.text = [NSString stringWithFormat:@"%@ %@-%@", [self.carpoolOrder.departure timeStringByFormat:@"yyyy年MM月dd日"], self.carpoolOrder.startTime, self.carpoolOrder.endTime];
    }else{
        self.tfStartTime.text = [NSString stringWithFormat:@"%@ %@", [self.carpoolOrder.departure timeStringByFormat:@"yyyy年MM月dd日"], self.carpoolOrder.departureTime];
    }
    
    if (![self.carpoolOrder.station isKindOfClass:[NSNull class]]) {
        self.tfStation.text = self.carpoolOrder.station;
    }
    
    
    if (!self.tfStation.text || self.tfStation.text.length <= 0) {
        self.tfStation.text = @"无";
    }
}
#pragma mark - HTTP Request
- (void)requestOrderDetail{
    if (!self.carpoolOrder || !self.carpoolOrder.orderId) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CarpoolOrderDetail params:^(NetParams *params) {
        params.data = @{@"orderId":self.carpoolOrder.orderId};
    }];
}
#pragma mark - Request Callback
- (void)httpRequestFinished:(NSNotification *)notification{
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    [self stopWait];
    if (type == FNUserRequestType_CarpoolOrderDetail) {
        if (resultData.resultCode == 0) {
            // 查询状态成功
            CarpoolOrderItem *orderItem = [[CarpoolOrderItem alloc]initWithDictionary:resultData.data[@"data"]];
            if (orderItem) {
                self.carpoolOrder = orderItem;
                [self updateUI];
            }
        }
    }
    DBG_MSG(@"%@", notification.object);
}
@end

#pragma mark - 
@interface CarpoolTravelRatingViewController()<RatingBarDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet RatingBar *rateBus;
@property (weak, nonatomic) IBOutlet RatingBar *rateDriver;
@property (weak, nonatomic) IBOutlet UILabel *lblHistoryScoreBus;
@property (weak, nonatomic) IBOutlet CPTextViewPlaceholder *tfRateBus;
@property (weak, nonatomic) IBOutlet UILabel *lblHistoryScoreDriver;
@property (weak, nonatomic) IBOutlet CPTextViewPlaceholder *tfRateDriver;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTextfieldBus;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightTextfieldDriver;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContent;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIScrollView *svBanner;
@property (weak, nonatomic) IBOutlet UIPageControl *pcBanner;
@property (weak, nonatomic) IBOutlet SubmitStyleButton *btnSubmit;

@property (nonatomic, strong) OrderReview *orderReview;
@end
@implementation CarpoolTravelRatingViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initUI];
    [self requestReview];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
}
#pragma mark - Actions
- (IBAction)actionViewDetail:(UIButton *)sender {
}

- (IBAction)actionGetInvoice:(UIButton *)sender {
}
- (IBAction)actionSubmit:(UIButton *)sender {
    if (!self.carpoolOrder || !self.carpoolOrder.orderId) {
        return;
    }
    
    if (self.tfRateBus.text && ![self.tfRateBus.text isEqualToString:self.tfRateBus.placeholder]) {
    }else{
        [self showTip:@"对此次行程说点什么吧～" WithType:FNTipTypeWarning hideDelay:1.5];
        return;
    }

    [NetManagerInstance sendRequstWithType:FNUserRequestType_Rating params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        params.data = @{@"driverScores":  @(self.rateBus.rating),
                        @"orderType":     @(2),
                        @"orderId":       self.carpoolOrder.orderId,
                        @"driverContent": self.tfRateBus.text};
    }];
}
#pragma mark - RequestMethods
- (void)requestReview{
    if (!self.carpoolOrder || !self.carpoolOrder.orderId) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CharterOrderReviewsList params:^(NetParams *params) {
        params.data = @{@"type":@(2),               //type    1包车 2 拼车
                        @"orderId":self.carpoolOrder.orderId};
    }];
}
#pragma mark - PrivateMethods
- (void)setUpTextView:(CPTextViewPlaceholder *)tv{
    tv.placeholder = @"请输入评价内容, 最多50字";
    tv.editable = YES;
    tv.clipsToBounds = YES;
    tv.layer.cornerRadius = 3;
    tv.layer.masksToBounds = YES;
    tv.layer.borderWidth = 0.6;
    tv.layer.borderColor = [UIColorFromRGB(0xFF9E05) CGColor];
    tv.returnKeyType = UIReturnKeyDone;
    tv.delegate = self;
}
-(void)initUI{
    [self.rateBus setImageDeselected:@"star_nor" halfSelected:@"" fullSelected:@"star_press" andDelegate:self];
    [self.rateDriver setImageDeselected:@"star_nor" halfSelected:@"" fullSelected:@"star_press" andDelegate:self];

    [self setUpTextView:self.tfRateBus];
    [self setUpTextView:self.tfRateDriver];
    
    self.lblPrice.text = [NSString stringWithFormat:@"%@元", @(self.carpoolOrder.price / 100)];
    [self.btnSubmit setTitle:@"已评价" forState:UIControlStateDisabled];

}

- (void)setupReviewInfo{
    self.pcBanner.numberOfPages = self.orderReview.vehiclePhotos.count;
    [self.svBanner.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.orderReview.vehiclePhotos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(idx * self.view.frame.size.width, 0, self.view.frame.size.width, self.svBanner.frame.size.height)];
        [iv sd_setImageWithURL:[NSURL URLWithString:obj]];
        [self.svBanner addSubview:iv];
    }];
    self.svBanner.contentSize = CGSizeMake(self.view.bounds.size.width * self.orderReview.vehiclePhotos.count, self.svBanner.bounds.size.height);
    self.lblHistoryScoreBus.text = [NSString stringWithFormat:@"历史评分:%.1f", self.orderReview.vehicleScores];
//    if (self.orderReview && self.orderReview.vehicleAppraises && self.orderReview.vehicleAppraises.count > 0) {
//        ReviewItem *busReview = self.orderReview.vehicleAppraises[0];
//        
//        [self.rateBus displayRating:busReview.appraiseLevel];
//        self.rateBus.isIndicator = YES;
//        self.tfRateBus.text = busReview.content;
//        self.tfRateBus.editable = NO;
//        self.heightTextfieldBus.constant = 100;
//        [self.view layoutIfNeeded];
//    }
    
    if (self.orderReview && self.orderReview.driverAppraises && self.orderReview.driverAppraises.count > 0) {
        ReviewItem *driverReview = self.orderReview.driverAppraises[0];

        [self.rateBus displayRating:driverReview.appraiseLevel];
        self.rateBus.isIndicator = YES;
        self.tfRateBus.text = driverReview.content;
        self.tfRateBus.editable = NO;
        self.heightTextfieldBus.constant = 100;
        [self.view layoutIfNeeded];
//        [self.rateDriver displayRating:driverReview.appraiseLevel];
//        self.rateDriver.isIndicator = YES;
//        self.tfRateDriver.text = driverReview.content;
//        self.tfRateDriver.editable = NO;
//        self.heightTextfieldDriver.constant = 100;
//        [self.view layoutIfNeeded];
    }
    
    self.btnSubmit.hidden = self.orderReview.isAppraiseDriver;
    
//    if (self.orderReview.isAppraiseDriver && self.orderReview.isAppraiseVehicle) {
//        self.btnSubmit.enabled = NO;
//        self.btnSubmit.alpha = 0.5;
//    }else{
//        self.btnSubmit.enabled = YES;
//        self.btnSubmit.alpha = 1;
//    }
}
- (void)textViewResignFirstResponder{
    [self.tfRateBus resignFirstResponder];
    [self.tfRateDriver resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
        self.bottomContent.constant = 0;
        [self.view layoutIfNeeded];
    }];
}
#pragma mark - Textview Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text rangeOfString:@"\n"].location != NSNotFound) {
        [self textViewResignFirstResponder];
        return NO;
    }
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView{
    self.bottomContent.constant = 140;
    [self.view layoutIfNeeded];
    
    CGRect visibleRect = CGRectOffset([textView.superview convertRect:textView.superview.bounds toView:self.scrollView], 0, 100);
    
    [self.scrollView scrollRectToVisible:visibleRect animated:YES];
}
#pragma mark - Rating bar delegate
- (void)ratingBar:(RatingBar*)ratingBar newRating:(float)newRating{
    if (ratingBar == self.rateBus) {
        if (self.heightTextfieldBus.constant == 0) {
            [UIView animateWithDuration:0.25 animations:^{
                self.heightTextfieldBus.constant = 200;
                [self.view layoutIfNeeded];
            }];
        }
    }else if (ratingBar == self.rateDriver){
        if (self.heightTextfieldDriver.constant == 0) {
            [UIView animateWithDuration:0.25 animations:^{
                self.heightTextfieldDriver.constant = 200;
                [self.view layoutIfNeeded];
            }];
        }
    }
}
#pragma mark - ScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.pcBanner.currentPage = page;
}
#pragma mark - HTTP Response
- (void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    NSDictionary *result = resultData.data;
    
    if (type == FNUserRequestType_CharterOrderReviewsList) {
        
        if (resultData.resultCode == 0) {
            self.orderReview = [[OrderReview alloc]initWithDictionary:result];
            [self setupReviewInfo];
        }else{
            [self showTip:resultData.message WithType:FNTipTypeFailure hideDelay:1.5];
        }
    }else if (type == FNUserRequestType_Rating){
        if (resultData.resultCode == 0) {
            [self showTip:@"评价成功！" WithType:FNTipTypeSuccess];
            [self requestReview];
        }else{
            [self showTip:resultData.message WithType:FNTipTypeFailure hideDelay:1.5];
        }
    }
}

@end
