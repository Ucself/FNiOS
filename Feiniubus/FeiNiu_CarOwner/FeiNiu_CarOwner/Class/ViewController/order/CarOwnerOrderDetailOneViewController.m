//
//  CarOwnerOrderDetailOneViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/9/2.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerOrderDetailOneViewController.h"
#import "CarOwnerSearchViewController.h"
#import <FNUIView/CustomPickerView.h>
#import "ProtocolCarOwner.h"
#import "GrabOrderResultView.h"

@interface CarOwnerOrderDetailOneViewController ()<UITableViewDelegate,UITableViewDataSource,CustomPickerViewDelegate,CarOwnerSearchViewControllerDelegate,GrabOrderResultViewDelegate>
{
    //是否需要提示抢单是否成功
    BOOL isRequestCharterOrder;
    //弹出框
    GrabOrderResultView *grabOrderResultView;
    
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;


@end

@implementation CarOwnerOrderDetailOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNotification_GrabOrderResult object:nil];
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
    //获取车辆数据
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:_orderModel.startTime forKey:@"startTime"];
    [requestDic setObject:_orderModel.endTime forKey:@"endTime"];
    //默认设置需要提示抢单状态
    isRequestCharterOrder = YES;
    [self startWait];
    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:requestDic urlSuffix:Kurl_vehiclefree requestType:KRequestType_getvehiclefree];
    //注册抢单结果通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushGrabOrderResult:) name:KNotification_GrabOrderResult object:nil];
}

//抢单点击
-(void)grabOrderClick:(id)sender
{
//    [grabOrderResultView showInView:[[UIApplication sharedApplication] keyWindow]];
//    return;
    if (!_vehicleSelectDic) {
        [self showTipsView:@"请选择车辆信息"];
        return;
    }
    if (!_driverSelectDic) {
        [self showTipsView:@"请选择驾驶员信息"];
        return;
    }
    //抢单请求字典
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:_orderModel.subOrderId forKey:@"OrderId"];
    if ([_driverSelectDic objectForKey:@"id"]) {
        [requestDic setObject:[_driverSelectDic objectForKey:@"id"] forKey:@"DriverId"];
    }
    if ([_vehicleSelectDic objectForKey:@"id"]) {
        [requestDic setObject:[_vehicleSelectDic objectForKey:@"id"] forKey:@"VehicleId"];
    }
    //请求抢单数据
    [self startWait];
    [[ProtocolCarOwner sharedInstance] postInforWithNSDictionary:requestDic urlSuffix:Kurl_charterOrderGrab requestType:KRequestType_postCharterOrderGrab];
    isRequestCharterOrder = YES ;
}
//请求抢单结果
-(void)getGrabOrderResult:(id)sender
{
    if (!isRequestCharterOrder) {
        return;
    }
    
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:_orderModel.subOrderId forKey:@"subOrderId"];
    //请求抢单数据
//    [self startWait];
    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:requestDic urlSuffix:Kurl_charterOrder requestType:KRequestType_getCharterGrab];
}

#pragma mark --- GrabOrderResultViewDelegate
//弹出控制器
-(void)submitButtonClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --- CarOwnerSearchViewControllerDelegate
-(void)seachSelected:(NSObject*)seachInfor requestType:(RequestDataType)requestType
{
    self.driverSelectDic = (NSDictionary*)seachInfor;
    [self.mainTableView reloadData];
}

#pragma mark --- CustomPickerViewDelegate
- (void)pickerViewCancel
{
    
}
- (void)pickerViewOK:(int)index useType:(int)useType
{
    _vehicleSelectDic = _vehicleArray[index];
    [self.mainTableView reloadData];
}

