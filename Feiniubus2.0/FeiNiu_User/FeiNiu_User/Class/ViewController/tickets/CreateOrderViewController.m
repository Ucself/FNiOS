//
//  CreateOrderViewController.m
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/16.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "CreateOrderViewController.h"
#import "CreateOrderHeadView.h"
#import "CreateOrderFootView.h"
#import "TicketPassengerModel.h"
#import "ContactPeopleListViewController.h"
#import "OrderTicket.h"
#import "PayTicketsViewController.h"
#import "PushNotificationAdapter.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBookUI/ABPersonViewController.h>
#import "WebContentViewController.h"
#import "UserPreferences.h"
#import "ComTempCache.h"
#import "AddContactPeopleViewController.h"

@interface CreateOrderViewController ()<UITableViewDataSource,UITableViewDelegate,CreateOrderHeadViewDelegate,CreateOrderFootViewDelegate,ContactPeopleListViewControllerDelegate,UITextFieldDelegate,ABPeoplePickerNavigationControllerDelegate,UserCustomAlertViewDelegate,AddContactPeopleViewControllerDelegate>
{
    //选中的乘车人
    NSMutableArray *selectTicketPassengerModelArray;
    //订单id
    NSMutableDictionary *orderHeadInfor;
    //订单详情
    OrderTicket *orderTicket;
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic,strong) CreateOrderHeadView *headView;
@property (nonatomic,strong) CreateOrderFootView *footView;
@property (nonatomic,assign) BOOL isOperation;

//下单的控件数据
@property (weak, nonatomic) IBOutlet UILabel *fullPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullPriceCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *halfPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *halfPriceCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *allPeopleCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *allPriceLabel;

@property (weak, nonatomic) IBOutlet UIView *priceDetailView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceDetailViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *triangleImageView;

@end

@implementation CreateOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    
    [self initUI];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithGenerateOrderNotification:) name:FNPushType_BusTicketsGenerateOrder object:nil];
    //键盘吊起通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //返回联系人相关信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectContectPeopleNotification:) name:selectPeopleNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FNPushType_BusTicketsGenerateOrder object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    //清除键盘
    [self hideTheKeyBoard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation
*/
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIViewController *destinationViewController = segue.destinationViewController;
    //班次列表
    if ([destinationViewController isKindOfClass:[ContactPeopleListViewController class]]) {
        ContactPeopleListViewController *viewController = (ContactPeopleListViewController*)destinationViewController;
        viewController.selectDatasource =[[NSMutableArray alloc] initWithArray:selectTicketPassengerModelArray] ;
        viewController.delegate = self;
    }
    //添加乘车人页面
    else if ([destinationViewController isKindOfClass:[AddContactPeopleViewController class]])
    {
        AddContactPeopleViewController *viewController = (AddContactPeopleViewController*)destinationViewController;
        viewController.delegate = self;
        viewController.addPeopleTypeEnum = addPeopleFromOrderTypeEnum;
    }
    //支付页面
    else if ([destinationViewController isKindOfClass:[PayTicketsViewController class]]){
        PayTicketsViewController *viewController = (PayTicketsViewController*)destinationViewController;
        viewController.orderTicket = orderTicket;
    }
    
}


#pragma mark-------

