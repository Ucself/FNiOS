//
//  CarOwnerOrderDetailTwoViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/2.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerOrderDetailTwoViewController.h"
#import <FNUIView/CircleProgressView.h>
#import <FNCommon/DateUtils.h>
#import "GrabOrderResultView.h"

@interface CarOwnerOrderDetailTwoViewController ()<UITableViewDelegate,UITableViewDataSource,GrabOrderResultViewDelegate>
{
    CircleProgressView *circleProgressView;
    //总秒数
    int totalSeconds;
    //开始秒数
    int startSecond;
    //计时器
    NSTimer *timer;
    //提示付款弹出框
    GrabOrderResultView *grabOrderResultView;
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

//开始时间
@property (nonatomic, retain) NSDate * startDate;
//结束时间
@property (nonatomic, retain) NSDate * finishDate;

@end

@implementation CarOwnerOrderDetailTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initInterface];
}

-(void)poolTimer:(id)sender
{
    //主线程更新UI
    startSecond = startSecond + 1;
    if (startSecond <= totalSeconds) {
        circleProgressView.elapsedTime = startSecond;
    }
    else
    {
        [timer invalidate];
        //支付超时
        [grabOrderResultView setDisplayType:DisplayTypeSuccess];
        grabOrderResultView.tipFirstInfor.text = @"支付超时";
        grabOrderResultView.tipSecondInfor.text = @"订单已取消";
        [grabOrderResultView.submitButton setTitle:@"回到任务列表" forState:UIControlStateNormal];
        [grabOrderResultView showInView:[[UIApplication sharedApplication] keyWindow]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //ios7下布局修正问题
    [_mainTableView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(46);
    }];
}

-(void)dealloc
{
    //注销通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_OrderPayResult object:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark ---

-(void) initInterface
{
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    
    //弹出框对象
    grabOrderResultView =  (GrabOrderResultView*)[[NSBundle mainBundle] loadNibNamed:@"GrabOrderResultView" owner:nil options:nil][0];
    grabOrderResultView.delegate = self;
    //注册用户付款通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushOrderPayResult:) name:KNotification_OrderPayResult object:nil];
}
//执行通知
-(void)pushOrderPayResult:(NSNotification*)notification
{
    NSDictionary *resultDic = notification.object;
    //如果收到的不是当前订单的推送直接返回
    if (![[resultDic objectForKey:@"orderId"] isEqualToString:_taskModel.subOrderId]) {
        return;
    }
    //推送付款情况
    if ([resultDic objectForKey:@"state"] && [[resultDic objectForKey:@"state"] isEqualToString:@"1"])
    {
        [timer invalidate];
        //完成付款
        [grabOrderResultView setDisplayType:DisplayTypeSuccess];
        grabOrderResultView.tipFirstInfor.text = @"付款成功";
        grabOrderResultView.tipSecondInfor.text = @"用户已付款";
        [grabOrderResultView.submitButton setTitle:@"回到任务列表" forState:UIControlStateNormal];
        [grabOrderResultView showInView:[[UIApplication sharedApplication] keyWindow]];
    }
    else if ([resultDic objectForKey:@"state"] && [[resultDic objectForKey:@"state"] isEqualToString:@"2"])
    {
        [timer invalidate];
        //用户未付款
        [grabOrderResultView setDisplayType:DisplayTypeFailure];
        grabOrderResultView.tipFirstInfor.text = @"订单取消";
        grabOrderResultView.tipSecondInfor.text = @"用户已取消订单";
        [grabOrderResultView.submitButton setTitle:@"回到任务列表" forState:UIControlStateNormal];
        [grabOrderResultView showInView:[[UIApplication sharedApplication] keyWindow]];
    }
}

#pragma mark --- GrabOrderResultViewDelegate

-(void)submitButtonClick:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark --- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tempCell;
    
    switch (indexPath.section) {
        case 0:
        {
            //circleProgressView
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"waitingCellIdent"];
            circleProgressView = (CircleProgressView*)[tempCell viewWithTag:101];
            timer = [NSTimer scheduledTimerWithTimeInterval:1.00
                                                     target:self
                                                   selector:@selector(poolTimer:)
                                                   userInfo:nil
                                                    repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
            //总秒数
            _startDate = [DateUtils stringToDate:_taskModel.waitStartTime];
            NSDate *date = [NSDate date];
            NSTimeZone *zone = [NSTimeZone systemTimeZone];
            NSInteger interval = [zone secondsFromGMTForDate: date];
            NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
            _finishDate = localeDate;
            //相隔秒数
            long timeInterval = (long)[_finishDate timeIntervalSince1970] - [_startDate timeIntervalSince1970];
            totalSeconds  = 30 *60;
            timeInterval= timeInterval % totalSeconds;
            
            circleProgressView.timeLimit = totalSeconds;
            circleProgressView.elapsedTime = timeInterval;
            startSecond = timeInterval;
            circleProgressView.status = @"等待时间";
            circleProgressView.tintColor = [UIColor colorWithRed:240.0/255.0 green:85.0/255.0 blue:60.0/255.0 alpha:1.0];
            circleProgressView.tintColor = [UIColor redColor];
            
        }
            
            break;
        case 1:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"inforCellIdent"];
            //忘返时间
            NSDate *startDate = [DateUtils stringToDate:_taskModel.startTime];
            NSDate *endDate = [DateUtils stringToDate:_taskModel.endTime];
            
            UILabel *startTimeLabel = (UILabel*)[tempCell viewWithTag:101];
            startTimeLabel.text = [[NSString alloc] initWithFormat:@"%@",[DateUtils formatDate:startDate format:@"yyyy-MM-dd HH:mm"]];
            UILabel *endTimeLabel = (UILabel*)[tempCell viewWithTag:111];
            endTimeLabel.text = [[NSString alloc] initWithFormat:@"%@",[DateUtils formatDate:endDate format:@"yyyy-MM-dd HH:mm"]];
            //车辆信息
            UILabel *vehicleInforLabel = (UILabel*)[tempCell viewWithTag:102];
            vehicleInforLabel.text = [[NSString alloc] initWithFormat:@"%@%@ 准乘坐%d人 一辆",_taskModel.vehicleTypeName,_taskModel.vehicleLevelName,_taskModel.seats];
            //里程
            UILabel *mileageLabel = (UILabel*)[tempCell viewWithTag:103];
            mileageLabel.text = [[NSString alloc] initWithFormat:@"%.0fkm",_taskModel.mileage];
            //车辆牌照
            UILabel *licensePlateLabel = (UILabel*)[tempCell viewWithTag:104];
            licensePlateLabel.text = [[NSString alloc] initWithFormat:@"%@",_taskModel.licensePlate];
            //司机信息
            UILabel *driverInforLabel = (UILabel*)[tempCell viewWithTag:105];
            driverInforLabel.text = [[NSString alloc] initWithFormat:@"%@ %@",_taskModel.driverName,_taskModel.driverPhone];
            //起始地
            UILabel *startNameLabel = (UILabel*)[tempCell viewWithTag:106];
            startNameLabel.text = [[NSString alloc] initWithFormat:@"%@",_taskModel.startName];
            //目的地
            UILabel *destinationNameLabel = (UILabel*)[tempCell viewWithTag:107];
            destinationNameLabel.text = [[NSString alloc] initWithFormat:@"%@",_taskModel.destinationName];
            //预估价格
            UILabel *priceLabel = (UILabel*)[tempCell viewWithTag:108];
            priceLabel.text = [[NSString alloc] initWithFormat:@"%.0f元",_taskModel.price/100.f];
        }
            
            break;
        default:
            break;
    }
    
    return tempCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

#pragma mark --- UITableViewDelegate toSeach
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 180.f;
            break;
        case 1:
            return 315.f;
            break;
        default:
            break;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
}
@end