#pragma mark --- UITableViewDelegate  toRobOrder

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.section) {
        case 0:
            return 245;
            break;
        case 1:
            return 47;
            break;
        case 2:
            return 243;
            break;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section != 1) {
        return;
    }
    
    switch (indexPath.row) {
        case 0:
        {
            if (!self.vehicleArray || self.vehicleArray.count == 0) {
                [self showTipsView:@"未有空闲车辆"];
                return;
            }
            //            searchViewController.requestType = RequestDataTypeVehicle;
            CustomPickerView *customPickerView = [[CustomPickerView alloc] initWithFrame:self.view.bounds dataSourceArray:self.vehicleArray useType:0];
            
            customPickerView.delegate = self;
            [customPickerView showInView:[[UIApplication sharedApplication] keyWindow]];
            
        }
            break;
        case 1:
        {
            if (!self.driverArray || self.driverArray.count == 0) {
                [self showTipsView:@"未有空闲驾驶员"];
                return;
            }

            //            searchViewControllerId
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Order" bundle:nil];
            CarOwnerSearchViewController *searchViewController = [storyboard instantiateViewControllerWithIdentifier:@"searchViewControllerId"];
            //如果存在对象的时候传入
            if (_orderModel) {
                searchViewController.startTime = _orderModel.startTime;
                searchViewController.endTime = _orderModel.endTime;
            }
            searchViewController.requestType = RequestDataTypeDriver;
            searchViewController.delegate = self;
            //跳转控制器
            [self.navigationController pushViewController:searchViewController animated:YES];
        }
            break;
            
        default:
            break;
    }
    
    
}
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    view.tintColor = [UIColor clearColor];
}
#pragma mark --- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tempCell;
    
    switch (indexPath.section) {
        case 0:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"inforCellIdent"];
            //用车时间
            UILabel *timeLable = (UILabel*)[tempCell viewWithTag:101];
            UILabel *endTimeLable = (UILabel*)[tempCell viewWithTag:1101];
            //用车需求
            UILabel *needLable = (UILabel*)[tempCell viewWithTag:102];
            //里程
            UILabel *mileageLable = (UILabel*)[tempCell viewWithTag:103];
            //起始地
            UILabel *startNameLable = (UILabel*)[tempCell viewWithTag:104];
            //目的地
            UILabel *destinationNameLable = (UILabel*)[tempCell viewWithTag:105];
            //用车价格
            UILabel *priceLable = (UILabel*)[tempCell viewWithTag:106];
            
            NSDate *startDate = [DateUtils stringToDate:_orderModel.startTime];
            NSDate *endDate = [DateUtils stringToDate:_orderModel.endTime];
            
            timeLable.text = [[NSString alloc] initWithFormat:@"%@",[DateUtils formatDate:startDate format:@"yyyy-MM-dd HH:mm"]];
            endTimeLable.text = [[NSString alloc] initWithFormat:@"%@",[DateUtils formatDate:endDate format:@"yyyy-MM-dd HH:mm"]];
            needLable.text = [[NSString alloc] initWithFormat:@"%@%@ 准乘坐%d人 1辆",_orderModel.vehicleTypeName,_orderModel.vehicleLevelName,_orderModel.seats];
            mileageLable.text = [[NSString alloc] initWithFormat:@"%.2fkm",_orderModel.mileage];
            startNameLable.text = [[NSString alloc] initWithFormat:@"%@",_orderModel.startName];
            destinationNameLable.text = [[NSString alloc] initWithFormat:@"%@",_orderModel.destinationName];
            priceLable.text = [[NSString alloc] initWithFormat:@"%.0f元",_orderModel.price/100.f];
        }
            break;
        case 1:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"customCellIdent"];
            if (indexPath.row == 0) {
                tempCell.textLabel.text = @"配置车辆";
                if (_vehicleSelectDic && [_vehicleSelectDic objectForKey:@"name"])
                {
                    tempCell.detailTextLabel.text = [_vehicleSelectDic objectForKey:@"name"];
                }
                else
                {
                    tempCell.detailTextLabel.text = @"请选择车辆";
                }
                
            }
            else if (indexPath.row == 1) {
                tempCell.textLabel.text = @"配置驾驶员";
                if (_driverSelectDic && [_driverSelectDic objectForKey:@"name"])
                {
                    tempCell.detailTextLabel.text = [_driverSelectDic objectForKey:@"name"];
                }
                else
                {
                    tempCell.detailTextLabel.text = @"请选择驾驶员";
                }
                
            }
        }
            break;
        case 2:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"buttonCellIdent"];
            //抢单按钮
            UIButton *grabOrderButton = (UIButton*)[tempCell viewWithTag:101];
            //注册点击事件
            [grabOrderButton addTarget:self action:@selector(grabOrderClick:) forControlEvents:UIControlEventTouchUpInside];
            
        }
            break;
        default:
            break;
    }
    
    return tempCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

