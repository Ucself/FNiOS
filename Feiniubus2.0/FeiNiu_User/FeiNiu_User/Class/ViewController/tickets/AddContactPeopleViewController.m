//
//  AddContactPeopleViewController.m
//  FeiNiu_User
//
//  Created by lbj@feiniubus.com on 16/3/17.
//  Copyright © 2016年 tianbo. All rights reserved.
//

#import "AddContactPeopleViewController.h"
#import <FNCommon/BCBaseObject.h>
#import "PeopleTypeSelectorView.h"
#import <FNUIView/SelectPickerView.h>

@interface AddContactPeopleViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    TicketPassengerModel *ticketPassengerModel;
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@end

@implementation AddContactPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
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
#pragma mark ----

-(void)initUI
{
    
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    ticketPassengerModel = [[TicketPassengerModel alloc] init];
    //默认全价票
    ticketPassengerModel.type = PassengerTypeAll;
}

-(void)navigationViewRightClick
{
    [super navigationViewRightClick];
    //隐藏键盘和类型选择
    [self hideTheKeyboard];
    
    if (!ticketPassengerModel.name || ![BCBaseObject isSpecialName:ticketPassengerModel.name]) {
        [self showTipsView:@"请填写中文\\英文\\点\\空格的姓名"];
        return;
    }
    
    if (!ticketPassengerModel.idCard || ![BCBaseObject isPersonCard:ticketPassengerModel.idCard]) {
        [self showTipsView:@"请填写正确的身份证号码"];
        return;
    }
    
    if ( ticketPassengerModel.phone && ![ticketPassengerModel.phone isEqualToString:@""] && ![BCBaseObject isFNMobileNumber:ticketPassengerModel.phone]) {
        [self showTipsView:@"请填写正确的电话码号"];
        return;
    }
    
    //请求保存乘车人
    NSDictionary *requestData = @{@"name":ticketPassengerModel.name,
                                  @"type":[[NSNumber alloc]initWithInt:ticketPassengerModel.type],
                                  @"idCard":ticketPassengerModel.idCard,
                                  @"phone":ticketPassengerModel.phone ? ticketPassengerModel.phone : @"",
                                  };
    [self startWait];
    [NetManagerInstance sendRequstWithType:EmRequestType_AddPassengerHistory params:^(NetParams *params) {
        params.method = EMRequstMethod_POST;
        params.data = requestData;
    }];
}

-(void)inputTextChanged:(id)sender
{
    if (![sender isKindOfClass:[UITextField class]]) {
        return;
    }
    UITextField *inputText = (UITextField *)sender;
    switch (inputText.tag) {
        case 10001:
        {
            ticketPassengerModel.name = inputText.text;
        }
            break;
        case 10002:
        {
            ticketPassengerModel.idCard = inputText.text;
        }
            break;
        case 10003:
        {
            ticketPassengerModel.phone = inputText.text;
        }
            break;
        default:
            break;
    }
}

- (IBAction)backClick:(id)sender {
    
}

/**
 *  隐藏键盘
 */
-(void)hideTheKeyboard
{
    UIView *nameView = [_mainTableView viewWithTag:10001];
    UIView *idCardView = [_mainTableView viewWithTag:10002];
    UIView *phoneView = [_mainTableView viewWithTag:10003];
    
    if (nameView) {
        [(UITextField*)nameView resignFirstResponder];
    }
    if (idCardView) {
        [(UITextField*)idCardView resignFirstResponder];
    }
    if (phoneView) {
        [(UITextField*)phoneView resignFirstResponder];
    }
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell ;
    UILabel *headerLabel;
    UILabel *typePeopleLabel;
    UITextField *inputText;
    if (indexPath.row == 2)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"typePeopleCell"];
        headerLabel = [cell viewWithTag:1001];
        typePeopleLabel = [cell viewWithTag:1002];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"contactPeopleCell"];
        headerLabel = [cell viewWithTag:1001];
        inputText = [cell viewWithTag:1002];
    }
    
    UIView *lineView = [cell viewWithTag:1003];
    lineView.backgroundColor = UIColorFromRGB(0xD0D0D0);
    
    inputText.returnKeyType = UIReturnKeyDone;
    inputText.delegate = self;
    [inputText addTarget:self action:@selector(inputTextChanged:) forControlEvents:UIControlEventEditingChanged];
    //单独注册文本更改通知 适用于中文
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldEditChanged:)
                                                 name:UITextFieldTextDidChangeNotification object:inputText];
    
    switch (indexPath.row) {
        case 0:
        {
            headerLabel.text = @"姓名";
            inputText.keyboardType = UIKeyboardTypeDefault;
            inputText.text = ticketPassengerModel.name;
            inputText.placeholder = @"填写姓名";
            inputText.tag = 10001;
            
        }
            break;
        case 1:
        {
            headerLabel.text = @"身份证";
            inputText.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            inputText.text = ticketPassengerModel.idCard;
            inputText.placeholder = @"填写身份证号码";
            inputText.tag = 10002;
        }
            break;
        case 2:
        {
            headerLabel.text = @"类型";
            typePeopleLabel.text = ticketPassengerModel.type == PassengerTypeAll? @"全价票":@"儿童/军残半价票";
        }
            break;
        case 3:
        {
            headerLabel.text = @"电话";
            inputText.keyboardType = UIKeyboardTypeNumberPad;
            inputText.text = ticketPassengerModel.phone;
            inputText.placeholder = @"选填";
            inputText.tag = 10003;
            lineView.backgroundColor = [UIColor clearColor];
            
        }
            break;
        default:
            break;
    }
    
    
    return cell;
}

