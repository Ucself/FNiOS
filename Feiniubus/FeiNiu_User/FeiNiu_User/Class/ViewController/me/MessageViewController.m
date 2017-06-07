//
//  MessageViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/25.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "MessageViewController.h"
#import "PushNotificationAdapter.h"

@interface MessageViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *noMessageView;

@property (strong, nonatomic) NSArray *messages;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.messages = [PushNotificationAdapter getAPNSList];
    
    if (self.messages && self.messages.count > 0) {
        UIBarButtonItem *clearItem = [[UIBarButtonItem alloc]initWithTitle:@"清空" style:UIBarButtonItemStylePlain target:self action:@selector(actionClearMessage:)];
        self.navigationItem.rightBarButtonItem = clearItem;
    }
    [self setupUI];
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

- (void)setupUI{
    if (self.messages.count == 0) {
        self.tableView.hidden = YES;
        self.noMessageView.hidden = NO;
    }else{
        self.tableView.hidden = NO;
        self.noMessageView.hidden = YES;
    }
}

- (void)actionClearMessage:(UIBarButtonItem *)sender{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定清除消息吗？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alertView show];
    
}
#pragma mark- uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    UILabel *lblMessage = (UILabel *)[cell.contentView viewWithTag:201];
    UILabel *lblDate = (UILabel *)[cell.contentView viewWithTag:202];
    NSDictionary *message = self.messages[indexPath.row];
    lblMessage.text = message[kAPNSItemMessage];
    lblDate.text = message[kAPNSItemDate];
    //cell.textLabel.text = [NSString stringWithFormat:@"第%ld行", indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark- http request handler
-(void)httpRequestFinished:(NSNotification *)notification
{
    [self stopWait];
}

-(void)httpRequestFailed:(NSNotification *)notification
{
    [super httpRequestFailed:notification];
    
}

#pragma mark -- UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
     
        [PushNotificationAdapter clearAPNSList];
        self.messages = nil;
        [self.tableView reloadData];
        [self setupUI];
    }
}
@end