#pragma mark --- http request handler
/**
 *  请求返回成功
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFinished:(NSNotification *)notification
{
    //    [super httpRequestFinished:notification];
    
    ResultDataModel *resultParse = (ResultDataModel*)notification.object;
    
    switch (resultParse.requestType) {
        case KRequestType_getvehiclefree:
        {
//            [self stopWait];
            if (resultParse.resultCode == 0) {
                //
                _vehicleArray = [[NSMutableArray alloc] init];
                NSMutableArray *returnArray = (NSMutableArray*)[resultParse.data objectForKey:@"data"];
                //车辆信息
                for (NSDictionary *tempDic in returnArray) {
                    NSString *vehicleId = [tempDic objectForKey:@"id"] ? [tempDic objectForKey:@"id"] : @"";
                    NSString *licensePlate = [tempDic objectForKey:@"licensePlate"] ? [tempDic objectForKey:@"licensePlate"] : @"";
                    
                    NSMutableDictionary *vehicleDic = [[NSMutableDictionary alloc] init];
                    [vehicleDic setObject:vehicleId forKey:@"id"];
                    [vehicleDic setObject:licensePlate forKey:@"name"];
                    
                    //添加到数组
                    [self.vehicleArray addObject:vehicleDic];
                }
                //默认选中第一个
                if (_vehicleArray.count > 0) {
                    _vehicleSelectDic = _vehicleArray[0];
                    //重新刷新一下
                    [_mainTableView reloadData];
                }
                
            }
            else
            {
                [self showTipsView:@"与服务器数据交互失败"];
            }
            NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
            [requestDic setObject:_orderModel.startTime forKey:@"startTime"];
            [requestDic setObject:_orderModel.endTime forKey:@"endTime"];
            //获取空闲驾驶员
            [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:requestDic urlSuffix:Kurl_driverfree requestType:KRequestType_getdriverfree];
        }
            break;
        case KRequestType_getdriverfree:
        {
            [self stopWait];
            if (resultParse.resultCode == 0) {
                
                _driverArray = (NSMutableArray*)[resultParse.data objectForKey:@"data"];
                //设置默认驾驶员
                if (_driverArray.count > 0) {
                    self.driverSelectDic = _driverArray[0];
                    [_mainTableView reloadData];
                }
                
            }
            else
            {
                [self showTipsView:@"与服务器数据交互失败"];
            }
        }
            break;
            
        case KRequestType_postCharterOrderGrab:
        {
            if (resultParse.resultCode == 0) {
                //20秒过后请求抢单结果
                [self performSelector:@selector(getGrabOrderResult:) withObject:self afterDelay:10.f];
            }
            else
            {
                [self showTipsView:@"与服务器数据交互失败"];
            }
        }
            break;
        case KRequestType_getCharterGrab:
        {
            [self stopWait];
            if (resultParse.resultCode == 0) {
                
                NSString *grabStatus = [resultParse.data objectForKey:@"grabStatus"]?[resultParse.data objectForKey:@"grabStatus"]:@"2";
                
                int iGrabStatus = [grabStatus intValue];
                switch (iGrabStatus) {
                    case 1:
                    {
                        //抢单成功
                        [grabOrderResultView setDisplayType:DisplayTypeSuccess];
                        [grabOrderResultView showInView:[[UIApplication sharedApplication] keyWindow]];
                    }
                        break;
                    case 2:
                    {
                        //抢单失败
                        [grabOrderResultView setDisplayType:DisplayTypeFailure];
                        [grabOrderResultView showInView:[[UIApplication sharedApplication] keyWindow]];
                    }
                        break;
                    case 3:
                    {
                        //订单还在等待中
                        [grabOrderResultView setDisplayType:DisplayTypeFailure];
                        [grabOrderResultView showInView:[[UIApplication sharedApplication] keyWindow]];
                    }
                        break;
                    default:
                    {
                        //其他未知信息
                        [grabOrderResultView setDisplayType:DisplayTypeFailure];
                        [grabOrderResultView showInView:[[UIApplication sharedApplication] keyWindow]];
                    }
                        break;
                }
            }
            else if (resultParse.resultCode == 100006)
            {
                [grabOrderResultView setDisplayType:DisplayTypeFailure];
                [grabOrderResultView showInView:[[UIApplication sharedApplication] keyWindow]];
            }
            else
            {
                //服务器未知错误
                [grabOrderResultView setDisplayType:DisplayTypeFailure];
                [grabOrderResultView showInView:[[UIApplication sharedApplication] keyWindow]];
            }
            //此单已提示不需要再提升
            isRequestCharterOrder = NO;
            
        }
            break;
            
        default:
            break;
    }
    
}
/**
 *  请求返回失败
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}


#pragma mark ---KNotification_GrabOrderResult
//推送过来的通知
-(void)pushGrabOrderResult:(NSNotification*)notification
{
    //不需要提示，不接受推送数据
    if (!isRequestCharterOrder) {
        return;
    }
    [self stopWait];
    NSDictionary *resultDic = notification.object;
    //如果收到的不是当前订单的推送直接返回
    if (![[resultDic objectForKey:@"orderId"] isEqualToString:_orderModel.subOrderId]) {
        return;
    }
    
    //根据推送信息弹出相应界面
    if (resultDic) {
        NSString *resultStatus = [resultDic objectForKey:@"result"] ? [resultDic objectForKey:@"result"] :@"";
        if ([resultStatus isEqualToString:@"true"]) {
            [grabOrderResultView setDisplayType:DisplayTypeSuccess];
            [grabOrderResultView showInView:[[UIApplication sharedApplication] keyWindow]];
        }
        else
        {
            [grabOrderResultView setDisplayType:DisplayTypeFailure];
            [grabOrderResultView showInView:[[UIApplication sharedApplication] keyWindow]];
        }
    }
    isRequestCharterOrder = NO;
}
@end










