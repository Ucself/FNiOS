//
//  LeftDrawerViewController.m
//  CourseDemoSummary
//
//  Created by DreamHack on 15-7-10.
//  Copyright (c) 2015年 DreamHack. All rights reserved.
//

#import "LeftDrawerViewController.h"
#import "ProtocolDriver.h"
#import "DriverPreferences.h"

@interface LeftDrawerViewController ()

@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation LeftDrawerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化界面相关绘制
    [self initInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //请求司机个人信息
    [self startWait];
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:[[DriverPreferences sharedInstance] getUserId] ? [[DriverPreferences sharedInstance] getUserId] :@"" forKey:@"driverId"];
    [[ProtocolDriver sharedInstance] getInforWithNSDictionary:requestDic urlSuffix:Kurl_driverStatistics requestType:KRequestType_driverStatistics];
}

-(void) initInterface
{
    //设置背景色
    [self.view setBackgroundColor:UIColorFromRGB(0x333333)];
    //设置边框
    self.leftView.layer.borderWidth = 0.5f;
    self.leftView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //设置边框
    self.rightView.layer.borderWidth = 0.5f;
    self.rightView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //查看布局
    //    [_backgroundView setBackgroundColor:[UIColor redColor]];
    //设置宽度
    [_backgroundView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(deviceWidth*0.65);
        make.height.equalTo(deviceHeight*0.85 + 62);
    }];
    
    
    
}

- (IBAction)changeAccountClick:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //登录相关控制器
    UINavigationController *loginNav = [storyboard instantiateViewControllerWithIdentifier:@"loginNavControllerId"];
    //先进入登录进行测试
    [self.navigationController presentViewController:loginNav animated:YES completion:nil];
    
    //鉴权失效重置token
    [[EnvPreferences sharedInstance] setToken:nil];
    [[EnvPreferences sharedInstance] setUserId:nil];
    //重置注册
    [[PushConfiguration sharedInstance] resetTagAndAlias];
//    //注册通知别名
//    [[PushConfiguration sharedInstance] resetAlias];
//    [[PushConfiguration sharedInstance] resetTag];
}

#pragma mark --- http request handler
/**
 *  请求返回成功
 *
 *  @param notification 通知回调
 */
-(void)httpRequestFinished:(NSNotification *)notification
{
    //不使用基类的完成
    //    [super httpRequestFinished:notification];
    
    ResultDataModel *resultParse = (ResultDataModel *)notification.object;
    
    switch (resultParse.requestType) {
        case KRequestType_driverStatistics:
        {
            //清除等待加载
//            [self stopWait];
            if (resultParse.resultCode == 0)
            {
                _mileage = [resultParse.data objectForKey:@"mileage"] ? [[resultParse.data objectForKey:@"mileage"] floatValue] : 0.00;
                _orderAmount = [resultParse.data objectForKey:@"orderAmount"] ? [[resultParse.data objectForKey:@"orderAmount"] intValue] : 0;
                
                _mileageLabel.text = [[NSString alloc] initWithFormat:@"%.2fkm",_mileage];
                _orderAmountLabel.text = [[NSString alloc] initWithFormat:@"%d单",_orderAmount];
                //再去请求用户信息数据
                [[ProtocolDriver sharedInstance] getInforWithNSDictionary:[NSDictionary new] urlSuffix:KUrl_MemberInfo requestType:KRequestType_memberinfo];
            }
            else
            {
                [self showTipsView:@"与服务器数据交互失败"];
            }
        }
            break;
            
        case KRequestType_memberinfo:
        {
            //清除等待加载
            [self stopWait];
            if (resultParse.resultCode == 0)
            {
                //返回的司机数据
                if ([resultParse.data objectForKey:@"driver"] && [[resultParse.data objectForKey:@"driver"] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *driverDic = [resultParse.data objectForKey:@"driver"];
                    _nameLabel.text = [driverDic objectForKey:@"name"] ? [driverDic objectForKey:@"name"] :@"****";
                }
            }
            else
            {
                [self showTipsView:@"与服务器数据交互失败"];
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
