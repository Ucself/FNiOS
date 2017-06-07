//
//  CarOwnerVehicleInforViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerVehicleInforViewController.h"
#import <FNUIView/CustomAlertView.h>
#import "ProtocolCarOwner.h"
#import "CarOwnerTaskDetailsViewController.h"

@interface CarOwnerVehicleInforViewController ()<UITableViewDelegate,UITableViewDataSource,CustomAlertViewDelegate>
{
    //车辆状态选择器
    UISwitch *stateSwitch;
    //当日期望毛利
    UILabel *priceLabel;
    
    /*车辆的统计信息*/
    //收入
    float income;
    //里程
    float mileage;
    //订单数
    int orderAmount;
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;


@end

@implementation CarOwnerVehicleInforViewController

@dynamic delegate;

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
    //请求车辆统计信息
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:_vehicleModel.vehicleId forKey:@"vehicleId"];
    
    [self startWait];
    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:requestDic urlSuffix:Kurl_vehicleStatistics requestType:KRequestType_vehicleStatistics];
    //iOS7设置到底部
    [_mainTableView makeConstraints:^(MASConstraintMaker *make) {
       
        make.bottom.equalTo(self.view.bottom).offset(46);
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//下一个控制器传参数
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    CarOwnerTaskDetailsViewController *taskDetailsViewController = [segue destinationViewController];
    UIViewController *taskDetailsViewController = [segue destinationViewController];
    //如果跳入的是车辆任务详情
    if ([taskDetailsViewController isKindOfClass:[CarOwnerTaskDetailsViewController class]]) {
        ((CarOwnerTaskDetailsViewController*)taskDetailsViewController).vehicleId = _vehicleModel.vehicleId;
    }
}


- (IBAction)taskDetailClick:(id)sender {
    [self performSegueWithIdentifier:@"toTaskDetail" sender:self];
}


#pragma mark ---
-(void) initInterface
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
}

-(void)btnBackClick:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(controllerReturnBack)]) {
        [self.delegate controllerReturnBack];
    }
    [super btnBackClick:sender];
}

#pragma mark -- UISwitchClick
//点击开关选择器
-(void)switchValueChanged:(id)sender
{
    UISwitch * tempSwitch = (UISwitch *)sender;
    
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:_vehicleModel.vehicleId forKey:@"id"];
    [requestDic setObject:tempSwitch.on ? @"1" : @"2" forKey:@"status"];
    NSString *urlSuffixString = [[NSString alloc] initWithFormat:@"%@?id=%@&status=%@",Kurl_vehicleStatus,_vehicleModel.vehicleId,tempSwitch.on ? @"1" : @"2"];
    //请求修改数据
    [[ProtocolCarOwner sharedInstance] putInforWithNSDictionary:[NSDictionary new] urlSuffix:urlSuffixString requestType:KRequestType_vehicleStatus];
}

