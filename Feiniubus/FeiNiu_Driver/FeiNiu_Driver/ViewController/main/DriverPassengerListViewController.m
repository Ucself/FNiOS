//
//  DriverPassengerListViewController.m
//  FeiNiu_Driver
//
//  Created by 易达飞牛 on 15/9/15.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "DriverPassengerListViewController.h"
#import "ProtocolDriver.h"
#import "DriverCarpoolOrdeMember.h"
#import <FNNetInterface/UIImageView+AFNetworking.h>

@interface DriverPassengerListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@property (nonatomic,strong) NSMutableArray *dataSource;


@end

@implementation DriverPassengerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initInterface];
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

#pragma mark ---
-(void) initInterface
{
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    //设置名称
    self.navigationItem.title = @"乘客明细";
    //iOS 9设置列表未置顶问题
    [_mainTableView remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
    }];
    //请求服务器上的数据
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:_driverTaskModel.scheduleId forKey:@"scheduleId"];
    
    [[ProtocolDriver sharedInstance] getInforWithNSDictionary:requestDic urlSuffix:Kurl_carpoolOrdeMember requestType:KRequestType_carpoolOrdeMember];
}

#pragma mark --- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tempCell;
    tempCell = [tableView dequeueReusableCellWithIdentifier:@"cellIdent"];
    //头像
    UIImageView *headImageView = (UIImageView*)[tempCell viewWithTag:101];
    //姓名
    UILabel *nameLabel = (UILabel*)[tempCell viewWithTag:102];
    //电话号码
    UILabel *phoneLabel = (UILabel*)[tempCell viewWithTag:103];
    //已验证票
    UILabel *ticketsLabel = (UILabel*)[tempCell viewWithTag:104];
    
    DriverCarpoolOrdeMember *driverCarpoolOrdeMember = (DriverCarpoolOrdeMember*)_dataSource[indexPath.row];
    switch (driverCarpoolOrdeMember.ticketsStatus) {
        case 1:
        {
            //未验票
            nameLabel.textColor = UIColorFromRGB(0xFF5A37);
        }
            break;
        case 2:
        {
            //部分验票
            nameLabel.textColor = UIColorFromRGB(0xB4B4B4);
        }
            break;
        case 3:
        {
            //全部验票
            nameLabel.textColor = UIColorFromRGB(0x80CC5A);
        }
            break;
        default:
            break;
    }
    //设置头像
    [headImageView setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,driverCarpoolOrdeMember.memberAvatar]]];
    headImageView.layer.masksToBounds = YES;
    headImageView.layer.cornerRadius = headImageView.frame.size.width / 2;
    headImageView.clipsToBounds = YES;
    //设置姓名
    nameLabel.text = driverCarpoolOrdeMember.memberName;
    //设置电话号码
    phoneLabel.text = driverCarpoolOrdeMember.memberPhone;
    //设置验票情况
    ticketsLabel.text = [[NSString alloc] initWithFormat:@"%d/%d",driverCarpoolOrdeMember.checkedicketsAmount,driverCarpoolOrdeMember.ticketsAmount];
    
    return tempCell;
}

#pragma mark ----UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
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
    ResultDataModel *resultParse = (ResultDataModel *)notification.object;
    
    switch (resultParse.requestType) {
        case KRequestType_carpoolOrdeMember:
        {
            if (resultParse.resultCode == 0)
            {
                _dataSource = [[NSMutableArray alloc] init];
                NSMutableArray *returnArray = [resultParse.data objectForKey:@"list"];
                for (NSDictionary *tempDic in returnArray) {
                    DriverCarpoolOrdeMember *driverCarpoolOrdeMember = [[DriverCarpoolOrdeMember alloc] initWithDictionary:tempDic];
                    [_dataSource addObject:driverCarpoolOrdeMember];
                }
                [_mainTableView reloadData];
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
