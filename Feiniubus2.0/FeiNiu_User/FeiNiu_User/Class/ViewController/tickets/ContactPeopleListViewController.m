//
//  ContactPeopleListViewController.m
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/17.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "ContactPeopleListViewController.h"
#import "PassengerTableViewCell.h"
#import <FNUIView/UserCustomAlertView.h>
#import "AddContactPeopleViewController.h"
#import "ComTempCache.h"


@interface ContactPeopleListViewController ()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate,UserCustomAlertViewDelegate,AddContactPeopleViewControllerDelegate>
{
    PassengerTableViewCell *prevCell;
    TicketPassengerModel *deleteTicketPassengerModel;
    
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end


@implementation ContactPeopleListViewController

@dynamic delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    
    if (!_selectDatasource) {
        _selectDatasource = [[NSMutableArray alloc] init];
    }
    
    NSArray *array = [ComTempCache getObjectWithKey:KeyContactList];
    if (array && array.count != 0) {
        _mainDatasource = [NSMutableArray arrayWithArray:array];
    }
    else {
        //请求乘车人数据
        [self requestPassengerHistory];
    }
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//登录成功方法
- (void) loginSuccessHandler
{
    //请求乘车人数据
    [self requestPassengerHistory];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//     Get the new view controller using [segue destinationViewController].
//     Pass the selected object to the new view controller.
    UIViewController *prepareViewController = [segue destinationViewController];
    if ( [prepareViewController isKindOfClass:[AddContactPeopleViewController class]]) {
        ((AddContactPeopleViewController*)prepareViewController).delegate = self;
        ((AddContactPeopleViewController*)prepareViewController).addPeopleTypeEnum = addPeopleFromListTypeEnum;
    }
}


#pragma mark ----

-(void)requestPassengerHistory
{
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_PassengerHistory params:^(NetParams *params) {
        params.method = EMRequstMethod_GET;
    }];
}

-(void)navigationViewRightClick
{
    [super navigationViewRightClick];
    [self performSegueWithIdentifier:@"toAddContactPeople" sender:nil];
}

- (IBAction)okClick:(id)sender {
    //更换回调方式
//    if ([self.delegate respondsToSelector:@selector(okClickReturnInfor:selectTicketPassenger:)]) {
//        [self.delegate okClickReturnInfor:_mainDatasource selectTicketPassenger:_selectDatasource];
//    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:selectPeopleNotification object:nil userInfo:@{selectPeopleNotification:_selectDatasource}];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --- AddContactPeopleViewControllerDelegate

-(void)addContactPeopleSuccess:(TicketPassengerModel*)ticketPassengerModel
{
    //    if (_selectDatasource) {
    //        [_selectDatasource addObject:ticketPassengerModel];
    //    }
    //    else
    //    {
    //        _selectDatasource = [@[ticketPassengerModel] mutableCopy];
    //    }
    //重新刷一次列表
    [self requestPassengerHistory];
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _mainDatasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdent = @"PassengerCellId";
    PassengerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PassengerTableViewCell" owner:self options:0] firstObject];
        cell.delegate = self;
        cell.height = 60;
        cell.containingTableView = _mainTableView;
    }

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = UIColor_DefOrange;
    [btn setImage:[UIImage imageNamed:@"ico_recycle"] forState:UIControlStateNormal];
    NSArray *btns = @[btn];
    [cell setButtonsLeft:nil right:btns];
    
    
    UILabel *nameLabel = [cell viewWithTag:101];
    UILabel *idCardLabel = [cell viewWithTag:102];
    UIImageView *selectImage = [cell viewWithTag:103];
    UILabel *halfTicketLabel = [cell viewWithTag:104];
    
    TicketPassengerModel *ticketPassengerModel = _mainDatasource[indexPath.row];
    nameLabel.text = ticketPassengerModel.name;
    idCardLabel.text = [[NSString alloc] initWithFormat:@"身份证： %@",ticketPassengerModel.idCard];
    if (ticketPassengerModel.type == 1) {
        halfTicketLabel.text = @"";
    }
    else{
        halfTicketLabel.text = @"儿童/军残半价票";
    }
    
    [selectImage setImage:[UIImage imageNamed:@"checkbox_more"]];
    for (TicketPassengerModel *tempModel in _selectDatasource) {
        if ([tempModel.id isEqualToString:ticketPassengerModel.id]) {
            [selectImage setImage:[UIImage imageNamed:@"checkbox_moreh"]];
        }
    }
    
    
    return cell;
}