#pragma mark --- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 9;
            break;
        default:
            break;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * tempCell;
    
    switch (indexPath.section) {
        case 0:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"vehicleStateIdent"];
            stateSwitch = (UISwitch*)[tempCell viewWithTag:101];
            //添加点击事件
            [stateSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventTouchUpInside];
            if (_vehicleModel.state == 1)
            {
                [stateSwitch setOn:YES animated:YES];
            }
            else
            {
                [stateSwitch setOn:NO animated:YES];
            }
        }
            break;
        case 1:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"vehicleProfitIdent"];
            //价格填写
            priceLabel = (UILabel*)[tempCell viewWithTag:101];
            priceLabel.text = [[NSString alloc] initWithFormat:@"%.0f%@",_vehicleModel.lastQuotation/100.f,@"元"];
        }
            break;
        case 2:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"vehicleListInforIdent"];
            UILabel *nameLabel = (UILabel*)[tempCell viewWithTag:101];
            UILabel *inforLabel = (UILabel*)[tempCell viewWithTag:102];
            switch (indexPath.row) {
                case 0:
                {
                    nameLabel.text = @"公司名称";
                    inforLabel.text = [[NSString alloc] initWithFormat:@"%@",_vehicleModel.companyName];
                    
                }
                    break;
                case 1:
                {
                    nameLabel.text = @"经营范围";
                    inforLabel.text = [[NSString alloc] initWithFormat:@"%@",_vehicleModel.businessScopeName];
                }
                    break;
                case 2:
                {
                    nameLabel.text = @"车辆牌照";
                    inforLabel.text = [[NSString alloc] initWithFormat:@"%@",_vehicleModel.licensePlate];
                }
                    break;
                case 3:
                {
                    nameLabel.text = @"座位数";
                    inforLabel.text = [[NSString alloc] initWithFormat:@"%d座",_vehicleModel.seats];
                }
                    break;
                case 4:
                {
                    nameLabel.text = @"类型等级";
                    inforLabel.text = [[NSString alloc] initWithFormat:@"%@%@",_vehicleModel.typeName,_vehicleModel.levelName];
                }
                    break;
                case 5:
                {
                    nameLabel.text = @"燃油类别";
                    inforLabel.text = [[NSString alloc] initWithFormat:@"%@",_vehicleModel.fuelTypeName];
                }
                    break;
                case 6:
                {
                    nameLabel.text = @"车辆总收入";
                    inforLabel.text = [[NSString alloc] initWithFormat:@"%.2f",income];
                }
                    break;
                case 7:
                {
                    nameLabel.text = @"安全行驶里程";
                    inforLabel.text = [[NSString alloc] initWithFormat:@"%.2fkm",mileage];
                }
                    break;
                case 8:
                {
                    nameLabel.text = @"完成总单数";
                    inforLabel.text = @"10单";
                    inforLabel.text = [[NSString alloc] initWithFormat:@"%d单",orderAmount];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    return tempCell;
}

#pragma mark --- CustomAlertViewDelegate
- (void)customAlertViewCancel
{
    
}
- (void)customAlertViewOK:(NSString*)result  useType:(int)useType
{
    priceLabel.text = [[NSString alloc] initWithFormat:@"%.0f元",[result floatValue]];
    float pricePoints = [result floatValue] * 100;
    //修改单日期望毛利
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:_vehicleModel.vehicleId forKey:@"id"];
    [requestDic setObject:[[NSString alloc] initWithFormat:@"%.0f" ,pricePoints] forKey:@"price"];
    NSString *urlSuffixString = [[NSString alloc] initWithFormat:@"%@?id=%@&price=%@",Kurl_vehiclePrice,_vehicleModel.vehicleId,result];
    //请求修改数据
    [[ProtocolCarOwner sharedInstance] putInforWithNSDictionary:requestDic urlSuffix:Kurl_vehiclePrice requestType:KRequestType_vehiclePrice];
}
#pragma mark --- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        return 51.f;
    }
    return 10.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        UIView *headerView = [[UIView alloc] init];
        headerView.backgroundColor = [UIColor clearColor];
        UIImageView *tempImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vehicleInforLine"]];
        [headerView addSubview:tempImage];
        //布局
        [tempImage makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(15.f);
            make.width.equalTo(2.f);
            make.left.equalTo(headerView.left).offset(15.f);
            make.top.equalTo(headerView.top).offset(22.f);
        }];
        UILabel *tempLabel = [[UILabel alloc] init];
        tempLabel.text = @"车辆信息";
        tempLabel.font = [UIFont boldSystemFontOfSize:15.f];
        [headerView addSubview:tempLabel];
        
        [tempLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tempImage.right).offset(5.f);
            make.centerY.equalTo(tempImage);
            make.right.equalTo(headerView);
        }];
        
        return headerView;
    }
    
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 1:
        {
            //填写车辆牌照
            CustomAlertView *alertView = [[CustomAlertView alloc] initWithFrame:self.view.frame alertName:@"当日期望毛利" alertInputContent:[[NSString alloc] initWithFormat:@"%.0f",_vehicleModel.lastQuotation/100.f] alertUnit:@"元" keyboardType:UIKeyboardTypeNumberPad useType:(int)indexPath.row];
            alertView.delegate = self;
            [alertView.inputDate canResignFirstResponder];
            [alertView showInView:[[UIApplication sharedApplication] keyWindow]];
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark --- http request handler
/**
 *  请求返回成功
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultParse = (ResultDataModel*)notification.object;
    
    switch (resultParse.requestType) {
        case KRequestType_vehicleStatistics:
        {
            if (resultParse.resultCode == 0)
            {
                mileage = [resultParse.data objectForKey:@"mileage"] ? [[resultParse.data objectForKey:@"mileage"] floatValue] : 0.00;
                income = [resultParse.data objectForKey:@"income"] ? [[resultParse.data objectForKey:@"income"] floatValue] : 0.00;
                orderAmount = [resultParse.data objectForKey:@"orderAmount"] ? [[resultParse.data objectForKey:@"orderAmount"] intValue] : 0;
                
                //刷新数据
                [_mainTableView reloadData];
            }
            else
            {
                [self showTipsView:@"与服务器数据交互失败"];
            }
        }
            break;
        case  KRequestType_vehicleStatus:
        {
            //返回值
            if (resultParse.resultCode != 0) {
                if (stateSwitch) {
                    //还原状态
                    stateSwitch.on = !stateSwitch.on;
                }
                [self showTipsView:@"状态修改失败"];
            }
            else
            {
                _vehicleModel.state =  stateSwitch.on ? 1:2;
            }
        }
            break;
        case KRequestType_vehiclePrice:
        {
            if (resultParse.resultCode != 0) {
                if (priceLabel) {
                    priceLabel.text = [[NSString alloc] initWithFormat:@"%.0f元",_vehicleModel.lastQuotation/100.f];
                }
                [self showTipsView:@"车辆报价不能小于0元"];
            }
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

@end

