-(void)initUI
{
    //tableView 头
    NSArray *headViewArray = [[NSBundle mainBundle] loadNibNamed:@"CreateOrderHeadView" owner:self options:nil];
    if (headViewArray.count >0) {
        _headView = headViewArray[0];
    }
    _headView.delegate = self;
    //日期
    NSDate *tickDatte = [DateUtils stringToDate:_queryTicketResultModel.date];
    _headView.dateLabel.text = [[NSString alloc] initWithFormat:@"%@（%@）",[DateUtils formatDate:tickDatte format:@"yyyy-MM-dd"],[DateUtils weekFromDate:tickDatte]];
    _headView.startCityLabel.text = _queryTicketResultModel.startCity;
    _headView.startSiteLabel.text = _queryTicketResultModel.startSite;
    _headView.typeLabel.text = _queryTicketResultModel.type == 3? @"滚动发班" : @"";   //2定时，3滚动
    if (_queryTicketResultModel.type == 3) {
        _headView.timeLabel.text = [[NSString alloc] initWithFormat:@"%@前有效",_queryTicketResultModel.time];
    }
    else{
        _headView.typeLabel.text = [[NSString alloc] initWithFormat:@"%@",_queryTicketResultModel.time];
        _headView.timeLabel.text = @"";
    }
    _headView.endCityLabel.text = _queryTicketResultModel.endCity;
    _headView.endSiteLabel.text = _queryTicketResultModel.endSite;
    _headView.priceLabel.text = [[NSString alloc] initWithFormat:@"%.2f元／张",_queryTicketResultModel.price/100.f];
    _headView.numberPeopleLabel.text = [[NSString alloc] initWithFormat:@"乘车人(共%lu人)",(unsigned long)(selectTicketPassengerModelArray ? selectTicketPassengerModelArray.count : 0)];
    [_headView.clickViewImg setHidden:YES];
    
    //tableView尾部
    NSArray *footViewArray = [[NSBundle mainBundle] loadNibNamed:@"CreateOrderFootView" owner:self options:nil];
    if (footViewArray.count >0) {
        _footView = footViewArray[0];
    }
//    _footView.delegate = self;
//    _footView.phoneNumberLabel.text = [[UserPreferences sharedInstance] getUserInfo] ? ((User*)[[UserPreferences sharedInstance] getUserInfo]).phone : @"";
    //价格显示
    [self resetDataDisplay];
    
    //首次设置价格详情隐藏
    _priceDetailViewHeight.constant = 0.f;
    CGAffineTransform transform =CGAffineTransformMakeRotation(-0);
    [_triangleImageView setTransform:transform];
}

//是否操作过本页
-(void)setIsOperation:(BOOL)isOperation
{
    if (_isOperation) {
        return;
    }
    _isOperation = isOperation;
    //本页禁用滑动手势
    self.fd_interactivePopDisabled = YES;
}

-(void)dealWithGenerateOrderNotification:(NSNotification*)notification
{
    //后台推送过来
    if (notification && [[orderHeadInfor objectForKey:@"isDealWith"] isEqualToNumber:[[NSNumber alloc] initWithInt:0]]) {
        [orderHeadInfor setObject:[[NSNumber alloc] initWithInt:1] forKey:@"isDealWith"]; //订单是否处理过 0 代表未处理 1代表已经处理
        //推送提示下单失败
        if ([notification.object objectForKey:@"success"] && [[notification.object objectForKey:@"success"] isEqualToNumber:[[NSNumber alloc] initWithInt:0]]) {
            [self stopWait];
            [self showTipsView:@"下单失败，请重试"];
        }
        else {
            [NetManagerInstance sendRequstWithType:EmRequestType_TicketOrderDetail params:^(NetParams *params) {
                params.method = EMRequstMethod_GET;
                params.data = @{@"orderId":[orderHeadInfor objectForKey:@"orderId"],@"hasTickets":@1};
            }];
        }
        
        return;
    }
    //未收到推送 20后的执行
    if ([[orderHeadInfor objectForKey:@"isDealWith"] isEqualToNumber:[[NSNumber alloc] initWithInt:0]]) {
        [orderHeadInfor setObject:[[NSNumber alloc] initWithInt:1] forKey:@"isDealWith"]; //订单是否处理过 0 代表未处理 1代表已经处理
        [NetManagerInstance sendRequstWithType:EmRequestType_TicketOrderDetail params:^(NetParams *params) {
            params.method = EMRequstMethod_GET;
            params.data = @{@"orderId":[orderHeadInfor objectForKey:@"orderId"],@"hasTickets":@1};
        }];
        return;
    }
}

