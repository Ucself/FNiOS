//
//  MoreViewController.m
//  FeiNiu_User
//
//  Created by 易达飞牛 on 15/8/20.
//  Copyright (c) 2015年 feiniu.com. All rights reserved.
//

#import "MoreViewController.h"
#import "PushConfiguration.h"
#import <FNUIView/REFrostedViewController.h>
#import <FNUIView/UIViewController+REFrostedViewController.h>
#import "WebContentViewController.h"
#import "FeedbackViewController.h"

#import "LoginViewController.h"
#import "ComTempCache.h"
#import "UserPreferences.h"
#import "AuthorizeCache.h"

@interface MoreViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *array;
@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.array = @[@"用户使用协议", @"常见问题", @"意见反馈", @"关于我们"];      //@"功能介绍",
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

- (void)setVersionLabel:(NSString *)versionId cell:(UITableViewCell *)cell{
    
    UILabel *detailLabel = [[UILabel alloc] init];
    [detailLabel setTextAlignment:NSTextAlignmentCenter];
    [detailLabel setText:[NSString stringWithFormat:@"当前版本%@",versionId]];
    [detailLabel setFont:[UIFont systemFontOfSize:15]];
    [detailLabel setTextColor:[UIColor grayColor]];
    [cell.contentView addSubview:detailLabel];
    [detailLabel makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(cell.right).offset(-30);
        make.centerY.equalTo(cell.centerY);
        make.width.equalTo(100);
        make.height.equalTo(40);
    }];
}

#pragma mark - Actions
- (IBAction)actionSignOut:(UIButton *)sender {
    [[AuthorizeCache sharedInstance] clean];
    [UserPreferInstance setUserInfo:nil];
    [[PushConfiguration sharedInstance] resetAlias];
    [ComTempCache removeObjectWithKey:KeyContactList];
    [NetManagerInstance setAuthorization:@""];
    
    [self showTip:@"注销成功" WithType:FNTipTypeSuccess];

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:KLogoutNotification object:nil];
    });
//    [LoginViewController presentAtViewController:self.frostedViewController needBack:NO requestToHomeIfCancel:NO completion:^{
//        [self.frostedViewController hideMenuViewController];
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    } callBalck:^(BOOL isSuccess, BOOL needToHome) {
//        
//    }];
    
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"moretableviewcell"];
    UILabel *titleLabel = [cell viewWithTag:101];
    titleLabel.text = self.array[indexPath.row];
    
    UIView *longLineView = [cell viewWithTag:103];
    //最后一行
    if (indexPath.row == self.array.count - 1) {
        [longLineView setHidden:NO];
    }
    else{
        [longLineView setHidden:YES];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self performSegueWithIdentifier:@"torating" sender:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    if (indexPath.row == 2) {
//        //update item
////        CustomVersionView *viewVersion = [CustomVersionView sharedInstance];
////        [viewVersion showInView:self.view];
//        
//    }else{
        //test vc
        
        WebContentViewController *webViewController = [WebContentViewController instanceWithStoryboardName:@"Me"];
        
        
        switch (indexPath.row) {
            case 0:
                webViewController.vcTitle = @"使用协议";
                webViewController.urlString = [NSString stringWithFormat:@"%@agreement1.html",KAboutServerAddr];
                [self.navigationController pushViewController:webViewController animated:YES];
                break;
            case 1:
                webViewController.vcTitle = @"常见问题帮助";
                webViewController.urlString = HTMLAddr_FAQ;
                [self.navigationController pushViewController:webViewController animated:YES];
                break;
            case 2: {
                UIViewController *c = [FeedbackViewController instanceWithStoryboardName:@"Me"];
                [self.navigationController pushViewController:c animated:YES];
            }
                break;
            case 3:
                webViewController.vcTitle = @"关于我们";
                webViewController.urlString = [NSString stringWithFormat:@"%@about.html?version=%@",KAboutServerAddr,[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
                [self.navigationController pushViewController:webViewController animated:YES];
                break;
                //            case 1:
                //                webViewController.vcTitle = @"功能介绍";
                //                webViewController.urlString = [NSString stringWithFormat:@"%@introduce.html",KAboutServerAddr];
                //                break;
                
            default:
                break;
        }

//    }
}

@end