#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        [self hideTheKeyboard];
        //点击了选择票类型
//        PeopleTypeSelectorView *typeSelectorView = [[PeopleTypeSelectorView alloc] initWithFrameBlock:self.view.bounds passengerType:ticketPassengerModel.type completion:^(int passengerType) {
//            ticketPassengerModel.type = passengerType;
//            [_mainTableView reloadData];
//        }];
//        [typeSelectorView showInView:self.view];
        
        int sectIndex = ticketPassengerModel.type == 1 ? 0 : 1;
        [SelectPickerView showInView:self.view items:@[@"全价票",@"儿童/军残半价票"] selectIndex:sectIndex completion:^(NSInteger index) {
            ticketPassengerModel.type = index == 0 ? 1 : 3;
            [_mainTableView reloadData];
        }];
        
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideTheKeyboard];
}
#pragma mark -- UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (range.length == 1) {
        return YES;
    }
    
    if (10001 == textField.tag) {
        
        if (range.location > 16) {
            return NO;
        }
    }
    else if (10002 == textField.tag) {
        if (range.location > 20) {
            return NO;
        }
    }
    else if (10003 == textField.tag) {
        if (range.location > 15) {
            return NO;
        }
    }
    
    return YES;
}

-(void)textFieldEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    
    int MAX_STARWORDS_LENGTH = 16;
    
    if (10002 == textField.tag) {
        MAX_STARWORDS_LENGTH = 20;
    }
    else if (10003 == textField.tag){
        MAX_STARWORDS_LENGTH = 15;
    }
    
    
    NSString *toBeString = textField.text;
    NSString *lang = [textField.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"])// 简体中文输入
    {
        //获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position)
        {
            if (toBeString.length > MAX_STARWORDS_LENGTH)
            {
                textField.text = [toBeString substringToIndex:MAX_STARWORDS_LENGTH];
            }
            //身份证最后一个x转换为大写
            if (10002 == textField.tag) {
                textField.text = [textField.text uppercaseString];
            }
        }
        
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else
    {
        if (toBeString.length > MAX_STARWORDS_LENGTH)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:MAX_STARWORDS_LENGTH];
            if (rangeIndex.length == 1)
            {
                textField.text = [toBeString substringToIndex:MAX_STARWORDS_LENGTH];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, MAX_STARWORDS_LENGTH)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
            //身份证最后一个x转换为大写
            if (10002 == textField.tag) {
                textField.text = [textField.text uppercaseString];
            }
        }
    }
}

#pragma mark ----
- (void)httpRequestFinished:(NSNotification *)notification
{
    [super httpRequestFinished:notification];
    [self stopWait];
    
    ResultDataModel *resultData = (ResultDataModel *)notification.object;
    
    if (resultData.code == !EmCode_Success) {
        return;
    }
    
    switch (resultData.type) {
        case EmRequestType_AddPassengerHistory:
        {
            
            //执行保存成功回调
            if ([self.delegate respondsToSelector:@selector(addContactPeopleSuccess:)]) {
                [self.delegate addContactPeopleSuccess:ticketPassengerModel];
            }
            //根据跳入类型返回不同的数据
            switch (_addPeopleTypeEnum) {
                case addPeopleFromOrderTypeEnum:
                {
                    NSMutableArray *viewControllers = [self.navigationController.viewControllers mutableCopy];
                    //SelectContactPeopleViewControl
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Tickets" bundle:nil];
                    UIViewController *contactPeopleListViewController = [storyboard instantiateViewControllerWithIdentifier:@"SelectContactPeopleViewControl"];
                    [viewControllers removeLastObject]; //移除当前的
                    [viewControllers addObject:contactPeopleListViewController]; //添加联系人列表的
                    //页面跳转
                    [self.navigationController setViewControllers:viewControllers animated:YES];
                }
                    break;
                case addPeopleFromListTypeEnum:
                    [self.navigationController popViewControllerAnimated:YES];
                    break;
                default:
                    break;
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
