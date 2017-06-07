//
//  QueryResultsViewController.m
//  FeiNiu_User
//
//  Created by tianbo on 16/3/14.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "QueryResultsViewController.h"
#import "UINavigationView.h"
#import "QueryTicketResultModel.h"
#import "TicketResultTableViewCell.h"
#import "CreateOrderViewController.h"
#import "AuthorizeCache.h"

@interface QueryResultsViewController ()<UITableViewDataSource,UITableViewDelegate,TicketResultTableViewCellDelegate>{
    
    NSMutableArray *dataSourceArray;
    CreateOrderViewController *createOrderViewController;   //跳转的控制器

}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UINavigationView *navView;
@property (weak, nonatomic) IBOutlet UILabel *ticketDate;

@property (weak, nonatomic) IBOutlet UIButton *beforeDayButton;
@property (weak, nonatomic) IBOutlet UIButton *afterDayButton;


@end

@implementation QueryResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialization];

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

#pragma mark---
//程序初始化需要加载的东西
-(void)initialization
{
    _navView.title = [[NSString alloc] initWithFormat:@"%@ - %@",
                      [_originData objectForKey:@"name"]?[_originData objectForKey:@"name"]:@"",
                      [_destinationData objectForKey:@"name"]? [_destinationData objectForKey:@"name"]:@""];
    
    _ticketDate.layer.borderColor = UIColorFromRGB(0xFE6E35).CGColor;
    _ticketDate.layer.borderWidth = 1.f;
    
    [self requestMoreTickets];
}

- (IBAction)beforeDayClick:(id)sender {
    
    self.setOutDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([_setOutDate timeIntervalSinceReferenceDate] - 24*3600)];
    [self requestMoreTickets];
}

- (IBAction)afterDayClick:(id)sender {
    self.setOutDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([_setOutDate timeIntervalSinceReferenceDate] + 24*3600)];;
    [self requestMoreTickets];
}
/**
 *  请求余票
 */
-(void)requestMoreTickets
{
    _ticketDate.text = _setOutDate ? [DateUtils formatDate:_setOutDate format:@"yyyy-MM-dd"]:@"";
    [self startWait];
    //获取订票时间范围
    [NetManagerInstance sendRequstWithType:EmRequestType_BookingTickets params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
        params.data = @{@"startAdcode":[_originData objectForKey:@"adcode"] ? [_originData objectForKey:@"adcode"] :@"" ,
                        @"endAdcode":[_destinationData objectForKey:@"adcode"] ? [_destinationData objectForKey:@"adcode"] :@"",
                        @"date":[DateUtils formatDate:_setOutDate format:@"yyyy-MM-dd"]};
    }];
}


#pragma mark - uitableview delegate mothed
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QueryTicketResultModel *queryTicketResultModel = dataSourceArray[indexPath.row];
    //没有优惠卷
    if (queryTicketResultModel.couponIoc == 0) {
        return 100;
    }
    
    return 130;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QueryTicketResultModel *queryTicketResultModel = dataSourceArray[indexPath.row];
    TicketResultTableViewCell *cell;
    //没有优惠卷
    if (queryTicketResultModel.couponIoc == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"resultCell"];
    }
    else  {
        cell = [tableView dequeueReusableCellWithIdentifier:@"resultCouponCell"];
        cell.couponLabel.text = queryTicketResultModel.coupon;
    }
    
    cell.queryTicketResultModel = queryTicketResultModel;
    cell.typeLabel.text = queryTicketResultModel.type == 3? @"滚动发班" : @"";   //2定时，3滚动
    cell.startSiteLabel.text = queryTicketResultModel.startSite;
    if (queryTicketResultModel.type == 3) {
        cell.timeLabel.text = [[NSString alloc] initWithFormat:@"%@前有效",queryTicketResultModel.time];
    }
    else{
        cell.timeLabel.text = [[NSString alloc] initWithFormat:@"%@",queryTicketResultModel.time];
    }
    MyRange *range1 = [[MyRange alloc] init];
    range1.location = 0;
    range1.length   = 2;
    cell.remainedTicketLabel.attributedText = [NSString hintMainString:[[NSString alloc] initWithFormat:@"余票%d张",queryTicketResultModel.remainedTicket]
                                                                 rangs:[@[range1] mutableCopy]
                                                          defaultColor:UIColorFromRGB(0xFFB85A)
                                                           changeColor:UITextColor_DarkGray];
    if (queryTicketResultModel.remainedTicket == 0) {
        [cell.reservationButton setTitle:@"已售完" forState:UIControlStateNormal ];
        [cell.reservationButton setBackgroundColor:UITextColor_LightGray];
    }
    else {
        [cell.reservationButton setTitle:@"预定" forState:UIControlStateNormal ];
        [cell.reservationButton setBackgroundColor:UIColorFromRGB(0xFE6E35)];
    }
    cell.endSiteLabel.text = queryTicketResultModel.endCity;
    cell.priceLabel.text = [[NSString alloc] initWithFormat:@"%.0f元",queryTicketResultModel.price/100.f];
    MyRange *fontRange = [[MyRange alloc]initWithContent:cell.priceLabel.text.length - 1 length:1];
    cell.priceLabel.attributedText = [NSString hintStringFontSize:cell.priceLabel.text
                                                            rangs:[@[fontRange] mutableCopy]
                                                  defaultFontSize:[UIFont systemFontOfSize:18]
                                                   changeFontSize:[UIFont systemFontOfSize:12]];
    
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [self performSegueWithIdentifier:@"toFillOrder" sender:nil];
}

