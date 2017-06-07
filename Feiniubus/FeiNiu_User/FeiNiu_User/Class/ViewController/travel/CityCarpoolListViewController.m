//
//  CityCarpoolListViewController.m
//  FeiNiu_User
//
//  Created by Nick.Lin on 15/10/29.
//  Copyright © 2015年 feiniu.com. All rights reserved.
//

#import "CityCarpoolListViewController.h"
#import "TravelListCell.h"
#import "CityCarpoolOrderItem.h"
#import "UIColor+Hex.h"
#import "CarpoolTravelingViewController.h"
#import "TianFuCarTravelingManagerVC.h"
#import "TianFuCarPayVC.h"
#import "BaiDuCarWaitOrder.h"
#import "BaiDuCarWaitOwner.h"
#import "TFCarEvaluationVC.h"
#import "BaiDuCarRouting.h"
#import "TFCarOrderDetailModel.h"

#define StateRedColor 0xFF7043
#define StateYellowColor 0xFFB84D
#define StateGreenColor 0x1EC18E
#define StateGrayColor 0xB4B4B4


@implementation CityCarpoolListViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestTravelList) name:@"TianfuTravelMangerRefreshNotification" object:nil];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deleteAction
{
    
}

- (void)requestSelectedItem{
    if (!_selectedIndexPath || ![_selectedIndexPath isKindOfClass:[NSIndexPath class]]) {
        return;
    }
    
    [self startWait];
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CityCarpoolOrderListItemWithIndex params:^(NetParams *params) {
        params.data = @{@"spik":@(_selectedIndexPath.row),
                        @"rows":@(1)};
    }];
}


- (void)requestTravelList{
    [NetManagerInstance sendRequstWithType:FNUserRequestType_CityCarpoolOrderList params:^(NetParams *params) {
        params.data =@{@"spik":@(_page * _pageSize),
                       @"rows":@(_pageSize)};
    }];
}