- (IBAction)toPayTicketClick:(id)sender {
    //设置操作过本也
    [self setIsOperation:YES];
    //验证电话号码
    if (!_footView.phoneNumberLabel.text || ![BCBaseObject isFNMobileNumber:_footView.phoneNumberLabel.text]) {
        [self showTipsView:@"请填写正确的电话码号"];
        return;
    }
    //验证乘车人
    if (selectTicketPassengerModelArray.count == 0) {
        [self showTipsView:@"请添加乘车人"];
        return;
    }
    NSMutableArray *peopleArray = [[NSMutableArray alloc] init];
    for (TicketPassengerModel *tempTicketPassengerModel in selectTicketPassengerModelArray) {
        NSMutableDictionary *peopleRequestParameter =[[NSMutableDictionary alloc] init];
        [peopleRequestParameter setObject:@(tempTicketPassengerModel.type) forKey:@"type"];
        [peopleRequestParameter setObject:tempTicketPassengerModel.name forKey:@"name"];
        [peopleRequestParameter setObject:tempTicketPassengerModel.idCard forKey:@"idCard"];
        [peopleRequestParameter setObject:tempTicketPassengerModel.phone forKey:@"phone"];
        [peopleArray addObject:peopleRequestParameter];
    }
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_TicketOrderCreate params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        params.data = @{@"trainPathId":_queryTicketResultModel.trainPathId,@"peoples":peopleArray,@"contactPhone":_footView.phoneNumberLabel.text};
    }];
    
}

- (IBAction)leftViewClick:(id)sender {
    if (_priceDetailViewHeight.constant > 0) {
        //点击后应该收缩
        [UIView animateWithDuration:0.4 animations:^{
            _priceDetailViewHeight.constant = 0.f;
            [_priceDetailView layoutIfNeeded];
            [_mainTableView layoutIfNeeded];
            CGAffineTransform transform =CGAffineTransformMakeRotation(-0);
            [_triangleImageView setTransform:transform];

        }];
        
    }
    else
    {
        //点击后应该展开
        [UIView animateWithDuration:0.4 animations:^{
            _priceDetailViewHeight.constant = 92.f;
            [_mainTableView layoutIfNeeded];
            [_priceDetailView layoutIfNeeded];
            CGAffineTransform transform =CGAffineTransformMakeRotation(M_PI);
            [_triangleImageView setTransform:transform];
        }];
    }
    
}
/**
 *  删除联系人
 *
 *  @param sender 删除联系人
 */
- (IBAction)deleteContactPeopleClick:(id)sender {
    DBG_MSG(@"((UIButton*)sender).tag == %ld",(long)((UIButton*)sender).tag);
    NSUInteger index = ((UIButton*)sender).tag - 1000;
    [selectTicketPassengerModelArray removeObjectAtIndex:index];
    [self resetDataDisplay];
    [_mainTableView reloadData];
}

/**
 *  隐藏键盘
 */
-(void)hideTheKeyBoard
{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    }];
    [_footView.phoneNumberLabel resignFirstResponder];
}

/**
 *  重置界面的数据显示
 */
