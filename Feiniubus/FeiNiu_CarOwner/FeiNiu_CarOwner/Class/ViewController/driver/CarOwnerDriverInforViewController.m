//
//  CarOwnerDriverInforViewController.m
//  FeiNiu_CarOwner
//
//  Created by 易达飞牛 on 15/8/11.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "CarOwnerDriverInforViewController.h"
#import <FNUIView/RatingBar.h>
#import <FNNetInterface/UIImageView+AFNetworking.h>
#import "ProtocolCarOwner.h"
#import "CarOwnerDriverTaskDetailsViewController.h"

@interface CarOwnerDriverInforViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    /*司机的统计信息*/
    //收入
    float income;
    //里程
    float mileage;
    //订单数
    int orderAmount;
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end

@implementation CarOwnerDriverInforViewController

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
    [_mainTableView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
    
    //获取司机的统计信息
    [self startWait];
    NSMutableDictionary *requestDic = [[NSMutableDictionary alloc] init];
    [requestDic setObject:_driverModel.driverId forKey:@"driverId"];
    [[ProtocolCarOwner sharedInstance] getInforWithNSDictionary:requestDic urlSuffix:Kurl_driverStatistics requestType:KRequestType_driverStatistics];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *tempControl = segue.destinationViewController;
    if ([tempControl isKindOfClass:[CarOwnerDriverTaskDetailsViewController class]]) {
        ((CarOwnerDriverTaskDetailsViewController*)tempControl).driverId = _driverModel.driverId;
    }
}

- (IBAction)taskDetailClick:(id)sender {
    [self performSegueWithIdentifier:@"toTaskDetails" sender:self];
}


#pragma mark ----

-(void)initInterface
{
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    
}

#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 175.f;
            break;
        case 1:
            return 48.f;
            break;
        default:
            break;
    }
    return 1.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.f;
    }
    return 10.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
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
    switch (section) {
        case 0:
        {
            return 1;
        }
            break;
        case 1:
        {
            return 5;
        }
            break;
        default:
            break;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tempCell = nil;
    switch (indexPath.section) {
        case 0:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"driverHeardCellIdent"];
            //头像
            UIImageView *headImageView = (UIImageView*)[tempCell viewWithTag:101];
            [headImageView setImageWithURL:[NSURL URLWithString:[[NSString alloc] initWithFormat:@"%@%@",KImageDonwloadAddr,_driverModel.driverHead]]];
            headImageView.layer.masksToBounds = YES;
            headImageView.layer.cornerRadius = headImageView.frame.size.width / 2;
            headImageView.clipsToBounds = YES;
            //姓名
            UILabel *nameLabel = (UILabel*)[tempCell viewWithTag:102];
            nameLabel.text = _driverModel.driverName;
            //评分
            UILabel *scoreLabel = (UILabel*)[tempCell viewWithTag:103];
            scoreLabel.text = [[NSString alloc] initWithFormat:@"%.1f分",_driverModel.driverRating];
            
            //星级
            RatingBar *tempRatingBar = (RatingBar*)[tempCell viewWithTag:104];
            tempRatingBar.interval = 2;
            [tempRatingBar setImageDeselected:@"small_star_nor_ white" halfSelected:@"small_star_half_ white" fullSelected:@"small_star_press_ white" andDelegate:nil];
            [tempRatingBar setIsIndicator:YES];
            [tempRatingBar displayRating:_driverModel.driverRating];
        }
            break;
        case 1:
        {
            tempCell = [tableView dequeueReusableCellWithIdentifier:@"driverItemCellIdent"];
            UILabel *tempTitle = (UILabel*)[tempCell viewWithTag:101];
            UILabel *tempDetail = (UILabel*)[tempCell viewWithTag:102];
            
            switch (indexPath.row) {
                case 0:
                {
                    tempTitle.text = @"联系电话";
                    tempDetail.text =_driverModel.driverPhone;
                }
                    break;
                case 1:
                {
                    tempTitle.text = @"年龄";
                    tempDetail.text = @"38岁";
                    //计算车龄
                    NSTimeInterval late1=[[DateUtils stringToDate:_driverModel.birthday] timeIntervalSince1970]*1;
                    NSTimeInterval late2=[[NSDate date] timeIntervalSince1970]*1;
                    NSTimeInterval cha=late2-late1;
                    if (cha/(60.0*60.0*24.0*365.0) > 100)
                    {
                        tempDetail.text = @"未填写年龄";
                    }
                    else
                    {
                        tempDetail.text = [[NSString alloc] initWithFormat:@"%.0f%@",cha/(60.0*60.0*24.0*365.0),@"岁"];
                    }
                }
                    break;
                case 2:
                {
                    tempTitle.text = @"安全行驶里程";
//                    tempDetail.text = @"4500km";
                    tempDetail.text = [[NSString alloc] initWithFormat:@"%.2fkm",mileage];
                }
                    break;
                case 3:
                {
                    tempTitle.text = @"司机总收入";
//                    tempDetail.text = @"10000元";
                    tempDetail.text = [[NSString alloc] initWithFormat:@"%.2f元",income];
                }
                    break;
                case 4:
                {
                    tempTitle.text = @"当月完成任务数";
//                    tempDetail.text = @"3";
                    tempDetail.text = [[NSString alloc] initWithFormat:@"%d单",orderAmount];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
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
        case KRequestType_driverStatistics:
        {
            if (resultParse.resultCode == 0)
            {
                income = [[resultParse.data objectForKey:@"income"] floatValue];
                mileage = [[resultParse.data objectForKey:@"mileage"] floatValue];
                orderAmount = [[resultParse.data objectForKey:@"orderAmount"] integerValue];
                
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