#pragma mark-
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TravelListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarpoolItemCell"];
    CityCarpoolOrderItem *orderItem = self.dataList[indexPath.row];
    
    cell.lblCreateDate.text = [orderItem.createTime timeStringByDefault];
    cell.lblStartName.text = orderItem.boardAddress;
    cell.lblEndName.text = orderItem.destinationAddress;
    
    UIColor *stateColor = [UIColor colorWithHex:StateRedColor];
    NSString *state;
    switch (orderItem.orderStatus) {
        case CityCarpoolOrderStatusPrepare:{
            state = @"未完成";
            break;
        }
        case CityCarpoolOrderStatusWaiting:{
            state = @"未完成";
            break;
        }
        case CityCarpoolOrderStatusStart:{
            if (orderItem.payStatus == CCityCarpoolOrderPayStatusPaid) {
                state = @"已完成";
//                stateColor = [UIColor colorWithHex:StateGreenColor];
            }else{
                state = @"未完成";
//                stateColor = [UIColor colorWithHex:StateYellowColor];
            }
            break;
        }
        case CityCarpoolOrderStatusEnd:{
            if (orderItem.payStatus == CityCarpoolOrderPayStatusPrepareForPay) {
                state = @"未完成";
            }
            else if(orderItem.payStatus == CCityCarpoolOrderPayStatusPaid){
                state = @"已完成";
            }else if (orderItem.payStatus == CityCarpoolOrderPayStatusFreeCharge){
                state = @"已完成";
//                stateColor = [UIColor colorWithHex:StateGrayColor];
            }
            else{
                state = @"已完成";
//                stateColor = [UIColor colorWithHex:StateGrayColor];
            }

            break;
        }
        case CityCarpoolOrderStatusCancel:{
            state = @"已取消";
//            stateColor = [UIColor colorWithHex:StateGrayColor];
            break;
        }
        case CityCarpoolOrderStatusFailure:{
            state = @"下单失败";

//            if (orderItem.payStatus == CityCarpoolOrderPayStatusNON){
//                state = @"未开放支付";
//                stateColor = [UIColor colorWithHex:StateGrayColor];
//            }else if (orderItem.payStatus == CityCarpoolOrderPayStatusFreeCharge){
//                state = @"免单";
//                stateColor = [UIColor colorWithHex:StateGrayColor];
//            }else{
//                stateColor = [UIColor colorWithHex:StateGrayColor];
//            }

            break;
        }
        default:
            break;
    }
    cell.lblState.text = state;
    cell.lblState.textColor = stateColor;
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([NetManagerInstance reach] == 0) {
        [self showTip:@"似乎已断开与互联网的连接" WithType:FNTipTypeWarning];
        return nil;
    }
    CityCarpoolOrderItem *orderItem = self.dataList[indexPath.row];
    
    if (orderItem.orderStatus == CityCarpoolOrderStatusWaiting) {
        BaiDuCarWaitOwner *waitOrderVC = [[UIStoryboard storyboardWithName:@"BaiDuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"waitowner"];
        waitOrderVC.orderId = orderItem.orderId;
        [self.navigationController pushViewController:waitOrderVC animated:YES];
    }
    else if (orderItem.orderStatus == CityCarpoolOrderStatusCancel) {
//        TianFuCarTravelingManagerVC *vc = [[UIStoryboard storyboardWithName:@"TianFuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"tianfumanagervc"];
//        vc.status = TianFuCarOrderStatusCancel;//测试，跳转到行程详情
//        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (orderItem.orderStatus == CityCarpoolOrderStatusEnd) {
        if (orderItem.payStatus == CityCarpoolOrderPayStatusNON || orderItem.payStatus == CityCarpoolOrderPayStatusPrepareForPay) {
            TianFuCarPayVC *tfcVC = [[UIStoryboard storyboardWithName:@"TianFuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"tianfucarpay"];
            tfcVC.orderId = orderItem.orderId;
            [self.navigationController pushViewController:tfcVC animated:YES];
        }else{
            TFCarOrderDetailModel* orderDetailModel = [[TFCarOrderDetailModel alloc] init];
            orderDetailModel.orderId = orderItem.orderId;
            orderDetailModel.price = [NSString stringWithFormat:@"%d",(int)orderItem.price];
            
            BOOL hasEvaluation = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"HaveEvaluation_%@",orderDetailModel.orderId]] boolValue];
            
            TFCarEvaluationVC *tfcVC = [[UIStoryboard storyboardWithName:@"TianFuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"evaluationvc"];
            tfcVC.orderDetailModel = orderDetailModel;
            tfcVC.isLook = hasEvaluation;
            [self.navigationController pushViewController:tfcVC animated:YES];
        }
        
    }
    else if (orderItem.orderStatus == CityCarpoolOrderStatusPrepare) {
        
        BaiDuCarWaitOrder *waitOrderVC = [[UIStoryboard storyboardWithName:@"BaiDuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"waitorder"];
        waitOrderVC.typeId = orderItem.type;
        waitOrderVC.orderId = orderItem.orderId;


        id params = [NSString stringWithFormat:@"CurrentOrderIdUserDefault_%@",orderItem.orderId];
        if (params && [params isKindOfClass:[NSString class]]) {
//            NSDictionary* dic = (NSDictionary*)params;
//            if ([dic[@"orderId"] isEqualToString:orderItem.orderId]) {
//                waitOrderVC.userLatitude = [dic[@"boardingLatitude"] floatValue];
//                waitOrderVC.userLongitude = [dic[@"boardingLongitude"] floatValue];
//                waitOrderVC.orderId = dic[@"orderId"];
//                waitOrderVC.typeId = [dic[@"type"] intValue];
//            }
            
            NSString *url = [NSString stringWithFormat:@"%@FerryOrderCheck",KServerAddr];
            [[NetInterface sharedInstance] httpGetRequest:url body:@{@"orderId":params} suceeseBlock:^(NSString *msg) {
                [self stopWait];
                
                NSDictionary* dic = [JsonUtils jsonToDcit:msg];
                if ([dic[@"code"] intValue] == 0) {
                    TFCarOrderDetailModel* orderModel = [[TFCarOrderDetailModel alloc] initWithDictionary:dic[@"order"]];
                    waitOrderVC.userLatitude = orderModel.boardingLatitude;
                    waitOrderVC.userLongitude = orderModel.boardingLongitude;
                }
            } failedBlock:^(NSError *msg) {
                [self stopWait];
            }];
            
//            [NetManagerInstance sendRequstWithType:KRequestType_FerryOrderCheck params:^(NetParams *params) {
//
//            }];
        }
        
        [self.navigationController pushViewController:waitOrderVC animated:YES];

    }
    else if (orderItem.orderStatus == CityCarpoolOrderStatusStart) {
        BaiDuCarRouting *carRouting = [[UIStoryboard storyboardWithName:@"BaiDuCar" bundle:nil] instantiateViewControllerWithIdentifier:@"carrouting"];
        carRouting.orderId = orderItem.orderId;
        [self.navigationController pushViewController:carRouting animated:YES];
    }

    
    
    
//    CarpoolTravelingViewController *carpoolVC = [CarpoolTravelingViewController instanceFromStoryboard];
//    carpoolVC.carpoolOrder = orderItem;
//    [self.navigationController pushViewController:carpoolVC animated:YES];
    return nil;
}


#pragma mark- http request handler
-(void)httpRequestFinished:(NSNotification *)notification{
    [super httpRequestFinished:notification];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    RequestType type = resultData.requestType;
    
    switch (type) {
        case FNUserRequestType_CityCarpoolOrderList:{
            if (_page == 0 || !self.dataList) {
                self.dataList = [NSMutableArray array];
                [self.tableView.footer resetNoMoreData];
                
            }
            NSArray *jsonList = resultData.data[@"list"];
            if (!jsonList || jsonList.count == 0) {
                [self.tableView.footer noticeNoMoreData];
            }else{
                [jsonList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CityCarpoolOrderItem *item = [[CityCarpoolOrderItem alloc]initWithDictionary:obj];
                    if (item) {
                        [self.dataList addObject:item];
                    }
                }];
                if (jsonList.count < _pageSize) {
                    [self.tableView.footer noticeNoMoreData];
                }else{
                    [self.tableView.footer endRefreshing];
                }
            }
            [self.tableView.header endRefreshing];
            [self.tableView reloadData];
            break;
        }
        case FNUserRequestType_CityCarpoolOrderListItemWithIndex:{
            NSArray *jsonList = resultData.data[@"list"];
            CityCarpoolOrderItem *item = [[CityCarpoolOrderItem alloc]initWithDictionary:[jsonList firstObject]];
            [self updateSelectedRowWithItem:item];
            break;
        }
        case KRequestType_FerryOrderCheck:{
        
        
        }
        default:
            break;
    }
}

-(void)httpRequestFailed:(NSNotification *)notification{
    [super httpRequestFailed:notification];
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    //    NSError *error = [notification.object objectForKey:@"error"];
    //    [self showTip:error.localizedDescription WithType:FNTipTypeFailure hideDelay:1.5];
}
@end