-(void)resetDataDisplay
{
    
    //设置显示人数
    _headView.numberPeopleLabel.text = [[NSString alloc] initWithFormat:@"乘车人(共%lu人)",(unsigned long)(selectTicketPassengerModelArray ? selectTicketPassengerModelArray.count : 0)];
    
    float fullPrice = 0,fullPriceCount = 0,halfPrice = 0,halfPriceCount = 0;
    //价格
    if (_queryTicketResultModel) {
        fullPrice = _queryTicketResultModel.price/100.f;
        halfPrice = _queryTicketResultModel.price/200.f;
    }
    //人数
    for (TicketPassengerModel *tempTicketPassengerModel in selectTicketPassengerModelArray) {
        if (tempTicketPassengerModel.type == 1) {
            fullPriceCount ++;
        }
        else{
            halfPriceCount ++;
        }
    }
    _fullPriceLabel.text =  [[NSString alloc] initWithFormat:@"%.2f",fullPrice];
    _halfPriceLabel.text =  [[NSString alloc] initWithFormat:@"%.2f",halfPrice];
    _fullPriceCountLabel.text = [[NSString alloc] initWithFormat:@"%.0f",fullPriceCount];
    _halfPriceCountLabel.text = [[NSString alloc] initWithFormat:@"%.0f",halfPriceCount];
    _allPeopleCountLabel.text = [[NSString alloc] initWithFormat:@"%.0f人",halfPriceCount + fullPriceCount];
    //人数字体大小区分
    MyRange *peopleCountFontRange = [[MyRange alloc]initWithContent:_allPeopleCountLabel.text.length - 1 length:1];
    _allPeopleCountLabel.attributedText = [NSString hintStringFontSize:_allPeopleCountLabel.text
                                                           rangs:[@[peopleCountFontRange] mutableCopy]
                                                 defaultFontSize:[UIFont boldSystemFontOfSize:18]
                                                  changeFontSize:[UIFont systemFontOfSize:12]];
    _allPriceLabel.text = [[NSString alloc] initWithFormat:@"%.2f元",halfPriceCount*halfPrice + fullPriceCount*fullPrice];
    //价格字体大小区分
    MyRange *fontRange = [[MyRange alloc]initWithContent:_allPriceLabel.text.length - 1 length:1];
    _allPriceLabel.attributedText = [NSString hintStringFontSize:_allPriceLabel.text
                                                            rangs:[@[fontRange] mutableCopy]
                                                  defaultFontSize:[UIFont boldSystemFontOfSize:18]
                                                   changeFontSize:[UIFont systemFontOfSize:12]];
    
}
//键盘通知
-(void)KeyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    //获取高度
    NSValue *value = [info objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGSize keyboardSize = [value CGRectValue].size;
    DBG_MSG(@"键盘高度：%f", keyboardSize.height);
}

-(void)navigationViewBackClick
{
    if (!_isOperation) {
        [super navigationViewBackClick];
        return;
    }
    UserCustomAlertView *alertView =[UserCustomAlertView alertViewWithTitle:@"订单填写还未完成\n确认放弃吗？" message:@"" delegate:self buttons:@[@"继续填写",@"放弃填写"]];
    if ([alertView viewWithTag:1001]) {
        UILabel *titleLabel = [alertView viewWithTag:1001];
        titleLabel.numberOfLines = 0;
        [titleLabel remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(0);
        }];
    }
    
    
    [alertView showInView:self.view];
}
//选择联系人通知
-(void)selectContectPeopleNotification:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    selectTicketPassengerModelArray = [info objectForKey:selectPeopleNotification];
    [self.mainTableView reloadData];
    [self resetDataDisplay];
}
#pragma mark ---UserCustomAlertViewDelegate
- (void)userAlertView:(UserCustomAlertView *)alertView dismissWithButtonIndex:(NSInteger)btnIndex
{
    switch (btnIndex) {
        case 1:
        {
            [super navigationViewBackClick];
        }
            break;
        case 0:
        {
            
        }
            break;
        default:
            break;
    }
}


#pragma mark -- ContactPeopleListViewControllerDelegate

-(void)okClickReturnInfor:(NSMutableArray*)ticketPassengerModelArray selectTicketPassenger:(NSMutableArray*)selectTicketPassenger
{
    return;
//    selectTicketPassengerModelArray = selectTicketPassenger;
//    [self.mainTableView reloadData];
//    [self resetDataDisplay];
}

#pragma mark -- AddContactPeopleViewControllerDelegate
-(void)addContactPeopleSuccess:(TicketPassengerModel*)ticketPassengerModel
{
    return;
//    if (ticketPassengerModel) {
//        selectTicketPassengerModelArray = [@[ticketPassengerModel] mutableCopy];
//    }
//    [self.mainTableView reloadData];
//    [self resetDataDisplay];
}


