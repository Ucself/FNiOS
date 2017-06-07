//
//  ChooseStationViewController.m
//  FeiNiu_User
//
//  Created by CYJ on 16/3/17.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "ChooseStationViewController.h"
#import "ChooseStationCell.h"
#import "MapCoordinaterModule.h"
#import "AddressManager.h"

@interface ChooseStationViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *myTableView;
    __weak IBOutlet UILabel *currentCityLab;
    __weak IBOutlet UILabel *navTitleLab;
    
    ChooseStationObj *seletedObj;
    NSArray *stationArrays;
}
@end

@implementation ChooseStationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    navTitleLab.text = self.navTitle;
    myTableView.tableFooterView = [UIView new];
    
    //如果没有地址--请求地址
    AddressManager *address = [AddressManager sharedInstance];
    if (!address.allAddressArray || address.allAddressArray.count == 0) {
        MapCoordinaterModule *module = [MapCoordinaterModule sharedInstance];
        [self startWait];
        [NetManagerInstance sendRequstWithType:EmRequestType_GetCommonAddress params:^(NetParams *params) {
//            params.data = @{@"adCode":@(module.adCode),
//                            @"type" : @(0)};    //type 0 请求所有站点
        }];
    }else{
        [self refreshWithData:[address addressForType:_type]];
    }
}

-(void)refreshWithData:(NSArray*)array
{
    stationArrays = array;
    [myTableView reloadData];
    
    if (stationArrays.count == 0) {
        return;
    }
    
    //默认选中第一个--- 选中上次选中
    __block NSInteger row = 0;
    [stationArrays enumerateObjectsWithOptions:0 usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChooseStationObj *station = [ChooseStationObj mj_objectWithKeyValues:obj];
        if (_adressName && [_adressName isEqualToString:station.name]) {
            
            row = idx;
            *stop = YES;
        }
    }];
    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
    [myTableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self tableView:myTableView didSelectRowAtIndexPath:path];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return stationArrays.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChooseStationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseStationCell"];

    ChooseStationObj *obj = stationArrays[indexPath.row];
    cell.titleLab.text = obj.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    seletedObj = [ChooseStationObj mj_objectWithKeyValues:stationArrays[indexPath.row]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clickDoneAction:(UIButton *)sender
{
    if (seletedObj) {
        if (_clickPopAction) {
            _clickPopAction(seletedObj);
        }
        [self popViewController];
    }else{
        [self showTipsView:@"请选择上车地点"];
    }
}

- (IBAction)btnBack:(id)sender {
    [self popViewController];
}

- (IBAction)clickChooseCityAction:(UITapGestureRecognizer *)sender
{
    [self showTipsView:NotOpenCityAlertString];
}

- (void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
}

- (void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    
    ResultDataModel *result = notification.object;
    if (result.type == EmRequestType_GetCommonAddress) {
        
        [self stopWait];
        AddressManager *address = [AddressManager sharedInstance];
        address.allAddressArray = result.data;
        [self refreshWithData:[address addressForType:_type]];
    }
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