#pragma mark -- TicketResultTableViewCellDelegate
-(void)reservationButtonClick:(QueryTicketResultModel*)cellData
{
    if (cellData.remainedTicket == 0) {
        return;
    }
    //测试一下鉴权
//    self.isNotAuthBack = YES;
//    [self startWait];
//    [NetManagerInstance sendRequstWithType:EmRequestType_CheckToken params:^(NetParams *params) {
//        params.method = EMRequstMethod_GET;
//    }];
    //测试一下鉴权
    if (![[AuthorizeCache sharedInstance] getAccessToken] || [[[AuthorizeCache sharedInstance] getAccessToken] isEqualToString:@""]) {
        [super toLoginViewController];
        return;
    }
    
    [self.navigationController pushViewController:createOrderViewController animated:YES];
    if (!createOrderViewController) {
        UIStoryboard *ticketStoryboard = [UIStoryboard storyboardWithName:@"Tickets" bundle:nil];;//fillOrderViewController
        createOrderViewController = [ticketStoryboard instantiateViewControllerWithIdentifier:@"fillOrderViewController"];
    }
    createOrderViewController.queryTicketResultModel = cellData;
}


#pragma mark ----
- (void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    [self stopWait];
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    switch (resultData.type) {
        case EmRequestType_BookingTickets:
        {
            if (resultData.code == EmCode_Success) {
                dataSourceArray = [QueryTicketResultModel mj_objectArrayWithKeyValuesArray:resultData.data];
                [_mainTableView reloadData];
            }
            //前一天按钮
            if (_calenderStartData && [[_setOutDate earlierDate:_calenderStartData] isEqualToDate:_calenderStartData]) {
                [_beforeDayButton setUserInteractionEnabled:YES];
                [_beforeDayButton setTitleColor:UITextColor_DarkGray forState:UIControlStateNormal];
            }
            else
            {
                [_beforeDayButton setUserInteractionEnabled:NO];
                [_beforeDayButton setTitleColor:UITextColor_LightGray forState:UIControlStateNormal];
            }
            //后一天按钮
            if (_calenderEndDate && [[_setOutDate laterDate:_calenderEndDate] isEqualToDate:_calenderEndDate]) {
                [_afterDayButton setUserInteractionEnabled:YES];
                [_afterDayButton setTitleColor:UITextColor_DarkGray forState:UIControlStateNormal];
            }
            else
            {
                [_afterDayButton setUserInteractionEnabled:NO];
                [_afterDayButton setTitleColor:UITextColor_LightGray forState:UIControlStateNormal];
            }
        }
            break;
        case EmRequestType_CheckToken:
        {
            if (resultData.code == EmCode_Success && createOrderViewController)
            {
                [self.navigationController pushViewController:createOrderViewController animated:YES];
            }
        }
            break;
        default:
            break;
    }
    
}
- (void)httpRequestFailed:(NSNotification *)notification{
    [super httpRequestFailed:notification];
}

@end