#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectTicketPassengerModelArray.count == 0) {
        return 65;
    }
    return 55;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 172;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 145;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (selectTicketPassengerModelArray.count == 0) {
        return 1;
    }
    return selectTicketPassengerModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectTicketPassengerModelArray.count == 0) { //noContactPeopleCell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noContactPeopleCell"];
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactPeopleCell"];
    UILabel *nameLabel = [cell viewWithTag:101];
    UILabel *idCardLabel = [cell viewWithTag:102];
    UILabel *ticketTypeLabel = [cell viewWithTag:103];
    UIButton *deleteContactPeople = [cell viewWithTag:104];
    UIView *lineView = [cell viewWithTag:105];
    
    TicketPassengerModel *ticketPassengerModel = selectTicketPassengerModelArray[indexPath.row];
    nameLabel.text = ticketPassengerModel.name;
    idCardLabel.text = ticketPassengerModel.idCard;
    if (ticketPassengerModel.type == 1) {
        ticketTypeLabel.text = @"";
    }
    else {
        ticketTypeLabel.text = @"儿童/军残半价票";
    }
    //是否显示线条
    if (indexPath.row + 1 == selectTicketPassengerModelArray.count) {
        [lineView setBackgroundColor:[UIColor whiteColor]];
    }
    else {
        [lineView setBackgroundColor:UIColorFromRGB(0xD0D0D0)];
    }
    //删除按钮
    [deleteContactPeople setTag:1000 + indexPath.row];
    DBG_MSG(@"deleteContactPeopleUIButton  tag == %ld",(long)deleteContactPeople.tag);
    return cell;
    
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _headView;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    _footView.phoneNumberLabel.delegate = self;
    _footView.phoneNumberLabel.returnKeyType = UIReturnKeyDone;
    _footView.phoneNumberLabel.keyboardType = UIKeyboardTypeNumberPad;
    return _footView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideTheKeyBoard];
}

#pragma mark ---  CreateOrderHeadViewDelegate

-(void)headViewAddClickView
{
    //设置操作过本也
    [self setIsOperation:YES];
    //请求联系人列表 //首先获取缓存如果不存在则跳入添加页面
    NSArray *array = [ComTempCache getObjectWithKey:KeyContactList];
    if (array && array.count != 0) {
        [self performSegueWithIdentifier:@"toSelectPeople" sender:nil];
        return;
    }
    else{
        //如果没有缓存数据就去请求服务器
        [self startWait];
        [NetManagerInstance sendRequstWithType:EmRequestType_PassengerHistory params:^(NetParams *params) {
            params.method = EMRequstMethod_GET;
        }];
    }
    
}

#pragma mark ---  CreateOrderFootViewDelegate

-(void)addressBookLookingClick
{
    //设置操作过本也
    [self setIsOperation:YES];
    
    ABPeoplePickerNavigationController *nav = [[ABPeoplePickerNavigationController alloc] init];
    nav.peoplePickerDelegate = self;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        nav.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:false];
    }
    [self presentViewController:nav animated:YES completion:nil];
}
-(void)ticketsInstructionsClick
{
    //此处进入取票说明页面
    WebContentViewController *webViewController = [WebContentViewController instanceWithStoryboardName:@"Me"];
    webViewController.vcTitle = @"取票退票说明";
    webViewController.urlString = HTMLAddr_CharterRefundRule;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark --- UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect rect =   [self.view convertRect:_footView.phoneNumberLabel.frame fromView:_footView.phoneNumberLabel.superview];
    DBG_MSG(@"%@",NSStringFromCGRect(rect));
    CGFloat bottom = CGRectGetMaxY(rect);
    CGFloat delta = ScreenH - bottom - 256;
    if (delta < 0) {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = CGRectOffset(self.view.bounds, 0, delta);
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideTheKeyBoard];
    return YES;
}

#pragma mark --- ABPeoplePickerNavigationControllerDelegate
//取消选择
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