#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PassengerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *selectImage = [cell viewWithTag:103];
    
    TicketPassengerModel *ticketPassengerModel = _mainDatasource[indexPath.row];
    TicketPassengerModel *tempModel ;
    for (TicketPassengerModel *selectModel in _selectDatasource) {
        if ([selectModel.id isEqualToString:ticketPassengerModel.id]) {
            tempModel = selectModel;
        }
    }
    if (tempModel) {
        [_selectDatasource removeObject:tempModel];
        //改变复选框
        [selectImage setImage:[UIImage imageNamed:@"checkbox_more"]];
    }
    else
    {
        [_selectDatasource addObject:ticketPassengerModel];
        //改变复选框
        [selectImage setImage:[UIImage imageNamed:@"checkbox_moreh"]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SWTableViewDelegate
- (void)swippableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            NSIndexPath *cellIndexPath = [_mainTableView indexPathForCell:cell];
            //删除数据源，删除
            deleteTicketPassengerModel = _mainDatasource[cellIndexPath.row];
            UserCustomAlertView *alertView =[UserCustomAlertView alertViewWithTitle:@"你确定删除乘车人？" message:@"" delegate:self buttons:@[@"取消",@"确定"]];
            if ([alertView viewWithTag:1001]) {
                UILabel *titleLabel = [alertView viewWithTag:1001];
                [titleLabel remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(0);
                }];
            }
            
            
            [alertView showInView:self.view];
            break;
        }
            
        default:
            break;
    }
}
- (void)swippableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    if (prevCell && prevCell != cell) {
        [prevCell hideUtilityButtonsAnimated:YES];
    }
    
    prevCell = (PassengerTableViewCell*)cell;
}

#pragma mark ---UserCustomAlertViewDelegate 
- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex
{
    switch (btnIndex) {
        case 1:
        {
            [NetManagerInstance sendRequstWithType:EmRequestType_DeletePassengerHistory params:^(NetParams *params) {
                params.method = EMRequstMethod_DELETE;
                params.data = @{@"id":deleteTicketPassengerModel.id};
            }];
        }
            break;
        case 0:
        {
            deleteTicketPassengerModel = nil;
        }
            break;
        default:
            break;
    }
}

#pragma mark ---

- (void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    [self stopWait];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    switch (resultData.type) {
        case EmRequestType_PassengerHistory:
        {
            _mainDatasource = [[NSMutableArray alloc] init];
            for (id tempData in resultData.data) {
                TicketPassengerModel *ticketPassengerModel = [TicketPassengerModel mj_objectWithKeyValues:tempData];
                [_mainDatasource addObject:ticketPassengerModel];
            }
            [self.mainTableView reloadData];
            
            [ComTempCache setObject:_mainDatasource forKey:KeyContactList];
            
            //如果没有乘车人直接跳转到乘车人页面
//            if (_mainDatasource.count <= 0) {
//                [self performSegueWithIdentifier:@"toAddContactPeople" sender:nil];
//            }
        }
            break;
        case EmRequestType_DeletePassengerHistory:
        {
            if (!deleteTicketPassengerModel) {
                return;
            }
            [_mainDatasource removeObject:deleteTicketPassengerModel];
            TicketPassengerModel *tempModel ;
            for (TicketPassengerModel *selectModel in _selectDatasource) {
                if ([selectModel.id isEqualToString:deleteTicketPassengerModel.id]) {
                    tempModel = selectModel;
                }
            }
            if (tempModel) {
                [_selectDatasource removeObject:tempModel];
            }
            [_mainTableView reloadData];
            //清楚暂时存储的数据
            deleteTicketPassengerModel = nil;
            //缓存数据
            [ComTempCache setObject:_mainDatasource forKey:KeyContactList];
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