//IOS8以上返回
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    long index = ABMultiValueGetIndexForIdentifier(phone,identifier);
    CFStringRef phonecf = ABMultiValueCopyValueAtIndex(phone, index);;
    NSString *phoneNO = (__bridge NSString*)phonecf;
    if(phoneNO) CFRelease(phone);
    
    //+86
    if ([phoneNO hasPrefix:@"+"]) {
        if (phoneNO.length > 5) {
            phoneNO = [phoneNO substringFromIndex:3];
        }
    }
    //86
    if ([phoneNO hasPrefix:@"86"]) {
        if (phoneNO.length > 5) {
            phoneNO = [phoneNO substringFromIndex:2];
        }
    }
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];   //去-
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@" " withString:@""];   //去空格
    if (phoneNO && [BCBaseObject isMobileNumber:phoneNO]) {
        _footView.phoneNumberLabel.text = phoneNO;
        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
        //return;
    }
    if(phonecf) CFRelease(phonecf);
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person
{
    ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
    personViewController.displayedPerson = person;
    [peoplePicker pushViewController:personViewController animated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

//IOS 7 返回
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    long index = ABMultiValueGetIndexForIdentifier(phone,identifier);
    CFStringRef phonecf = ABMultiValueCopyValueAtIndex(phone, index);;
    NSString *phoneNO = (__bridge NSString*)phonecf;
    if(phoneNO) CFRelease(phone);
    
    //+86
    if ([phoneNO hasPrefix:@"+"]) {
        if (phoneNO.length > 5) {
            phoneNO = [phoneNO substringFromIndex:3];
        }
    }
    //86
    if ([phoneNO hasPrefix:@"86"]) {
        if (phoneNO.length > 5) {
            phoneNO = [phoneNO substringFromIndex:2];
        }
    }
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];   //去-
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@" " withString:@""];   //去空格
    if (phoneNO && [BCBaseObject isMobileNumber:phoneNO]) {
        _footView.phoneNumberLabel.text = phoneNO;
        [peoplePicker dismissViewControllerAnimated:YES completion:nil];
        //return;
    }
    if(phonecf) CFRelease(phonecf);
    return YES;
}


#pragma mark ----
- (void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];   //此处不调用 各自结果去消除加载框
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    switch (resultData.type) {
        case EmRequestType_TicketOrderCreate:
        {
            orderHeadInfor = [[NSMutableDictionary alloc] init];
            if ([resultData.data objectForKey:@"orderId"]) {
                [orderHeadInfor setObject:[resultData.data objectForKey:@"orderId"] forKey:@"orderId"]; //订单id
                [orderHeadInfor setObject:[[NSNumber alloc] initWithInt:0] forKey:@"isDealWith"]; //订单是否处理过 0 代表未处理 1代表已经处理
                //20秒推送未过来 执行通知方法
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WaitNotificationSecond * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self dealWithGenerateOrderNotification:nil];
                });
//                [self performSelector:@selector(dealWithGenerateOrderNotification:) withObject:nil afterDelay:WaitNotificationSecond];
            }
        }
            break;
        case EmRequestType_TicketOrderDetail:
        {
            [self stopWait];
            orderTicket = [[OrderTicket alloc] init];
            //下单订单成功
            if ([resultData.data objectForKey:@"state"] && [[resultData.data objectForKey:@"state"] isEqualToNumber:[[NSNumber alloc] initWithInt:1]]) {
                orderTicket = [OrderTicket mj_objectWithKeyValues:[resultData.data objectForKey:@"order"]];
                //之前的直接跳转支付页面
                [self performSegueWithIdentifier:@"toPayTicket" sender:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:KOrderRefreshNotification object:nil];
            }
            else{
                [self showTipsView:@"下单失败，请重试"];
            }
        }
            break;
        case EmRequestType_PassengerHistory:
        {
            [self stopWait];
            if(resultData.data && [resultData.data  isKindOfClass:[NSArray class]] && ((NSArray*)resultData.data).count > 0)
            {
                [self performSegueWithIdentifier:@"toSelectPeople" sender:nil];
            }
            else
            {
                //toAddSelectPeople 如果乘车人直接到添加乘车人
                [self performSegueWithIdentifier:@"toAddSelectPeople" sender:nil];
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
